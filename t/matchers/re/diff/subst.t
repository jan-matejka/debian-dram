re matcher, a line substitution in the middle
=============================================


setup::

  $ cat > testfile <<\EOF
  >   $ printf "%s\n" a X c
  >   a (re)
  >   b (re)
  >   c (re)
  > EOF


test::

  $ dram testfile
  !
  --- testfile
  +++ testfile
  @@ -1,4 +1,4 @@
     $ printf "%s\n" a X c
     a (re)
  -  b (re)
  +  X
     c (re)
  
  tests: 1, skipped: 0, failed: 1
  [1]
