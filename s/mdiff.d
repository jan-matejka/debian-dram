// vim: et sts=2 fdm=marker cms=\ //\ %s
//
// Copyright (C) 2020  Roman Neuhauser
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

module mdiff;

// imports {{{
import std.algorithm;
import std.conv;
import std.container.array;
import std.file;
import std.functional : equalTo;
import std.path;
import std.range;
import std.stdio;
import std.string;
import std.typecons;
// }}}

struct Line // {{{
{
  size_t lino;
  string text;
} // }}}

struct Edit // {{{
{
  long oldline;
  long newline;
  string text;
} // }}}

auto toLines(string doc) pure // {{{
{
  return doc
    .lineSplitter
    .array
    .toLines
  ;
} // }}}

auto toLines(const string[] doc) pure // {{{
{
  return doc
    .enumerate(1)
    .map!(iln => Line(iln.expand))
    .array
  ;
} // }}}

auto ref at(long[] xs, long i) pure // {{{
{
  return xs[(i < 0) ? xs.length + i : i];
} // }}}

bool eq(string l, string r) // {{{
{
  return l == r;
} // }}}

auto diff(alias eq = eq)(const string lhs, const string rhs) // {{{
{
  return diff!eq(lhs.toLines, rhs.toLines);
} // }}}

auto diff(alias eq = eq)(const string[] lhs, const string[] rhs) // {{{
{
  return diff!eq(lhs.toLines, rhs.toLines);
} // }}}

auto diff(alias eq = eq)(const Array!string lhs, const Array!string rhs) // {{{
{
  return diff!eq(lhs[].array.toLines, rhs[].array.toLines);
} // }}}

auto diff(alias eq = eq)(const Line[] lhs, const Line[] rhs) // {{{
{
  auto toEdit(long x0, long y0, long x1, long y1) // {{{
  {
    return (x1 == x0)
      ? Edit(0, rhs[y0].lino, rhs[y0].text)
      : (y1 == y0)
        ? Edit(lhs[x0].lino, 0, lhs[x0].text)
        : Edit(lhs[x0].lino, rhs[y0].lino, lhs[x0].text)
    ;
  } // }}}
  return backtrack!eq(lhs, rhs)
    .map!(xyxy => toEdit(xyxy.expand))
    .array
    .retro
  ;
} // }}}

auto backtrack(alias eq)(const Line[] lhs, const Line[] rhs) // {{{
{
  long x1 = lhs.length;
  long y1 = rhs.length;

  Tuple!(long, long, long, long)[] rv;

  lcs!eq(lhs, rhs).enumerate.retro.each!((long d, long[] v) {
    long k0;
    long k1 = x1 - y1;

    if (k1 == -d || (k1 != d && v.at(k1 - 1) < v.at(k1 + 1)))
      k0 = k1 + 1;
    else
      k0 = k1 - 1;

    long x0 = v.at(k0);
    long y0 = x0 - k0;

    while (x1 > x0 && y1 > y0) {
      rv ~= tuple(x1 - 1, y1 - 1, x1, y1);
      x1 -= 1;
      y1 -= 1;
    }

    if (d > 0)
      rv ~= tuple(x0, y0, x1, y1);

    x1 = x0;
    y1 = y0;
  });

  return rv;
} // }}}

auto lcs(alias eq)(const Line[] lhs, const Line[] rhs) // {{{
{
  const size_t ll = lhs.length;
  const size_t rl = rhs.length;

  long[] v;
  long[][] vs;

  v.length = max(1 + 2 * (ll + rl), 2);

  iota(1 + ll + rl).each!((long d) {
    vs ~= v.dup;

    return iota(-d, d + 1, 2).each!((long k) {
      long x;
      if (k == -d || (k != d && v.at(k - 1) < v.at(k + 1)))
        x = v.at(k + 1);
      else
        x = v.at(k - 1) + 1;

      long y = x - k;

      while (x < ll && y < rl && (eq(lhs[x].text, rhs[y].text))) {
        x += 1;
        y += 1;
      }

      at(v, k) = x;

      return (x >= ll && y >= rl)
        ? No.each
        : Yes.each
      ;
    });
  });

  return vs;
} // }}}
