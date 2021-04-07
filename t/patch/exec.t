`DRAM_PATCH=badvalue dram` produces a diagnostic, exits !0
==========================================================


setup::

  $ cat >1.t <<\EOF
  >   $ echo X
  >   Y
  > EOF

  $ cp 1.t 2.t


test::

  $ DRAM_PATCH=$PWD/snafubar dram -u *.t
  !!
  --- 1.t
  +++ 1.t
  @@ -1,2 +1,2 @@
     $ echo X
  -  Y
  +  X
  Failed to execute '*/snafubar' (No such file or directory) (glob)
  [8]
