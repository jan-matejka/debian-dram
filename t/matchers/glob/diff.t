output diffs, glob matcher
==========================


setup::

  $ cat > testfile <<\EOF
  >   $ printf "%s\n" a b c
  >   a (glob)
  >   d (glob)
  >   c (glob)
  > EOF


test::

  $ dram testfile
  !
  --- testfile
  +++ testfile
  @@ -1,4 +1,4 @@
     $ printf "%s\n" a b c
     a (glob)
  -  d (glob)
  +  b
     c (glob)
  
  tests: 1, skipped: 0, failed: 1
  [1]


setup::

  $ cat > testfile <<\EOF
  >   $ printf "%s\n" a b
  >   a (glob)
  >   b (glob)
  >   c (glob)
  > EOF


test::

  $ dram testfile
  !
  --- testfile
  +++ testfile
  @@ -1,4 +1,3 @@
     $ printf "%s\n" a b
     a (glob)
     b (glob)
  -  c (glob)
  
  tests: 1, skipped: 0, failed: 1
  [1]


setup::

  $ cat > testfile <<\EOF
  >   $ printf "%s\n" a b
  >   b (glob)
  > EOF


test::

  $ dram testfile
  !
  --- testfile
  +++ testfile
  @@ -1,2 +1,3 @@
     $ printf "%s\n" a b
  +  a
     b (glob)
  
  tests: 1, skipped: 0, failed: 1
  [1]


setup::

  $ cat > testfile <<\EOF
  >   $ printf "%s\n" b c
  >   X (glob)
  >   b (glob)
  >   c (glob)
  > EOF


test::

  $ dram testfile
  !
  --- testfile
  +++ testfile
  @@ -1,4 +1,3 @@
     $ printf "%s\n" b c
  -  X (glob)
     b (glob)
     c (glob)
  
  tests: 1, skipped: 0, failed: 1
  [1]


setup::

  $ cat > testfile <<\EOF
  >   $ printf "%s\n" X b c
  >   b (glob)
  >   c (glob)
  > EOF


test::

  $ dram testfile
  !
  --- testfile
  +++ testfile
  @@ -1,3 +1,4 @@
     $ printf "%s\n" X b c
  +  X
     b (glob)
     c (glob)
  
  tests: 1, skipped: 0, failed: 1
  [1]
