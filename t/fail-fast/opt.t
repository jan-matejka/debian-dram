`dram -b` exits after the first failed test
===========================================

setup::

  $ for x in a b d e; do
  >   printf -->$x '  $ true\n'
  > done

  $ printf -->c '  $ false\n'


test::

  $ dram -Dfv a b c d e
  . a
  . b
  ! c
  
  tests: 5, skipped: 2, failed: 1
  [1]
