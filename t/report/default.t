default report
==============

first, all test results on a single line, with each
test result encoded as a single character:
`"."` for successful tests, `"!"` for failed ones,
`"s"` for skipped ones.  then diffs for all failed
tests, then the summary line.


setup::

  $ printf -->1.t '  $ false\n'
  $ printf -->2.t '  $ exit 1\n'
  $ printf -->3.t '  $ true\n'
  $ printf -->4.t '  $ exit 12\n'
  $ printf -->5.t '  $ exit 80\n'
  $ printf -->6.t '  $ false\n'
  $ printf -->7.t '  $ true\n'


test::

  $ dram .
  !X.Xs!.
  --- 1.t
  +++ 1.t
  @@ -1 +1,2 @@
     $ false
  +  [1]
  --- 6.t
  +++ 6.t
  @@ -1 +1,2 @@
     $ false
  +  [1]
  
  # Ran 7 tests, 1 skipped, 2 failed, 2 broke.
  [6]
