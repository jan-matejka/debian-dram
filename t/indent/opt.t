`dram -I X` behavior
====================

setup::

  $ cat > testfile <<\EOF
  >   $ not-a-test
  >   > not-an-output
  >   [0] not an exit code
  >     $ echo hello
  >     goodbye
  >     [1]
  >       $ not-a-test
  >       > not-an-output
  >       [0] not an exit code
  > EOF


test::

  $ dram -I 4 testfile
  !
  --- testfile
  +++ testfile
  @@ -2,8 +2,7 @@
     > not-an-output
     [0] not an exit code
       $ echo hello
  -    goodbye
  -    [1]
  +    hello
         $ not-a-test
         > not-an-output
         [0] not an exit code
  
  tests: 1, skipped: 0, failed: 1
  [1]
