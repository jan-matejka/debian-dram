setup::

  $ cat > testfile <<\EOF
  >   $ echo hello
  >   .el.* (re)
  > EOF


test::

  $ dram testfile
  .
  
  tests: 1, skipped: 0, failed: 0
