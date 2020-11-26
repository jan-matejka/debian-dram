`dram -E` preserves environment variables
=========================================


setup::

  $ cat > testfile <<\EOF
  >   $ env | sort | grep -w -e COLUMNS -e LANG -e LC_ALL \
  >   >                      -e LINES -e PATH -e PWD -e SNAFUBAR \
  >   >                      -e TESTDIR -e TESTFILE -e TZ
  >   COLUMNS=120
  >   LANG=C
  >   LC_ALL=C
  >   LINES=25
  >   PATH=* (glob)
  >   PWD=* (glob)
  >   SNAFUBAR=roflmao
  >   TESTDIR=/*#opt.t/work (glob)
  >   TESTFILE=testfile
  >   TZ=UTC
  > EOF


test::

  $ SNAFUBAR=roflmao COLUMNS=120 LINES=25 dram -E testfile
  .
  
  # Ran 1 test.
