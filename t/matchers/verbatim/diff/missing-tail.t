verbatim matcher, missing line of output at the end
===================================================


setup::

  $ cat > testfile <<\EOF
  >   $ printf "%s\n" a b
  >   a
  >   b
  >   X
  > EOF


test::

  $ dram testfile
  !
  --- testfile
  +++ testfile
  @@ -1,4 +1,3 @@
     $ printf "%s\n" a b
     a
     b
  -  X
  
  # Ran 1 test, 1 failed.
  [2]
