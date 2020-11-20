// vim: et sts=2 fdm=marker cms=\ //\ %s
//
// Copyright (C) 2020  Roman Neuhauser
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

module dram;

import core.time;
import std.algorithm;
import std.conv;
import std.container.array;
import std.datetime.stopwatch: AutoStart, StopWatch;
import std.datetime.systime;
import std.file;
import std.path;
import std.process;
import std.range;
import std.regex;
import std.stdio;
import std.string;
import std.typecons;
import dxml.util;
import dxml.writer;

import mdiff;

int main(string[] argv) // {{{
{
  // stdout has a huge buffer by default, this causes
  // output on stderr to appear in the terminal way out
  // of order.  setting both streams to line-buffered
  // fixes this.
  [stdout, stderr].each!(f => f.setvbuf(1024, _IOLBF));

  // std.getopt sucks.  -h/--help handling is hardcoded,
  // defaultGetoptPrinter prints long options right-justified
  // which looks horribly messy, and an unknown option
  // causes an exception.  it's fucked up.
  //
  // until and unless i can fix this, dram is configured
  // using environment variables only.
  auto cfg = DramConfig(environment.toAA);

  try {
    // each operand is either a testfile or a directory
    // (supposedly) containing testfiles (recursively)
    auto tests = argv[1..$]
      .map!(arg => cfg.findTestFiles(arg))
      .joiner
      .map!buildNormalizedPath
      .array
    ;

    cfg.setUp;

    auto skipped = 0;
    auto failed  = 0;
    auto results = tests
      .map!(test => runTest(cfg, test))
      .cache
      // print dots, exclamation marks, etc.
      .tee!(r => cfg.report(r))
      // abort on first fail if given -b
      .until!(r => cfg.failFast(r))(No.openRight)
      // force evaluation, need reported results
      // before printing the newline below.
      .array
    ;

    if (results.length < tests.length) {
      auto done = results.map!(tr => tr.testFile);
      results ~= tests
        .filter!(x => !done.canFind(x))
        .map!(tf => TestResult(80, tf))
        .cache
        .tee!(r => cfg.report(r))
        .array
      ;
    }

    // tally results
    results.each!((r) {
      skipped += r.skip;
      failed  += r.fail;
    });

    if (!cfg.verbose && !results.empty)
      writeln;

    // if any test failed, exit 1
    auto exit = results
      .map!(r => cfg.diffAndPatch(r))
      .sum > 0
    ;

    "\ntests: %d, skipped: %d, failed: %d".writefln(
      tests.length
    , skipped
    , failed
    );

    cfg.cleanUp(results, skipped, failed);

    return failed ? 1 : exit;
  } catch (FileException e) {
    stderr.writeln(e.msg);
    return 1;
  }
} // }}}

struct DramConfig // {{{
{
  string[] envvars;
  bool   failfast;
  bool   keepenv;
  bool   keeptmp;
  bool   nodiffs;
  bool   verbose;
  bool   update;
  bool   ask;
  string extension = ".t";
  string junitFile;

  StopWatch stopWatch;

  string indent;
  Tuple!(
    string, "ps1",
    string, "ps2",
  ) prompts;

  Tuple!(
    string, "glob",
    string, "regex",
    string, "noeol",
  ) suffixes;

  string cookie;

  string diffcmd;
  string patchcmd;
  string shell;
  string tmpdir;

  this(string[string] env) // {{{
  {
    envvars = env.get("DRAM_ENV", "").split;
    failfast = isAnyOf("1Yy", env.get("DRAM_FAIL_FAST", "0"));
    keepenv = isAnyOf("1Yy", env.get("DRAM_KEEP_ENVIRON", "0"));
    keeptmp = isAnyOf("1Yy", env.get("DRAM_KEEP_TMPDIR", "0"));
    nodiffs = isAnyOf("1Yy", env.get("DRAM_NODIFFS", "0"));
    verbose = isAnyOf("1Yy", env.get("DRAM_VERBOSE", "0"));
    update = isAnyOf("1YyAa", env.get("DRAM_UPDATE", "0"));
    ask = isAnyOf("Aa", env.get("DRAM_UPDATE", "0"));
    extension = env.get("DRAM_TEST_SUFFIX", ".t");
    junitFile = env.get("DRAM_JUNIT_FILE", "");

    stopWatch = StopWatch(AutoStart.no);

    indent = env.get("DRAM_INDENT", "  ");
    prompts = tuple(
      indent ~ "$ ",
      indent ~ "> ",
    );
    suffixes = tuple(
      " (glob)",
      " (re)",
      " (no-eol)",
    );

    cookie = "DRAM" ~ thisProcessID.to!string;

    diffcmd = env.get("DRAM_DIFF", "diff");
    patchcmd = env.get("DRAM_PATCH", "patch");
    shell = env.get("DRAM_SHELL", "sh");
    tmpdir = env.get("DRAM_TMPDIR", tempDir.buildPath("dramtests-" ~ thisProcessID.to!string));
  } // }}}
  string default_(string def, string val) // {{{
  {
    return val.empty ? def : val;
  } // }}}
  bool isAnyOf(string chars, string val) // {{{
  {
    return val.empty ? false : chars.any!(x => x == val[0]);
  } // }}}

