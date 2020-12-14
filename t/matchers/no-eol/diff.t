handling of outputs without trainling newlines
==============================================


setup::

  $ cat > testfile-0 <<\EOF
  >   $ printf "hello\n"; (exit 42)
  >   hello (no-eol)
  >   [42]
  > EOF


test::

  $ dram testfile-0
  !
  --- testfile-0
  +++ testfile-0
  @@ -1,3 +1,3 @@
     $ printf "hello\n"; (exit 42)
  -  hello (no-eol)
  +  hello
     [42]
  
  # Ran 1 test, 1 failed.
  [2]


setup::

  $ cat > testfile-1 <<\EOF
  >   $ printf hello; (exit 42)
  >   hello
  >   [42]
  > EOF


test::

  $ dram testfile-1
  !
  --- testfile-1
  +++ testfile-1
  @@ -1,3 +1,3 @@
     $ printf hello; (exit 42)
  -  hello
  +  hello (no-eol)
     [42]
  
  # Ran 1 test, 1 failed.
  [2]
