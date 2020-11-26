`dram FILE...` runs each FILE
=============================


setup::

  $ for x in a b c; do printf -->$x '  $ true\n'; done


test::

  $ dram *
  ...
  
  # Ran 3 tests.