  string[] findTestFiles(string under) // {{{
  {
    if (under.isDir)
      return dirEntries(under, SpanMode.breadth)
        .map!(to!string)
        .filter!(fn => fn.isFile && fn.extension == extension)
        .array // `sort` needs a random-access container
        .sort
        .array
      ;
    else
      return [under];
  } // }}}

  void setUp() // {{{
  {
    stopWatch.start;
    tmpdir.mkdirRecurse;
  } // }}}
  void cleanUp(TestResult[] results, int skipped, int failed) // {{{
  {
    if (!junitFile.empty)
      writeJUnitFile(results, skipped, failed);
    if (!keeptmp)
      tmpdir.rmdirRecurse;
    else
      "preserved %s".writefln(tmpdir);
  } // }}}
  void writeJUnitFile(TestResult[] results, int skipped, int failed) // {{{
  // based on https://llg.cubic.org/docs/junit/
  // deviation from Cram: omits <testsuite>'s hostname attribute
  {
    auto now = Clock.currTime!(ClockType.second);
    auto suiteTime = stopWatch.peek.total!"msecs" / 1000.0;
    auto junit = File(junitFile, "w");
    auto orange = junit.lockingTextWriter;
    orange.writeXMLDecl!string;
    auto xml = xmlWriter(orange, "  ");
    xml.openStartTag("testsuite", Newline.yes);
    xml.writeAttr("name", "dram", Newline.yes);
    xml.writeAttr("tests", results.length.to!string, Newline.yes);
    xml.writeAttr("failures", failed.to!string, Newline.yes);
    xml.writeAttr("skipped", skipped.to!string, Newline.yes);
    xml.writeAttr("timestamp", now.toISOExtString, Newline.yes);
    xml.writeAttr("time", suiteTime.to!string, Newline.yes);
    xml.closeStartTag;
    results.each!((tr) {
      auto ttime = tr.time.total!"msecs" / 1000.0;
      xml.openStartTag("testcase", Newline.yes);
      xml.writeAttr("classname", encodeAttr(tr.testFile), Newline.yes);
      xml.writeAttr("name", encodeAttr(tr.testFile.baseName), Newline.yes);
      xml.writeAttr("time", ttime.to!string, Newline.yes);
      if (tr.skip) {
        xml.closeStartTag;
        xml.openStartTag("skipped");
        xml.closeStartTag(EmptyTag.yes);
        xml.writeEndTag("testcase");
      }
      else if (tr.fail) {
        xml.closeStartTag;
        tr.diff.rewind;
        auto difftext = appender!string;
        //difftext.reserve(diff.size);
        tr.diff
          .byLine(Yes.keepTerminator)
          .each!(l => difftext ~= encodeText(l))
        ;
        xml.openStartTag("failure", Newline.yes);
        xml.closeStartTag;
        xml.writeText(difftext[], Newline.yes, InsertIndent.no);
        xml.writeEndTag("failure", Newline.yes);
        xml.writeEndTag("testcase");
      } else {
        xml.closeStartTag(EmptyTag.yes);
      }
    });
    xml.writeEndTag("testsuite");
    junit.writeln;
    junit.close;
  } // }}}
  bool failFast(TestResult r) // {{{
  {
    return failfast ? r.fail : false;
  } // }}}
  void report(TestResult r) // {{{
  {
    (r.fail ? "!" : r.skip ? "s" : ".").write;
    if (verbose)
      writeln(" ", r.testFile);
  } // }}}
  int diffAndPatch(TestResult r) // {{{
  {
    // if it's closed it should be empty
    if (!r.diff.isOpen)
      return 0;

    if (!nodiffs)
      r.diff.byLine.each!writeln;

    if (!update)
      return 1;

    // $DRAM_UPDATE is either "1", "[Yy]es" or "[Aa]sk"

    if (ask) {
      writefln("%s failed. Apply results? [Y/n]", r.testFile);

      auto reply = std.stdio.stdin.readln;
      if (reply.length && 0 > "Yy".indexOf(reply[0]))
        return 1;
    }

    if (runPatch(this, r.testFile, r.diff.name))
      stderr.writefln("Failed to patch %s from %s", r.testFile, r.diff.name);
    return 1;
  } // }}}
  string[string] env(string test, string tmpdir) // {{{
  {
    string[string] env;
    if (keepenv) {
      // -E / DRAM_KEEP_ENVIRON=[1Yy] preserves existing env. variables
      // DRAM_* ones are always removed, because not doing so would
      // break running dram in dram tests.
      env = environment
        .toAA
        .byPair
        .filter!(nv => !nv.key.startsWith("DRAM_"))
        .assocArray
      ;
    } else {
      // this is the default environment
      env = [
        "COLUMNS": "80"
      , "LANG": "C"
      , "LC_ALL": "C"
      , "LINES": "20"
      , "PATH": environment.get("PATH", "/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin")
      , "TZ": "UTC"
      ];
      // variables forced using -e / $DRAM_ENV
      envvars.each!((n) {
        auto v = environment.get(n);
        if (v != null)
          env[n] = v;
      });
    }
    // these are always present, and specific to each testfile
    [
      "TESTDIR": test.dirName.absolutePath.buildNormalizedPath
    , "TESTFILE": test.baseName
    , "TMPDIR": tmpdir.absolutePath
    ].each!((n, v) => env[n] = v);
    return env;
  } // }}}

