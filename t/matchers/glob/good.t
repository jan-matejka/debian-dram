setup::

  $ cat > testfile <<\EOF
  >   $ echo hello
  >   *ll? (glob)
  > EOF


test::

  $ dram testfile
  .
  
  # Ran 1 test.
