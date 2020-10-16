`dram -E` preserves environment variables
=========================================


setup::

  $ cat > testfile <<\EOF
  >   $ echo ${SNAFUBAR-unset}
  >   roflmao
  > EOF


test::

  $ SNAFUBAR=roflmao dram -E testfile
  .
  
  tests: 1, skipped: 0, failed: 0
