`DRAM_DIFF=badvalue dram` produces a diagnostic, exits 8
========================================================


setup::

  $ cat >1.t <<\EOF
  >   $ echo X
  >   Y
  > EOF

  $ cp 1.t 2.t


test::

  $ DRAM_DIFF=$PWD/snafubar dram *.t
  Failed to execute '*/snafubar' (No such file or directory) (glob)
  [8]
