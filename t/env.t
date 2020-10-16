environment variables
=====================

`dram` sanitizes the environment in which the tests.


setup::

  $ cat > testfile <<\EOF
  >   $ env | sort
  >   COLUMNS=80
  >   LANG=C
  >   LC_ALL=C
  >   LINES=20
  >   PATH=* (glob)
  >   PWD=* (glob)
  >   TESTDIR=/*#env.t/work (glob)
  >   TESTFILE=testfile
  >   TMPDIR=/*#env.t#work#testfile/tmp (glob)
  >   TZ=UTC
  > EOF


test::

  $ dram testfile
  .
  
  tests: 1, skipped: 0, failed: 0
