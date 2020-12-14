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
  >   TESTDIR=/*/default.t/work (glob)
  >   TESTFILE=testfile
  >   TMPDIR=/*/default.t/work/testfile/tmp (glob)
  >   TZ=UTC
  > EOF


test::

  $ COLUMNS=120 LINES=25 dram testfile
  .
  
  # Ran 1 test.
