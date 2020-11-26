verbose report
==============

`dram -v` prints a result line for each test,
then diffs for all failed tests, then the
summary line.


setup::

  $ mkdir a b x
  $ printf -->1.t '  $ false\n'
  $ printf -->a/2.t '  $ false\n'
  $ printf -->a/3.t '  $ true\n'
  $ printf -->a/4.t '  $ true\n'
  $ printf -->b/5.t '  $ exit 80\n'
  $ printf -->b/6.t '  $ false\n'
  $ printf -->b/7.t '  $ true\n'


test::

  $ cd x
  $ dram -v ..
  ! ../1.t
  ! ../a/2.t
  . ../a/3.t
  . ../a/4.t
  s ../b/5.t
  ! ../b/6.t
  . ../b/7.t
  --- ../1.t
  +++ ../1.t
  @@ -1 +1,2 @@
     $ false
  +  [1]
  --- ../a/2.t
  +++ ../a/2.t
  @@ -1 +1,2 @@
     $ false
  +  [1]
  --- ../b/6.t
  +++ ../b/6.t
  @@ -1 +1,2 @@
     $ false
  +  [1]
  
  # Ran 7 tests, 1 skipped, 3 failed.
  [2]
