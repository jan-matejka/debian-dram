simple testfile handling
========================

.../script should contain the synthesized "true",
and the commands extracted from the testfile,
each followed by a fence.

setup::

  $ cat > testfile <<\EOF
  >   $ false
  >   [1]
  >   $ echo hello; (exit 42)
  >   hello
  >   [42]
  > EOF
  $ dram -T testfile
  .
  
  # Ran 1 test.
  preserved * (glob)


tests::

  $ find $TMPDIR -name script -exec cat {} \;
  :
  echo DRAM\d+ 1 \$\? (re)
  false
  echo DRAM\d+ 2 \$\? (re)
  echo hello; (exit 42)
  echo DRAM\d+ 3 \$\? (re)
