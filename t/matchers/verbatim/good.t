setup::

  $ cat > testfile <<\EOF
  >   $ echo hello
  >   hello
  > EOF


test::

  $ dram testfile
  .
  
  # Ran 1 test.
