`DRAM_SHELL=x dram` runs tests through `x`
==========================================


setup::

  $ mkdir bin
  $ cat >bin/wtf <<\EOF
  > #!/bin/sh
  > lol()
  > {
  >   echo wut
  > }
  > . "$@"
  > EOF
  $ chmod +x bin/wtf
  $ export PATH="$PWD/bin:$PATH"

  $ cat >testfile <<\EOF
  >   $ lol
  >   wut
  > EOF


test::

  $ dram -s wtf testfile
  .
  
  tests: 1, skipped: 0, failed: 0
