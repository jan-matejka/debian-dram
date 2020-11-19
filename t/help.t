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
    -e VAR[=VAL]  run tests with VAR in environment
    -f            abort after first failed test
    -i            interactively merge changed test output
    -n            answer no to all questions
    -s SHELL      shell to use for running tests (default: sh)
    -t SUFFIX     extension of testfiles (default: .t)
    -v            show filenames and test statuses
    -y            answer yes to all questions
