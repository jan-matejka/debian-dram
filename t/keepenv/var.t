`DRAM_KEEP_ENVIRON=[1Yy] dram` preserves environment variables
==============================================================


setup::

  $ cat > testfile <<\EOF
  >   $ echo ${SNAFUBAR-unset}
  >   roflmao
  > EOF


test::

  $ SNAFUBAR=roflmao DRAM_KEEP_ENVIRON=1 dram testfile
  .
  
  tests: 1, skipped: 0, failed: 0
