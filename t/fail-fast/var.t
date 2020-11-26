`DRAM_FAIL_FAST=[1Yy] dram` exits after the first failed test
=============================================================

setup::

  $ for x in a b d e; do
  >   printf -->$x '  $ true\n'
  > done

  $ printf -->c '  $ false\n'


test::

  $ dram -Df a b c d e
  ..!ss
  
  # Ran 5 tests, 2 skipped, 1 failed.
  [2]


test::

  $ DRAM_FAIL_FAST=1 dram -Dfv a b c d e
  . a
  . b
  ! c
  s d
  s e
  
  # Ran 5 tests, 2 skipped, 1 failed.
  [2]
