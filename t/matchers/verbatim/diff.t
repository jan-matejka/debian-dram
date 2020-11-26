mismatched output
=================


setup::

  $ cat > testfile-1 <<\EOF
  >   $ printf "%s\n" a b
  >   a
  >   b
  >   X
  > EOF


test::

  $ dram testfile-1
  !
  --- testfile-1
  +++ testfile-1
  @@ -1,4 +1,3 @@
     $ printf "%s\n" a b
     a
     b
  -  X
  
  # Ran 1 test, 1 failed.
  [2]


setup::

  $ cat > testfile-2 <<\EOF
  >   $ printf "%s\n" a b
  >   b
  > EOF


test::

  $ dram testfile-2
  !
  --- testfile-2
  +++ testfile-2
  @@ -1,2 +1,3 @@
     $ printf "%s\n" a b
  +  a
     b
  
  # Ran 1 test, 1 failed.
  [2]
