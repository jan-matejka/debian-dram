empty testfile handling
=======================

.../script should contain a single synthesized "true",
and its fence.

setup::

  $ touch testfile
  $ dram -T testfile
  .
  
  tests: 1, skipped: 0, failed: 0
  preserved * (glob)


tests::

  $ find $TMPDIR -name script -exec cat {} \;
  :
  echo DRAM\d+ 1 \$\? (re)
