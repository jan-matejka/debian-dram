`dram -i` with a failing test, given "y"
========================================

when actual test results differ from expectations, `dram` should
produce on standard output a unified diff between expected
and actual results, and ask whether it should patch the original
test file with the actual results.  when this is accepted by the
user, the testfile should be updated.

the exit code should be zero.


setup::

  $ cat > t1 <<\EOF
  >   $ echo hello
  >   goodbye
  > EOF


test::

  $ yes y | dram -i t1
  !
  --- t1
  +++ t1
  @@ -1,2 +1,2 @@
     $ echo hello
  -  goodbye
  +  hello
  t1 failed. Apply results? [Y/n]
  
  tests: 1, skipped: 0, failed: 1
  [1]


postconditions::

  $ cat t1
    $ echo hello
    hello
