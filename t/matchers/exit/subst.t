expecting !0, geting other !0
=============================

setup::

  $ cat > testfile <<\EOF
  >   $ (exit 42)
  >   [69]
  > EOF


test::

  $ dram testfile
  !
  --- testfile
  +++ testfile
  @@ -1,2 +1,2 @@
     $ (exit 42)
  -  [69]
  +  [42]
  
  tests: 1, skipped: 0, failed: 1
  [1]
