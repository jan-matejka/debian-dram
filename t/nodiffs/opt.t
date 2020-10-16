`dram -D` inhibits printing of diffs
====================================


setup::

  $ cat > testfile <<\EOF
  >   $ echo hello
  >   goodbye
  > EOF


test::

  $ dram -D testfile
  !
  
  tests: 1, skipped: 0, failed: 1
  [1]
