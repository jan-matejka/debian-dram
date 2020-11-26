`dram DIR` with files not recognized as tests
=============================================


setup::

  $ cat > testfile <<\EOF
  >   $ echo hello
  >   goodbye
  > EOF


test::

  $ dram .
  
  # Ran 0 tests.
