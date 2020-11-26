handling of outputs without trainling newlines
==============================================


setup::

  $ cat > testfile-0 <<\EOF
  >   $ printf hello
  >   hello (no-eol)
  >   $ (exit 42)
  >   [42]
  > EOF


test::

  $ dram testfile-0
  .
  
  # Ran 1 test.


setup::

  $ cat > testfile-1 <<\EOF
  >   $ printf hello; (exit 42)
  >   hello (no-eol)
  >   [42]
  > EOF


test::

  $ dram testfile-1
  .
  
  # Ran 1 test.
