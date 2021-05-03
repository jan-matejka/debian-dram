`dram -E` sets `DRAM_KEEP_ENVIRON=1`
====================================


setup::

  $ . $TESTROOT/Fake.dram.bin


test::

  $ dram -E testfile
  DRAM_KEEP_ENVIRON=1
