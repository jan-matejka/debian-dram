`dram -i` with a failing test, given "n"
========================================

when actual test results differ from expectations, `dram` should
produce on standard output a unified diff between expected
and actual results, and ask whether it should patch the original
test file with the actual results.  when this is rejected by the
user, the testfile should remain untouched.

the exit code should be non-zero.


setup::

  $ cat > t1 <<\EOF
  >   $ echo hello
  >   goodbye
  > EOF


test::

  $ yes n | dram -i t1
  !
  --- t1
  +++ t1
  @@ -1,2 +1,2 @@
     $ echo hello
  -  goodbye
  +  hello
  t1 failed. Apply results? [Y/n]
  
  # Ran 1 test, 1 failed.
  [2]


postconditions::

  $ cat t1
    $ echo hello
    goodbye
