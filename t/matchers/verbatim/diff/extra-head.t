verbatim matcher, extra line of output at the beginning
=======================================================

setup::

  $ cat > testfile <<\EOF
  >   $ printf "%s\n" X b c
  >   b
  >   c
  > EOF


test::

  $ dram testfile
  !
  --- testfile
  +++ testfile
  @@ -1,3 +1,4 @@
     $ printf "%s\n" X b c
  +  X
     b
     c
  
  # Ran 1 test, 1 failed.
  [2]
