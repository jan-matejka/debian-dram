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
  Not an executable file: */snafubar (glob)
  Failed to patch 1.t from *#1.t/diff (glob)
  --- 2.t
  +++ 2.t
  @@ -1,2 +1,2 @@
     $ echo X
  -  Y
  +  X
  Not an executable file: */snafubar (glob)
  Failed to patch 2.t from *#2.t/diff (glob)
  
  # Ran 2 tests, 2 failed.
  [2]
