`dram -e X` adds `X` to `DRAM_ENV`, passes `X` into script environ
==================================================================

setup::

  $ cat > "$TMPDIR/snafubar" <<\EOF
  > #!/bin/sh
  > env | grep '^DRAM_' | grep -v '^DRAM_BIN=' | sort
  > echo "LOL='$LOL'"
  > echo "ROFL='$ROFL'"
  > EOF

  $ chmod +x "$TMPDIR/snafubar"
  $ export DRAM_BIN="$TMPDIR/snafubar"


test::

  $ export LOL="$(printf "%s\n" "foo  bar" "baz")"
  $ dram -e LOL -e ROFL="omg wtf" .
  DRAM_ENV=LOL ROFL
  LOL='foo  bar
  baz'
  ROFL='omg wtf'


test::

  $ unset LOL
  $ dram -e LOL -e ROFL="omg wtf" .
  DRAM_ENV=LOL ROFL
  LOL=''
  ROFL='omg wtf'
