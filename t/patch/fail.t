`DRAM_PATCH=badvalue dram` produces a diagnostic, exits 8
=========================================================


setup::

  $ cat >1.t <<\EOF
  >   $ echo X
  >   Y
  > EOF

  $ cp 1.t 2.t

  $ cat >snafubar <<\EOF
  > #!/bin/sh
  > echo >&2 'stderr from "patch"'
  > exit 1
  > EOF

  $ chmod +x snafubar

test::

  $ DRAM_PATCH=$PWD/snafubar dram -u *.t
  !!
  --- 1.t
  +++ 1.t
  @@ -1,2 +1,2 @@
     $ echo X
  -  Y
  +  X
  stderr from "patch"
  Failed command: '*/snafubar' '-s' '1.t' '*/1.t/diff' (glob)
  [8]