  bool matchLine(string expected, string actual) // {{{
  {
    auto el = expected.length;
    if (expected.endsWith(suffixes.glob))
      return globMatch(actual, expected.dropBack(suffixes.glob.length));
    if (expected.endsWith(suffixes.regex))
      return !matchFirst(actual, "^" ~ expected.dropBack(suffixes.regex.length) ~ "$").empty;
    return expected == actual;
  } // }}}
  string inputLine(ulong i, string ln) // {{{
  {
    return (i == 0 ? prompts.ps1 : prompts.ps2) ~ ln;
  } // }}}
  string outputLine(string ln) // {{{
  {
    return indent ~ ln;
  } // }}}
  string exitLine(int exitcode) // {{{
  {
    return format("%s[%d]", indent, exitcode);
  } // }}}
  string cookieLine(int i) // {{{
  {
    return format("echo %s %d $?", cookie, i);
  } // }}}
} // }}}

TestResult runTest(DramConfig cfg, string testFile) // {{{
{
  auto stopWatch = StopWatch(AutoStart.yes);
  auto p = new DramParser(cfg);
  auto asserts = p.parseFile(testFile);

  // each test runs in a private directory, its basename
  // is derived from the absolute pathname of the testfile
  // this is to avoid an annoyance from cram where if you
  // have foo/some.t and bar/some.t, you'll get (roughly)
  // /tmp/cram-$PID/some.t-1 and /tmp/cram-$PID/some.t-2.
  // IOW, it's hard to tell which one is which.
  auto twd = cfg.tmpdir.buildNormalizedPath(
    testFile.absolutePath.buildNormalizedPath.replace("/", "#")
  ).to!string;
  twd.mkdirRecurse;

  // each test work area contains the following files:
  // "script" - the code extracted from the testfile
  // "out" - this will contain the stdout and stderr
  //   resulting from a run of "script"
  // "result" - outputs from "out" merged with the original
  //   testfile
  // "diff" - unified diff between the testfile and "result"
  //
  // "script" runs in `twd`/work.
  auto outputFile = File(twd.buildPath("out"), "w+");
  auto script = File(twd.buildPath("script"), "w+");

  writeScript(cfg, script, asserts);

  script.flush;

  // exit code of 80 is special, it causes dram to ignore
  // outputFile from the script and treat the test as "skipped".
  auto exit = runScript(cfg, testFile, script.name, outputFile);
  if (exit) {
    stopWatch.stop;
    return TestResult(exit, testFile, twd, stopWatch.peek);
  }

  outputFile.rewind;

  auto result = File(twd.buildPath("result"), "w+");
  writeResults(cfg, result, asserts, collectOutputs(cfg, outputFile));
  outputFile.close;

  result.close;
  auto diff = File(twd.buildPath("diff"), "w+");
  auto exDiff = runDiff(cfg, testFile, result.name, diff);

  // zero exit from diff means the files are the same,
  // in that case diffAndPatch doesn't need the file.
  if (exDiff)
    diff.rewind;
  else
    diff.close;
  stopWatch.stop;
  return TestResult(exDiff, testFile, twd, stopWatch.peek, diff);
} // }}}

