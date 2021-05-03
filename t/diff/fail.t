`DRAM_DIFF=badvalue dram` produces a diagnostic, exits 8
========================================================


setup::

  $ cat >1.t <<\EOF
  >   $ echo X
  >   Y
  > EOF

  $ cp 1.t 2.t

  $ cat >snafubar <<\EOF
  > #!/bin/sh
  > echo >&2 'stderr from "diff"'
  > exit 2
  > EOF

  $ chmod +x snafubar


test::

  $ DRAM_DIFF=$PWD/snafubar dram *.t
  stderr from "diff"
  Failed command: '*/snafubar' '-u' '--label' '1.t' '--label' '1.t' '1.t' '*/1.t/result' (glob)
  [8]
