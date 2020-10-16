handling of outputs without trainling newlines
==============================================


setup::

  $ cat > testfile <<\EOF
  >   $ printf hello
  >   hello (no-eol)
  >   $ (exit 42)
  >   [42]
  > EOF


test::

  $ dram testfile
  .
  
  tests: 1, skipped: 0, failed: 0


setup::

  $ cat > testfile <<\EOF
  >   $ printf hello; (exit 42)
  >   hello (no-eol)
  >   [42]
  > EOF


test::

  $ dram testfile
  .
  
  tests: 1, skipped: 0, failed: 0
