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

  $ ls $T
  *#failure (glob)
  *#success (glob)

  $ find $T -mindepth 2 | sort | sed "s:^$T/::"
  *t#keeptmp#var.t#work#failure/diff (glob)
  *t#keeptmp#var.t#work#failure/out (glob)
  *t#keeptmp#var.t#work#failure/result (glob)
  *t#keeptmp#var.t#work#failure/script (glob)
  *t#keeptmp#var.t#work#failure/tmp (glob)
  *t#keeptmp#var.t#work#failure/work (glob)
  *t#keeptmp#var.t#work#success/diff (glob)
  *t#keeptmp#var.t#work#success/out (glob)
  *t#keeptmp#var.t#work#success/result (glob)
  *t#keeptmp#var.t#work#success/script (glob)
  *t#keeptmp#var.t#work#success/tmp (glob)
  *t#keeptmp#var.t#work#success/work (glob)

  $ mkdir x
  $ cd x

  $ T=$(DRAM_KEEP_TMPDIR=1 dram -D ../success ../failure | sed -n '$s/^preserved //p')

  $ ls $T
  *#failure (glob)
  *#success (glob)

  $ find $T -mindepth 2 | sort | sed "s:^$T/::"
  *t#keeptmp#var.t#work#failure/diff (glob)
  *t#keeptmp#var.t#work#failure/out (glob)
  *t#keeptmp#var.t#work#failure/result (glob)
  *t#keeptmp#var.t#work#failure/script (glob)
  *t#keeptmp#var.t#work#failure/tmp (glob)
  *t#keeptmp#var.t#work#failure/work (glob)
  *t#keeptmp#var.t#work#success/diff (glob)
  *t#keeptmp#var.t#work#success/out (glob)
  *t#keeptmp#var.t#work#success/result (glob)
  *t#keeptmp#var.t#work#success/script (glob)
  *t#keeptmp#var.t#work#success/tmp (glob)
  *t#keeptmp#var.t#work#success/work (glob)
