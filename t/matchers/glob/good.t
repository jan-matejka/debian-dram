setup::

  $ cat > testfile <<\EOF
  >   $ echo hello
  >   *ll? (glob)
  > EOF


test::

  $ dram testfile
  .
  
  tests: 1, skipped: 0, failed: 0
