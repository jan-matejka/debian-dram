mismatched output
=================


setup::

  $ cat > testfile <<\EOF
  >   $ printf "%s\n" a b c
  >   a
  >   d
  >   c
  > EOF


test::

  $ dram testfile
  !
  --- testfile
  +++ testfile
  @@ -1,4 +1,4 @@
     $ printf "%s\n" a b c
     a
  -  d
  +  b
     c
  
  tests: 1, skipped: 0, failed: 1
  [1]


setup::

  $ cat > testfile <<\EOF
  >   $ printf "%s\n" a b
  >   a
  >   b
  >   c
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
  -  c
  
  tests: 1, skipped: 0, failed: 1
  [1]


setup::

  $ cat > testfile <<\EOF
  >   $ printf "%s\n" a b
  >   b
  > EOF


test::

  $ dram testfile
  !
  --- testfile
  +++ testfile
  @@ -1,2 +1,3 @@
     $ printf "%s\n" a b
  +  a
     b
  
  tests: 1, skipped: 0, failed: 1
  [1]
