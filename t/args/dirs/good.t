`dram DIR...` with each `DIR` containing several tests
======================================================


setup::

  $ for d in a b; do
  >   mkdir $d
  >   for i in 1 2 3; do
  >     printf -->$d/$i.t '  $ true\n'
  >   done
  > done


test::

  $ dram a b
  ......
  
  tests: 6, skipped: 0, failed: 0
