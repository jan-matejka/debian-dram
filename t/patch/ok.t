`DRAM_PATCH=x dram` uses `x` to patch files
===========================================

setup::

  $ cat >1.t <<\EOF
  >   $ echo X
  >   Y
  > EOF

  $ mkdir bin
  $ cat >bin/mypatch <<\EOF
  > #!/bin/sh
  > echo patching...
  > patch "$@"
  > EOF
  $ chmod +x bin/mypatch


test::

  $ DRAM_PATCH=$PWD/bin/mypatch dram -iy *.t
  !
  --- 1.t
  +++ 1.t
  @@ -1,2 +1,2 @@
     $ echo X
  -  Y
  +  X
  patching...
  
  tests: 1, skipped: 0, failed: 1
  [1]
