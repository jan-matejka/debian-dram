`dram -I X` sets `DRAM_INDENT` to `X` spaces
============================================

setup::

  $ cat > "$TMPDIR/snafubar" <<\EOF
  > #!/bin/sh
  > env | grep '^DRAM_' | grep -ve '^DRAM_BIN=' -e '^DRAM_INDENT=' | sort
  > echo DRAM_INDENT="'$DRAM_INDENT'"
  > EOF

  $ chmod +x "$TMPDIR/snafubar"
  $ export DRAM_BIN="$TMPDIR/snafubar"


test::

  $ dram -I 4 testfile
  DRAM_INDENT='    '
