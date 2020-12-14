`dram -e X` passes X into script environ
========================================

setup::

  $ cat >testfile <<\EOF
  >   $ env | sort
  >   COLUMNS=80
  >   LANG=C
  >   LC_ALL=C
  >   LINES=20
  >   LOL=foo  bar\nbaz
  >   PATH=* (glob)
  >   PWD=* (glob)
  >   ROFL=omg wtf
  >   TESTDIR=/*/var.t/work (glob)
  >   TESTFILE=testfile
  >   TMPDIR=/*/var.t/work/testfile/tmp (glob)
  >   TZ=UTC
  > EOF


test::

  $ export LOL="$(printf "%s" "foo  bar\nbaz")" ROFL="omg wtf"
  $ DRAM_ENV="LOL ROFL" dram testfile
  .
  
  # Ran 1 test.


test::

  $ unset LOL
  $ DRAM_ENV="LOL ROFL" dram testfile
  !
  --- testfile
  +++ testfile
  @@ -3,7 +3,6 @@
     LANG=C
     LC_ALL=C
     LINES=20
  -  LOL=foo  bar\nbaz
     PATH=* (glob)
     PWD=* (glob)
     ROFL=omg wtf
  
  # Ran 1 test, 1 failed.
  [2]
