glob matcher, extra line of output at the beginning
===================================================

this is one area where Dram improves on Cram;
the latter produces this diff given the same testfile::

   @@ -1,3 +1,4 @@
      $ printf "%s\n" X b c
   -  b (glob)
   -  c (glob)
   +  X
   +  b
   +  c


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
  
  # Ran 1 test, 1 failed.
  [2]
