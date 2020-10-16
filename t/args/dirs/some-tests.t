`dram DIR` with `DIR` containing tests and other files
======================================================


setup::

  $ for i in 1 2 3; do
  >   printf -->$i.t   '  $ true\n'
  >   printf -->$i.txt '  $ false\n'
  > done


test::

  $ dram .
  ...
  
  tests: 3, skipped: 0, failed: 0
