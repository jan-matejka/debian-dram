`DRAM_FAIL_FAST=[1Yy]` exits after the first failed test
========================================================

setup::

  $ for x in a b d e; do
  >   printf -->$x '  $ true\n'
  > done

  $ printf -->c '  $ false\n'


test::

  $ DRAM_FAIL_FAST=1 dram -D a b c d e
  ..!ss
  
  # Ran 5 tests, 2 skipped, 1 failed.
  [2]

  $ DRAM_FAIL_FAST=Y dram -D a b c d e
  ..!ss
  
  # Ran 5 tests, 2 skipped, 1 failed.
  [2]

  $ DRAM_FAIL_FAST=y dram -D a b c d e
  ..!ss
  
  # Ran 5 tests, 2 skipped, 1 failed.
  [2]


test::

  $ DRAM_FAIL_FAST=1 dram -Dv a b c d e
  . a
  . b
  ! c
  s d
  s e
  
  # Ran 5 tests, 2 skipped, 1 failed.
  [2]

  $ DRAM_FAIL_FAST=Y dram -Dv a b c d e
  . a
  . b
  ! c
  s d
  s e
  
  # Ran 5 tests, 2 skipped, 1 failed.
  [2]

  $ DRAM_FAIL_FAST=y dram -Dv a b c d e
  . a
  . b
  ! c
  s d
  s e
  
  # Ran 5 tests, 2 skipped, 1 failed.
  [2]
