glob matcher, missing line of output at the beginning
=====================================================

this is one area where Dram improves on Cram;
the latter produces this diff given the same testfile::

   @@ -1,4 +1,3 @@
      $ printf "%s\n" b c
   -  X (glob)
   -  b (glob)
   -  c (glob)
   +  b
   +  c



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
  
  # Ran 1 test, 1 failed.
  [2]
