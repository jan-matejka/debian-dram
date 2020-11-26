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
  
  # Ran 1 test, 1 failed.
  [2]
