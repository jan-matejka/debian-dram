`dram -t .foo` runs `*.foo` files
=================================


setup::

  $ for t in a b c; do
  >   touch $t.foo $t.t
  > done


test::

  $ dram -vt .foo .
  . a.foo
  . b.foo
  . c.foo
  
  # Ran 3 tests.
