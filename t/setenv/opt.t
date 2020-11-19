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
  
  tests: 1, skipped: 0, failed: 0


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
  
  tests: 1, skipped: 0, failed: 1
  [1]
