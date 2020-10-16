`DRAM_TEST_SUFFIX=.foo dram` runs `*.foo` files
===============================================


setup::

  $ for t in a b c; do
  >   touch $t.foo $t.t
  > done


test::

  $ DRAM_TEST_SUFFIX=.foo dram -v .
  . a.foo
  . b.foo
  . c.foo
  
  tests: 3, skipped: 0, failed: 0