struct TestResult // {{{
{
  int exit;
  string testFile;
  string twd;
  Duration time;
  File diff;
  bool fail() // {{{
  {
    return exit != 0 && exit != 80;
  } // }}}
  bool skip() // {{{
  {
    return exit == 80;
  } // }}}
  bool success() // {{{
  {
    return exit == 0;
  } // }}}
} // }}}

// a testfile is prose interspersed with command blocks
// (or vice versa, depending on one's point of view).
// another way to look at it is that it's a series of
// command blocks, where each block consists of a command,
// its outputs, and a prose trailer.
// to account for any leading prose at the beginning of
// the testfile, dram synthesizes an always-successful
// command and skips it when writing out the results.

struct Assertion // {{{
{
  Array!string program;
  Array!string output;
  uint exitcode;
  Array!string trailer;
  this(string cmd)
  {
    program.insertBack(cmd);
  }
} // }}}

class DramParser // {{{
{
  DramConfig cfg;

  Array!Assertion asserts;

  alias LineParser = bool delegate(int, string);
  LineParser[] Start;
  LineParser[] CmdLine;
  LineParser[] OutputLine;
  LineParser[]* parsers;

  Regex!char reExitCode;

  this(DramConfig cfg) // {{{
  {
    this.cfg = cfg;
    reExitCode = regex("^" ~ escaper(cfg.indent).to!string ~ r"\[(\d+)\]");
    parsers    = &Start;
    Start      = [&cmdline, &trailer];
    CmdLine    = [&cmdline, &inputline, &exitcode, &outputline, &trailer];
    OutputLine = [&cmdline, &exitcode, &outputline, &trailer];
    asserts.insertBack(Assertion(":"));
  } // }}}
  ref Assertion current() // {{{
  {
    return asserts.back();
  } // }}}
  Array!Assertion parseFile(string testFile) // {{{
  {
    File(testFile)
      .byLineCopy
      .enumerate(1)
      .each!((nr, ln) => parseLine(nr, ln))
    ;
    return asserts;
  } // }}}
  void parseLine(int lnno, string ln) // {{{
  {
    foreach (parse; *parsers)
      if (parse(lnno, ln)) return;
    assert(0, "parser bug, trailer() is supposed to consume anything");
  } // }}}
  bool cmdline(int lnno, string ln) // {{{
  {
    if (!ln.startsWith(cfg.prompts.ps1))
      return false;
    asserts.insertBack(Assertion());
    current.program ~= ln[cfg.prompts.ps1.length..$];
    parsers = &CmdLine;
    return true;
  } // }}}
  bool inputline(int lnno, string ln) // {{{
  {
    if (!ln.startsWith(cfg.prompts.ps2))
      return false;
    current.program ~= ln[cfg.prompts.ps2.length..$];
    parsers = &CmdLine;
    return true;
  } // }}}
  bool outputline(int lnno, string ln) // {{{
  {
    if (!ln.startsWith(cfg.indent))
      return false;
    ln = ln[cfg.indent.length..$];
    glob(ln) || re(ln) || literal(ln);
    parsers = &OutputLine;
    return true;
  } // }}}
  bool glob(string ln) // {{{
  {
    if (!ln.endsWith(cfg.suffixes.glob))
      return false;
    current.output ~= ln;
    return true;
  } // }}}
  bool re(string ln) // {{{
  {
    if (!ln.endsWith(cfg.suffixes.regex))
      return false;
    current.output ~= ln;
    return true;
  } // }}}
  bool literal(string ln) // {{{
  {
    current.output ~= ln;
    return true;
  } // }}}
  bool exitcode(int lnno, string ln) // {{{
  {
    auto m = matchFirst(ln, reExitCode);
    if (m.empty)
      return false;
    current.exitcode = m[1].to!uint;
    parsers = &Start;
    return true;
  } // }}}
  bool trailer(int lnno, string ln) // {{{
  {
    current.trailer ~= ln;
    parsers = &Start;
    return true;
  } // }}}
} // }}}

