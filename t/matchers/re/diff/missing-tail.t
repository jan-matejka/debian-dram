re matcher, missing line of output at the end
=============================================


setup::

  $ cat > testfile <<\EOF
  >   $ printf "%s\n" a b
  >   a (re)
  >   b (re)
  >   X (re)
  > EOF


test::

  $ dram testfile
  !
  --- testfile
  +++ testfile
  @@ -1,4 +1,3 @@
     $ printf "%s\n" a b
     a (re)
     b (re)
  -  X (re)
  
  # Ran 1 test, 1 failed.
  [2]
