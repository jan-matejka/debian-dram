re matcher, extra line of output at the beginning
=================================================

this is one area where Dram improves on Cram;
the latter produces this diff given the same testfile::

   @@ -1,3 +1,4 @@
      $ printf "%s\n" X b c
   -  b (re)
   -  c (re)
   +  X
   +  b
   +  c


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
