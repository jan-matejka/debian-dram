`dram -t .foo` sets `DRAM_TEST_SUFFIX=.foo`
===========================================


setup::

  $ . $TESTROOT/Fake.dram.bin


test::

  $ dram -t .foo .
  DRAM_TEST_SUFFIX=.foo
