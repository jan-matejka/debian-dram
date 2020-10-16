handling of outputs without trainling newlines
==============================================


setup::

  $ cat > testfile <<\EOF
  >   $ printf "hello\n"; (exit 42)
  >   hello (no-eol)
  >   [42]
  > EOF


test::

  $ dram testfile
  !
  --- testfile
  +++ testfile
  @@ -1,3 +1,3 @@
     $ printf "hello\n"; (exit 42)
  -  hello (no-eol)
  +  hello
     [42]
  
  tests: 1, skipped: 0, failed: 1
  [1]


setup::

  $ cat > testfile <<\EOF
  >   $ printf hello; (exit 42)
  >   hello
  >   [42]
  > EOF


test::

  $ dram testfile
  !
  --- testfile
  +++ testfile
  @@ -1,3 +1,3 @@
     $ printf hello; (exit 42)
  -  hello
  +  hello (no-eol)
     [42]
  
  tests: 1, skipped: 0, failed: 1
  [1]
