`DRAM_KEEP_TMPDIR=[1Yy] dram` leaves behind working files
=========================================================

the path is printed as the last line of dram's output

setup::

  $ cat > success <<TEST
  >   $ echo fubar
  >   fubar
  > TEST

  $ cat > failure <<TEST
  >   $ echo rofl
  >   lmao
  > TEST


test::

  $ T=$(DRAM_KEEP_TMPDIR=1 dram -D success failure | sed -n '$s/^preserved //p')
  $ d=${T#$TMPDIR/}
  $ echo ${d%-*}
  dramtests

  $ ls $T$PWD
  failure
  success

  $ find $T$PWD -mindepth 2 | sort | sed "s:^$T$PWD/::"
  failure/diff
  failure/out
  failure/result
  failure/script
  failure/tmp
  failure/work
  success/diff
  success/out
  success/result
  success/script
  success/tmp
  success/work

  $ rm -r $T$PWD/failure $T$PWD/success

  $ mkdir x

  $ T=$(cd x; DRAM_KEEP_TMPDIR=1 dram -D ../success ../failure | sed -n '$s/^preserved //p')

  $ ls $T$PWD
  failure
  success

  $ find $T$PWD -mindepth 2 | sort | sed "s:^$T$PWD/::"
  failure/diff
  failure/out
  failure/result
  failure/script
  failure/tmp
  failure/work
  success/diff
  success/out
  success/result
  success/script
  success/tmp
  success/work
