`DRAM_KEEP_TMPDIR=[1Yy]` leaves behind working files
====================================================

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

  $ mkdir x


test::

  $ T=$(cd x; dram ../success ../failure | sed -n '$s/^preserved //p')

  $ test "x$T" = "x"

  $ ls -A "$TMPDIR"


test::

  $ T=$(cd x; DRAM_KEEP_TMPDIR=x dram ../success ../failure | sed -n '$s/^preserved //p')

  $ test "x$T" = "x"

  $ ls -A "$TMPDIR"


test::

  $ T=$(cd x; DRAM_KEEP_TMPDIR=1 dram ../success ../failure | sed -n '$s/^preserved //p')

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


test::

  $ T=$(cd x; DRAM_KEEP_TMPDIR=Y dram ../success ../failure | sed -n '$s/^preserved //p')

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


test::

  $ T=$(cd x; DRAM_KEEP_TMPDIR=y dram ../success ../failure | sed -n '$s/^preserved //p')

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
