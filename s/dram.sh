#!/bin/sh
#
# vim: et sts=2 fdm=marker cms=\ #\ %s
#
# Copyright (C) 2020  Roman Neuhauser
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

VERSION=0.8

usage() # {{{
{
  printf -->&$(expr 1 + ${1-1}) \
    "Usage: %s [OPTIONS] TEST...\n" "${0##*/}"

  test ${1-0} -eq 0 || exit $1

  cat <<HELP

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
HELP
  exit ${1-$?}
} # }}}

version() # {{{
{
  cat <<VERSION
Dram: functional tests for the CLI, version $VERSION
VERSION
  exit
} # }}}

while getopts :hVDEI:TUe:fij:s:t:uv opt "$@"; do
  case $opt in
  h) usage 0 ;;
  V) version ;;
  D) export DRAM_NODIFFS=1 ;;
  E) export DRAM_KEEP_ENVIRON=1 ;;
  I)
    case "$OPTARG" in
    *[!0123456789]*)
      printf -->&2 "%s: '-I' requires integer argument\n" "${0##*/}"
      exit 1
    ;;
    *)
      export DRAM_INDENT="$(printf "%*s" "$OPTARG" " ")"
    ;;
    esac
  ;;
  T) export DRAM_KEEP_TMPDIR=1 ;;
  U) export DRAM_UPDATE=0 ;;
  e)
    export "$OPTARG"
    DRAM_ENV="$DRAM_ENV ${OPTARG%%=*}"
    export DRAM_ENV="${DRAM_ENV# }"
  ;;
  f) export DRAM_FAIL_FAST=1 ;;
  i) export DRAM_UPDATE=ask ;;
  j) export DRAM_JUNIT_FILE="$OPTARG" ;;
  s) export DRAM_SHELL="$OPTARG" ;;
  t) export DRAM_TEST_SUFFIX="$OPTARG" ;;
  u) export DRAM_UPDATE=1 ;;
  v) export DRAM_VERBOSE=1 ;;
  \?)
    printf -->&2 "%s: uknown option '-%s'\n" "${0##*/}" "$OPTARG"
    exit 1
  ;;
  esac
done; shift $(expr $OPTIND - 1)

test $# -gt 0 || usage 1
exec ${DRAM_BIN-${0%/*}/dram.bin} "$@"
