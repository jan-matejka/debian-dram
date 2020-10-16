skipped tests
=============

if the shell script extracted from a testfile exits `80`,
the test is considered "skipped".


setup::

  $ cat > testfile-0 <<\EOF
  >   $ exit 80
  > EOF


test::

  $ dram testfile-0
  s
  
  tests: 1, skipped: 1, failed: 0


not that this does not extend to exit codes from
the code under test!

setup::

  $ cat > testfile-1 <<\EOF
  >   $ (exit 80)
  > EOF


test::

  $ dram testfile-1
  !
  --- testfile-1
  +++ testfile-1
  @@ -1 +1,2 @@
     $ (exit 80)
  +  [80]
  
  tests: 1, skipped: 0, failed: 1
  [1]


test results from the file are ignored.

setup::

  $ cat > testfile-2 <<\EOF
  >   $ echo hello
  >   goodbye
  >   [42]
  >   $ exit 80
  >   $ echo goodbye
  >   hello
  > EOF


test::

  $ dram testfile-2
  s
  
  tests: 1, skipped: 1, failed: 0


  $ dram -v testfile-2
  s testfile-2
  
  tests: 1, skipped: 1, failed: 0