void writeScript(DramConfig cfg, File script, Array!Assertion asserts) // {{{
// the outputs from `echo DRAM ...` are used to gather
// exit codes from test code.
{
  asserts[].enumerate(1).each!((int nr, Assertion ass) {
    ass.program.each!(t => script.writeln(t));
    script.writefln(cfg.cookieLine(nr));
  });
} // }}}

int runScript(DramConfig cfg, string test, string script, File outputFile) // {{{
// stdin is redirected from /dev/null
// stdout, stderr from the script are redirected into `outputFile`
// working directory is a freshly created "work", a sibling of
// the script
{
  auto workdir = script.dirName.buildPath("work");
  auto tmpdir  = script.dirName.buildPath("tmp");
  workdir.mkdir;
  tmpdir.mkdir;

  try {
    auto pid = spawnProcess(
      [cfg.shell, script]
    , File("/dev/null", "r")
    , outputFile
    , outputFile
    , cfg.env(test, tmpdir)
    , Config.retainStderr | Config.retainStdout | Config.newEnv
    , workdir
    );
    return pid.wait;
  } catch (ProcessException e) {
    stderr.writefln("%s", e.msg);
    return 1;
  }
} // }}}

Array!Output collectOutputs(DramConfig cfg, File outputFile) // {{{
{
  auto outputs = Array!Output();
  auto o = Output();
  outputFile
    .byLineCopy
    .each!((ln) {
      // the cookie is supposed to be at the beginning of a line
      // if a command output ends without a trailing newline,
      // the cookie line will butt the output.
      auto parts = ln.findSplitBefore(cfg.cookie ~ " ");
      auto noeol = !parts[0].empty && !parts[1].empty;
      if (!parts[0].empty || parts[1].empty)
        o.output ~= parts[0] ~ (noeol ? cfg.suffixes.noeol : "");
      if (!parts[1].empty) {
        o.exitcode = parts[1].drop(1 + parts[1].lastIndexOf(' ')).to!uint;
        outputs ~= o;
        o = Output();
      }
    });
  return outputs;
} // }}}

void writeResults(DramConfig cfg, File sink, Array!Assertion asserts, Array!Output outputs) // {{{
// produce a copy of the testfile with actual outputs merged in
{
  // leading prose (this is the command synthesized so we
  // have something to hang the opening "trailer" on.
  asserts[0].trailer
    .each!(x => sink.writeln(x))
  ;
  zip(asserts[1..$], outputs[1..$]).each!((ass, o) {
    // command
    ass.program[]
      .each!((i, ln) => sink.writeln(cfg.inputLine(i, ln)))
    ;
    // outputs
    diff!((l, r) => cfg.matchLine(l, r))(ass.output, o.output)
      .filter!(edit => edit.newline)
      .each!(edit => sink.writeln(cfg.outputLine(edit.text)))
    ;
    // exit code
    if (o.exitcode)
      sink.writeln(cfg.exitLine(o.exitcode));
    ass.trailer
      .each!(x => sink.writeln(x))
    ;
  });
} // }}}

struct Output // {{{
{
  Array!string output;
  uint exitcode;
} // }}}

int runDiff(DramConfig cfg, string test, string result, File sink) // {{{
{
  try {
    return spawnProcess(
      [cfg.diffcmd, "-u", "--label", test, "--label", test, test, result]
    , std.stdio.stdin
    , sink
    , std.stdio.stderr
    , null
    , Config.retainStdout
    ).wait;
  } catch (ProcessException e) {
    stderr.writefln("%s", e.msg);
    return 1;
  }
} // }}}

int runPatch(DramConfig cfg, string test, string patch) // {{{
{
  try {
    return spawnProcess(
      [cfg.patchcmd, "-s", test, patch]
    ).wait;
  } catch (ProcessException e) {
    stderr.writefln("%s", e.msg);
    return 1;
  }
} // }}}
