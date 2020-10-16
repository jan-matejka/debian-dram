`dram FILE...` runs each FILE
=============================


setup::

  $ for x in a b c; do printf -->$x '  $ true\n'; done


test::

  $ dram *
  ...
  
  tests: 3, skipped: 0, failed: 0
