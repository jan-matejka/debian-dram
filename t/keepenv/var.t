`DRAM_KEEP_ENVIRON=[1Yy]` preserves environment variables
=========================================================


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
  >   TESTDIR=/*/var.t/work (glob)
  >   TESTFILE=testfile
  >   TZ=UTC
  > EOF


test::

  $ SNAFUBAR=roflmao COLUMNS=120 LINES=25 DRAM_KEEP_ENVIRON=1 dram testfile
  .
  
  # Ran 1 test.


test::

  $ SNAFUBAR=roflmao COLUMNS=120 LINES=25 DRAM_KEEP_ENVIRON=Y dram testfile
  .
  
  # Ran 1 test.


test::

  $ SNAFUBAR=roflmao COLUMNS=120 LINES=25 DRAM_KEEP_ENVIRON=y dram testfile
  .
  
  # Ran 1 test.


test::

  $ SNAFUBAR=roflmao COLUMNS=120 LINES=25 DRAM_KEEP_ENVIRON=x dram testfile
  !
  --- testfile
  +++ testfile
  @@ -1,13 +1,12 @@
     $ env | sort | grep -w -e COLUMNS -e LANG -e LC_ALL \
     >                      -e LINES -e PATH -e PWD -e SNAFUBAR \
     >                      -e TESTDIR -e TESTFILE -e TZ
  -  COLUMNS=120
  +  COLUMNS=80
     LANG=C
     LC_ALL=C
  -  LINES=25
  +  LINES=20
     PATH=* (glob)
     PWD=* (glob)
  -  SNAFUBAR=roflmao
     TESTDIR=/*/var.t/work (glob)
     TESTFILE=testfile
     TZ=UTC
  
  # Ran 1 test, 1 failed.
  [2]


test::

  $ SNAFUBAR=roflmao COLUMNS=120 LINES=25 DRAM_KEEP_ENVIRON= dram testfile
  !
  --- testfile
  +++ testfile
  @@ -1,13 +1,12 @@
     $ env | sort | grep -w -e COLUMNS -e LANG -e LC_ALL \
     >                      -e LINES -e PATH -e PWD -e SNAFUBAR \
     >                      -e TESTDIR -e TESTFILE -e TZ
  -  COLUMNS=120
  +  COLUMNS=80
     LANG=C
     LC_ALL=C
  -  LINES=25
  +  LINES=20
     PATH=* (glob)
     PWD=* (glob)
  -  SNAFUBAR=roflmao
     TESTDIR=/*/var.t/work (glob)
     TESTFILE=testfile
     TZ=UTC
  
  # Ran 1 test, 1 failed.
  [2]
