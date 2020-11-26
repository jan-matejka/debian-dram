expecting 0, geting !0
======================

setup::

  $ cat > testfile <<\EOF
  >   $ (exit 42)
  > EOF


test::

  $ dram testfile
  !
  --- testfile
  +++ testfile
  @@ -1 +1,2 @@
     $ (exit 42)
  +  [42]
  
  # Ran 1 test, 1 failed.
  [2]
