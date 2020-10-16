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

import std.algorithm;
import std.conv;
import std.container.array;
import std.file;
import std.path;
import std.process;
import std.range;
import std.regex;
import std.stdio;
import std.string;
import std.typecons;

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

  cfg.setUp;

  try {
    // each operand is either a testfile or a directory
    // (supposedly) containing testfiles (recursively)
    auto tests = argv[1..$]
      .map!(arg => cfg.findTestFiles(arg))
      .joiner
      .map!buildNormalizedPath
      .array
    ;
    auto ran     = 0;
    auto skipped = 0;
    auto failed  = 0;
    auto results = tests
      .map!(test => runTest(cfg, test))
      .cache
      // print dots, exclamation marks, etc.
      .tee!(r => cfg.report(r))
      // tally results
      .tee!((r) {
        ran     += 1;
        skipped += (r.skip);
        failed  += (r.fail);
      })
      // abort on first fail if given -b
      .until!(r => cfg.failFast(r))(No.openRight)
      // force evaluation, need reported results
      // before printing the newline below.
      .array
    ;

    if (!cfg.verbose && !results.empty)
      writeln;

    // if any test failed, exit 1
    auto exit = results
      .map!(r => cfg.diffAndPatch(r))
      .sum > 0
    ;

    "\ntests: %d, skipped: %d, failed: %d".writefln(
      tests.length
    , tests.length - ran + skipped
    , failed
    );

    cfg.cleanUp;

    return exit;
  } catch (FileException e) {
    stderr.writeln(e.msg);
    return 1;
  }
} // }}}

struct DramConfig // {{{
{
  bool   failfast;
  bool   keepenv;
  bool   keeptmp;
  bool   nodiffs;
  bool   verbose;
  char   update = 'n';
  string extension = ".t";

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
    failfast = isAnyOf("1Yy", env.get("DRAM_FAIL_FAST", "0"));
    keepenv = isAnyOf("1Yy", env.get("DRAM_KEEP_ENVIRON", "0"));
    keeptmp = isAnyOf("1Yy", env.get("DRAM_KEEP_TMPDIR", "0"));
    nodiffs = isAnyOf("1Yy", env.get("DRAM_NODIFFS", "0"));
    verbose = isAnyOf("1Yy", env.get("DRAM_VERBOSE", "0"));
    update = default_("no", env.get("DRAM_UPDATE", "no"))[0];
    extension = env.get("DRAM_TEST_SUFFIX", ".t");

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
    tmpdir.mkdirRecurse;
  } // }}}
  void cleanUp() // {{{
  {
    if (!keeptmp)
      tmpdir.rmdirRecurse;
    else
      "preserved %s".writefln(tmpdir);
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

    if (nodiffs)
      return 1;

    r.diff.byLine.each!writeln;

    if (0 > "1AaYy".indexOf(update))
      return 1;

    // $DRAM_UPDATE is either "1", "[Yy]es" or "[Aa]sk"

    if (update == 'a') {
      writefln("%s failed. Apply results? [Y/n]", r.testFile);

      auto reply = std.stdio.stdin.readln;
      if (reply.length && 0 > "Yy".indexOf(reply[0]))
        return 1;
    }

    auto exPatch = runPatch(this, r.testFile, r.diff.name);
    if (exPatch)
      writefln("failed to patch %s from %s", r.testFile, r.diff.name);
    return exPatch;
  } // }}}
  string[string] env(string test, string tmpdir) // {{{
  {
    string[string] env;
    if (keepenv)
      // -E / DRAM_KEEP_ENVIRON=[1Yy] preserves existing env. variables
      // DRAM_* ones are always removed, because not doing so would
      // break running dram in dram tests.
      env = environment
        .toAA
        .byPair
        .filter!(nv => !nv.key.startsWith("DRAM_"))
        .assocArray
      ;
    else
      // this is the default environment
      env = [
        "COLUMNS": "80"
      , "LANG": "C"
      , "LC_ALL": "C"
      , "LINES": "20"
      , "PATH": environment.get("PATH", "/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin")
      , "TZ": "UTC"
      ];
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
    if (exit != 80)
      std.stdio.stderr.writefln("failed to run %s", cfg.shell);
    return TestResult(exit, testFile, twd);
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
  return TestResult(exDiff, testFile, twd, diff);
} // }}}

struct TestResult // {{{
{
  int exit;
  string testFile;
  string twd;
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
  return spawnProcess(
    [cfg.diffcmd, "-u", "--label", test, "--label", test, test, result]
  , std.stdio.stdin
  , sink
  , std.stdio.stderr
  , null
  , Config.retainStdout
  ).wait;
} // }}}

int runPatch(DramConfig cfg, string test, string patch) // {{{
{
  return spawnProcess(
    [cfg.patchcmd, "-s", test, patch]
  ).wait;
} // }}}
