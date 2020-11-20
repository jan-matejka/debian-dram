`dram -h` prints short help
===========================


test::

  $ dram -h
  Usage: dram [OPTIONS] TEST...
  
  Options:
    -h            show this help and exit
    -V            show version information and exit
  
    -D            do not print diffs
    -E            preserve existing environment variables
    -I INDENT     number of spaces used for test code indentation (default: 2)
    -T            leave behind temporary files
    -U            do not merge actual output into tests
    -e VAR[=VAL]  run tests with VAR in environment
    -f            abort after first failed test
    -i            interactively merge actual output into tests
    -s SHELL      shell to use for running tests (default: sh)
    -t SUFFIX     extension of testfiles (default: .t)
    -u            merge actual output into tests
    -v            show filenames and test statuses
