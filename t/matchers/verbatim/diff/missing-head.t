verbatim matcher, missing line of output at the beginning
=========================================================

setup::

  $ cat > testfile <<\EOF
  >   $ printf "%s\n" b c
  >   X
  >   b
  >   c
  > EOF


test::

  $ dram testfile
  !
  --- testfile
  +++ testfile
  @@ -1,4 +1,3 @@
     $ printf "%s\n" b c
  -  X
     b
     c
  
  # Ran 1 test, 1 failed.
  [2]
