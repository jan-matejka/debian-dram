`DRAM_DIFF=x dram` uses `x` to diff files
=========================================

setup::

  $ cat >1.t <<\EOF
  >   $ echo X
  >   Y
  > EOF

  $ mkdir bin
  $ cat >bin/mydiff <<\EOF
  > #!/bin/sh
  > echo diffing...
  > diff "$@"
  > EOF
  $ chmod +x bin/mydiff


test::

  $ DRAM_DIFF=$PWD/bin/mydiff dram *.t
  !
  diffing...
  --- 1.t
  +++ 1.t
  @@ -1,2 +1,2 @@
     $ echo X
  -  Y
  +  X
  
  # Ran 1 test, 1 failed.
  [2]
