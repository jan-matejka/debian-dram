Dram: Literate Functional Tests for the CLI
###########################################

Introduction
============

Dram is an enhanced, slightly incompatible reimplementation of Cram_.

.. _Cram: https://bitheap.org/


Testfile Format
===============

A testfile contains any number of tests interspersed with
prose.  A test consists of a command line followed by zero
or more continuation lines, followed by zero or more output
lines, optionally followed by an exit code line.

* ``"  $ %s"`` - command lines
* ``"  > %s"`` - continuation lines
* ``"  %s"`` - output lines
* ``"  [%d]"`` - exit code lines

Output lines are matched verbatim by default.
Output lines ending in ``" (re)"`` are treated as regular
expressions, see `std.regex`_ for details.  Output lines
ending in ``" (glob)"`` are treated as shell patterns,
see `std.path.globMatch`_ for details.

.. _std.regex: https://dlang.org/phobos/std_regex.html
.. _std.path.globMatch: https://dlang.org/phobos/std_path.html#globMatch

The beauty in this is twofold: one, the tests look like copy/paste
from a terminal.  In fact, run the following snippet in
an interactive shell started with `zsh -f` and you're all set
for clipboard-based testing::

  export PS1=$'%(?..[%?]\n)\n$ ' PS2='> '

Two, the syntax is compatible with reStructuredText_.

.. _reStructuredText: http://docutils.sf.net/


Test Syntax Examples
====================

::

  $ fnord()
  > {
  >   printf -- "%s\n" "$@"
  >   return $#
  > }

  $ fnord \
  >   hello \
  >   world
  hello
  world
  [2]

  $ cat <<\END
  > echo $#
  > END
  echo $#

  $ echo 'hello/goodbye?'
  h*e[?] (glob)

  $ echo foofoo
  (foo){2,} (re)


Runtime Behavior
================

Dram extracts all commands from a testfile into a script,
runs the script with a modified environment, in an empty
directory, with standard input redirected from ``/dev/null``,
and standard output plus standard error redirected into
a file.  Individual commands are fenced from each other
so their outputs are unambiguously attributable.

Dram then compares the actual outputs with expected ones,
and offers their differences (as unified diffs) for merging
into the original testfiles.


Cram (In)Compatibility
======================

Dram is *not* meant to be a 100% drop-in replacement
for Cram.

Command Line Interface
++++++++++++++++++++++

* Dram only does short options.
* There's no `-d` / `--debug` (use `-T` and examine the files left behind).
* Dram has `-j` instead of `--xunit-file`.

Testfile Syntax
+++++++++++++++

Regular expressions are *mostly* compatible,
see `std.regex`_ and `Lib/re.py`_ for comparison.

Shell patterns are somewhat different: on top of
``*`` and ``?``, Dram understands ``[abc]``, ``[!abc]``,
and ``{foo,bar,baz}``.  Backslashes do not escape
metacharacters, use ``[?]`` to match a literal ``"?"``
and ``[*]`` to match a literal ``"*"``.

.. _std.regex: https://dlang.org/phobos/std_regex.html
.. _Lib/re.py: https://docs.python.org/3/library/re.html

Diff Differences
++++++++++++++++

Dram produces smaller diffs than Cram in certain situations.
Given this test file::

    $ printf "%s\n" b c
    X (glob)
    b (glob)
    c (glob)

    $ printf "%s\n" X b c
    b (glob)
    c (glob)

Cram will produce ::

  @@ -1,8 +1,8 @@
     $ printf "%s\n" b c
  -  X (glob)
  -  b (glob)
  -  c (glob)
  +  b
  +  c

     $ printf "%s\n" X b c
  -  b (glob)
  -  c (glob)
  +  X
  +  b
  +  c

while Dram will produce ::

  @@ -1,8 +1,8 @@
     $ printf "%s\n" b c
  -  X (glob)
     b (glob)
     c (glob)

     $ printf "%s\n" X b c
  +  X
     b (glob)
     c (glob)


Test Isolation
++++++++++++++

Dram runs each testfile with its own ``$TMPDIR``.
Cram runs all testfiles in a directory with a common
``$TMPDIR``, and does not empty it between tests.

Console Output
++++++++++++++

Tests are ordered by their pathnames.  Cram runs tests
in the order `readdir(3)` returns them.

The summary line is formatted differently.

Whereas Cram displays the diff for each failed test
right after running it, Dram runs (and reports on)
all tests first, and displays diffs later.

Cram::

  !
  --- tt/x.t
  +++ tt/x.t.err
  @@ -1,2 +1,2 @@
     $ (exit 42)
  -  31
  +  [42]
  !
  --- tt/y.t
  +++ tt/y.t.err
  @@ -1,2 +1,2 @@
     $ echo hello
  -  goodbye
  +  hello

Dram::

  !!
  --- tt/x.t
  +++ tt/x.t
  @@ -1,2 +1,2 @@
     $ (exit 42)
  -  31
  +  [42]
  --- tt/y.t
  +++ tt/y.t
  @@ -1,2 +1,2 @@
     $ echo hello
  -  goodbye
  +  hello

Filesystem artifacts
++++++++++++++++++++

* Dram does not write `.err` files.
* The structure of the temporary directory is different.


Implementation
==============

Dram is written in D and uses `diff(1)` and `patch(1)`
to create and apply diffs.

Because of defficiencies in `std.getopt`_, Dram comes as a pair
of programs: ``dram.bin``, the binary compiled from D source code,
and ``dram``, a POSIX `sh(1)`-compatible wrapper.

.. _std.getopt: https://dlang.org/phobos/std_getopt.html


Build Instructions
==================

Expects Dmd_, DUB_ and GNU Make (but the ``GNUmakefile`` is trivial)::

  % make check
  % sudo make install

.. _Dmd: https://dlang.org/download.html
.. _DUB: https://dub.pm/


License
=======

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
