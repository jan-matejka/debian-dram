`DRAM_NODIFFS=[1Yy] dram` inhibits printing of diffs
====================================================


setup::

  $ cat > testfile <<\EOF
  >   $ echo hello
  >   goodbye
  > EOF


test::

  $ DRAM_NODIFFS=1 dram testfile
  !
  
  tests: 1, skipped: 0, failed: 1
  [1]


test::

  $ DRAM_NODIFFS=y dram testfile
  !
  
  tests: 1, skipped: 0, failed: 1
  [1]


test::

  $ DRAM_NODIFFS=Y dram testfile
  !
  
  tests: 1, skipped: 0, failed: 1
  [1]


test::

  $ DRAM_NODIFFS=x dram testfile
  !
  --- testfile
  +++ testfile
  @@ -1,2 +1,2 @@
     $ echo hello
  -  goodbye
  +  hello
  
  tests: 1, skipped: 0, failed: 1
  [1]


test::

  $ DRAM_NODIFFS= dram testfile
  !
  --- testfile
  +++ testfile
  @@ -1,2 +1,2 @@
     $ echo hello
  -  goodbye
  +  hello
  
  tests: 1, skipped: 0, failed: 1
  [1]
