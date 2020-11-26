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

  $ DRAM_SHELL=wtf dram testfile
  .
  
  # Ran 1 test.
