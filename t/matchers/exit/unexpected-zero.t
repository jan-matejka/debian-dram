expecting !0, geting 0
======================

setup::

  $ cat > testfile <<\EOF
  >   $ true
  >   [11]
  > EOF


test::

  $ dram testfile
  !
  --- testfile
  +++ testfile
  @@ -1,2 +1 @@
     $ true
  -  [11]
  
  # Ran 1 test, 1 failed.
  [2]
