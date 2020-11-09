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
  
  tests: 1, skipped: 0, failed: 1
  [1]


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
  
  tests: 1, skipped: 0, failed: 1
  [1]
