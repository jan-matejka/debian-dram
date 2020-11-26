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
  >   TESTDIR=/*#opt.t/work (glob)
  >   TESTFILE=testfile
  >   TMPDIR=/*#opt.t#work#testfile/tmp (glob)
  >   TZ=UTC
  > EOF


test::

  $ export LOL="$(printf "%s" "foo  bar\nbaz")"
  $ dram -e LOL -e ROFL="omg wtf" testfile
  .
  
  # Ran 1 test.


test::

  $ unset LOL
  $ dram -e LOL -e ROFL="omg wtf" testfile
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
