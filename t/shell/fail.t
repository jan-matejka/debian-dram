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
  Not an executable file: */snafubar (glob)
  Not an executable file: */snafubar (glob)
  Not an executable file: */snafubar (glob)
  !!!
  
  tests: 3, skipped: 0, failed: 3
  [1]
