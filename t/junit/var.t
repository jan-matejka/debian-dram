`DRAM_JUNIT_FILE=pathname dram` writes a JUnit report in pathname
=================================================================

setup::

  $ mkdir t
  $ for x in "a&" "b>" "d<"; do
  >   printf -->"t/$x.t" '  $ true\n'
  > done

  $ printf -->"t/c&<>.t" '  $ false\n'

  $ printf -->"t/e]]>.t" '  $ false\n'

  $ printf -->"t/f.t" '  $ sleep 1\n'

test::

  $ DRAM_JUNIT_FILE=report.xml dram -D t
  ..!.!.
  
  tests: 6, skipped: 0, failed: 2
  [1]

  $ cat report.xml
  <?xml version="1.0" encoding="UTF-8"?>
  <testsuite
    name="dram"
    tests="6"
    failures="2"
    skipped="0"
    timestamp="\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}" (re)
    time="\d+(\.\d+)?"> (re)
    <testcase
      classname="t/a&amp;.t"
      name="a&amp;.t"
      time="\d+(\.\d+)?"/> (re)
    <testcase
      classname="t/b>.t"
      name="b>.t"
      time="\d+(\.\d+)?"/> (re)
    <testcase
      classname="t/c&amp;&lt;>.t"
      name="c&amp;&lt;>.t"
      time="\d+(\.\d+)?"> (re)
      <failure>
  --- t/c&amp;&lt;>.t
  +++ t/c&amp;&lt;>.t
  @@ -1 +1,2 @@
     $ false
  +  [1]
  
      </failure>
    </testcase>
    <testcase
      classname="t/d&lt;.t"
      name="d&lt;.t"
      time="\d+(\.\d+)?"/> (re)
    <testcase
      classname="t/e]]>.t"
      name="e]]>.t"
      time="\d+(\.\d+)?"> (re)
      <failure>
  --- t/e]]&gt;.t
  +++ t/e]]&gt;.t
  @@ -1 +1,2 @@
     $ false
  +  [1]
  
      </failure>
    </testcase>
    <testcase
      classname="t/f.t"
      name="f.t"
      time="\d+(\.\d+)?"/> (re)
  </testsuite>
