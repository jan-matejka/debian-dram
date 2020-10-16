output diffs, glob matcher
==========================


setup::

  $ cat > testfile <<\EOF
  >   $ printf "%s\n" a b c
  >   a (re)
  >   d (re)
  >   c (re)
  > EOF


test::

  $ dram testfile
  !
  --- testfile
  +++ testfile
  @@ -1,4 +1,4 @@
     $ printf "%s\n" a b c
     a (re)
  -  d (re)
  +  b
     c (re)
  
  tests: 1, skipped: 0, failed: 1
  [1]


setup::

  $ cat > testfile <<\EOF
  >   $ printf "%s\n" a b
  >   a (re)
  >   b (re)
  >   c (re)
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
  -  c (re)
  
  tests: 1, skipped: 0, failed: 1
  [1]


setup::

  $ cat > testfile <<\EOF
  >   $ printf "%s\n" a b
  >   b (re)
  > EOF


test::

  $ dram testfile
  !
  --- testfile
  +++ testfile
  @@ -1,2 +1,3 @@
     $ printf "%s\n" a b
  +  a
     b (re)
  
  tests: 1, skipped: 0, failed: 1
  [1]


setup::

  $ cat > testfile <<\EOF
  >   $ printf "%s\n" b c
  >   X (re)
  >   b (re)
  >   c (re)
  > EOF


test::

  $ dram testfile
  !
  --- testfile
  +++ testfile
  @@ -1,4 +1,3 @@
     $ printf "%s\n" b c
  -  X (re)
     b (re)
     c (re)
  
  tests: 1, skipped: 0, failed: 1
  [1]


setup::

  $ cat > testfile <<\EOF
  >   $ printf "%s\n" X b c
  >   b (re)
  >   c (re)
  > EOF


test::

  $ dram testfile
  !
  --- testfile
  +++ testfile
  @@ -1,3 +1,4 @@
     $ printf "%s\n" X b c
  +  X
     b (re)
     c (re)
  
  tests: 1, skipped: 0, failed: 1
  [1]
