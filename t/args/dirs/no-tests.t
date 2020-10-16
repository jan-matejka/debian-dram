`dram DIR` with files not recognized as tests
=============================================


setup::

  $ cat >> testfile <<\EOF
  >   $ echo hello
  >   goodbye
  > EOF


test::

  $ dram .
  
  tests: 0, skipped: 0, failed: 0
