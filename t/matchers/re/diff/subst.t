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
  
  # Ran 1 test, 1 failed.
  [2]
