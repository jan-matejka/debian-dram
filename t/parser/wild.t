indented prose handling
=======================

test code begins with an indented line starting with
the command leader ("$ " by default), continues with
optional continuation lines ("> " by default), 
output lines (indented lines *not* starting with either
leader), through exit code line ([%d]).

any other indented lines are prose (ie. not tests).

setup::

  $ # exit 80

  $ cat > indents.t <<\EOF
  > prose
  >   indented prose
  > 
  > more prose
  > 
  >   more indented prose
  >   even more indented prose
  >   $ echo hello; (exit 42)
  >   hello
  >   [42]
  >   whoa, indented prose!
  > EOF

  $ dram -T indents.t
  .
  
  tests: 1, skipped: 0, failed: 0
  preserved * (glob)


test::

  $ cat $TMPDIR/*/*indents.t/script
  :
  echo DRAM\d+ 1 \$\? (re)
  echo hello; (exit 42)
  echo DRAM\d+ 2 \$\? (re)


setup::

  $ cat > no-tests.t <<\EOF
  > a test looks like this (note, this is *not* to be
  > executed because the command prompt is wrong!)::
  > 
  >   % echo fubar
  >   > fubar
  > 
  >   % (exit 42)
  >   [42]
  > 
  > if the output or exit code does not match, dram
  > will emit a unified diff::
  > 
  >   % echo fubar
  >   > snafu
  > 
  >   % (exit 42)
  >   [69]
  > EOF

  $ dram -T no-tests.t
  .
  
  tests: 1, skipped: 0, failed: 0
  preserved * (glob)


test::

  $ cat $TMPDIR/*/*no-tests.t/script
  :
  echo DRAM\d+ 1 \$\? (re)
