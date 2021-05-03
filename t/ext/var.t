`DRAM_TEST_SUFFIX=.foo` runs `*.foo` files
==========================================


setup::

  $ for t in a b c; do
  >   touch $t.foo $t.t
  > done


test::

  $ DRAM_TEST_SUFFIX=.foo dram -v .
  . a.foo
  . b.foo
  . c.foo
  
  # Ran 3 tests.
