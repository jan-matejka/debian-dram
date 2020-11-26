setup::

  $ cat > testfile <<\EOF
  >   $ echo hello
  >   .el.* (re)
  > EOF


test::

  $ dram testfile
  .
  
  # Ran 1 test.
