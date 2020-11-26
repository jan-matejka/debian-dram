`dram DIR...` recurses each DIR
===============================


setup::

  $ for d in a/t b/t; do
  >   mkdir -p $d
  >   for i in 1 2 3; do
  >     printf -->$d/$i.t '  $ true\n'
  >   done
  > done


test::

  $ dram a b
  ......
  
  # Ran 6 tests.
