`dram -s badvalue` produces a diagnostic, exits !0
==================================================


setup::

  $ cat >1.t <<\EOF
  >   $ echo wut
  >   wut
  > EOF

  $ cp 1.t 2.t
  $ cp 1.t 3.t


test::

  $ dram -s $PWD/snafubar *.t
  Failed to execute '*/snafubar' (No such file or directory) (glob)
  [8]
