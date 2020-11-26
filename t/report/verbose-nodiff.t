`dram DIR` with mixed results
=============================


setup::

  $ printf -->1.t '  $ false\n'
  $ printf -->2.t '  $ false\n'
  $ printf -->3.t '  $ true\n'
  $ printf -->4.t '  $ true\n'
  $ printf -->5.t '  $ exit 80\n'
  $ printf -->6.t '  $ false\n'
  $ printf -->7.t '  $ true\n'


test::

  $ dram -Dv .
  ! 1.t
  ! 2.t
  . 3.t
  . 4.t
  s 5.t
  ! 6.t
  . 7.t
  
  # Ran 7 tests, 1 skipped, 3 failed.
  [2]
