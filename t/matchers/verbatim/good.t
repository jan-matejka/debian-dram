setup::

  $ cat > testfile <<\EOF
  >   $ echo hello
  >   hello
  > EOF


test::

  $ dram testfile
  .
  
  tests: 1, skipped: 0, failed: 0
