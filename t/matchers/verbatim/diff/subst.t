verbatim matcher, a line substitution in the middle
===================================================


setup::

  $ cat > testfile <<\EOF
  >   $ printf "%s\n" a X c
  >   a
  >   b
  >   c
  > EOF


test::

  $ dram testfile
  !
  --- testfile
  +++ testfile
  @@ -1,4 +1,4 @@
     $ printf "%s\n" a X c
     a
  -  b
  +  X
     c
  
  # Ran 1 test, 1 failed.
  [2]
