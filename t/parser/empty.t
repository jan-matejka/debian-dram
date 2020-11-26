empty testfile handling
=======================

.../script should contain a single synthesized "true",
and its fence.

setup::

  $ touch testfile
  $ dram -T testfile
  .
  
  # Ran 1 test.
  preserved * (glob)


tests::

  $ find $TMPDIR -name script -exec cat {} \;
  :
  echo DRAM\d+ 1 \$\? (re)
