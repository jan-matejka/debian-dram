glob matcher, a line substitution in the middle
===============================================


setup::

  $ cat > testfile <<\EOF
  >   $ printf "%s\n" a X c
  >   a (glob)
  >   b (glob)
  >   c (glob)
  > EOF


test::

  $ dram testfile
  !
  --- testfile
  +++ testfile
  @@ -1,4 +1,4 @@
     $ printf "%s\n" a X c
     a (glob)
  -  b (glob)
  +  X
     c (glob)
  
  tests: 1, skipped: 0, failed: 1
  [1]
