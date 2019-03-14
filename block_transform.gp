#
#  Copyright (c) 2018, Mike Tegtmeyer
#  All rights reserved.
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions are met:
#
#      * Redistributions of source code must retain the above copyright
#        notice, this list of conditions and the following disclaimer.
#      * Redistributions in binary form must reproduce the above copyright
#        notice, this list of conditions and the following disclaimer in the
#        documentation and/or other materials provided with the distribution.
#      * Neither the name of the author nor the names of its contributors may
#        be used to endorse or promote products derived from this software
#        without specific prior written permission.
#
#  THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND ANY
#  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
#  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#  DISCLAIMED. IN NO EVENT SHALL THE REGENTS AND CONTRIBUTORS BE LIABLE FOR ANY
#  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
#  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
#  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
#  THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#/


# transform a column while selecting, reordering, and duplicating
# columns in a datablock
# N.B. The data is read in as strings. This means that:
#   a) Any 'set datafile missing ...' specification is reset
#   b) The read values may be invalid and contain things like NaNs etc
#   c) Invalid data processing is deferred to the use of the block, not
#       here.

# ARG1 is the input datablock name -- do not include the '$'
# ARG2 is the output datablock name -- do not include the '$'
# ARG3 is a unary transformation expression name of the value 'val'. For
#      example, given the unary function: fn(val)=(val == 5);  or
#       fn(val)=(val.'hello'); The the value of ARG4 is the string 'fn'
#
# ARG4 ... are the remaining column numbers to be included in the block (can be #		repeated)

# There is currently a bug in gnuplot that causes extra whitespace to be added
# at the end or the beginning of table plotting. See bug #2140. Unfortunately
# another bug exists where attempts to sanitize this extra value causes bad data
# to be encoded in the result. Unclear what is going on or even how to
# reliably reproduce. Until a fix is made, the unary function can
# handle the extra padding.

if(ARGC < 4) {
  print(sprintf("%s: [input blockname] [output blockname] [transform_expression] [[included_column] ... ]",ARG0));

  exit error 'exiting...'
}

if(exists('GPFUN_'.ARG3) == 0) {
  print("Unary function '".ARG3."' does not exist.");

  exit error 'exiting...'
}

set style data points
unset datafile
set datafile separator tab
set key autotitle

set xrange [*:*]
set yrange [*:*]

GMT_SET_TABLE=sprintf("set table $%s separator tab",ARG2);
#GMT_SET_TABLE=sprintf("set table '%s' separator tab",ARG2);

GMT_PLOT_CMD=sprintf("plot $%s using ",ARG1);

do for [i=4:ARGC] {
  GMT_ARGVAL=value('ARG'.i)
  if(GMT_ARGVAL[1:1] eq '_') {
    GMT_PLOT_CMD=GMT_PLOT_CMD.sprintf("(%s(strcol(%s)))",ARG3,GMT_ARGVAL[2:*]);
  }
  else {
    GMT_PLOT_CMD=GMT_PLOT_CMD.sprintf("(strcol(%s))",GMT_ARGVAL);
  }

  if(i != ARGC) {
    GMT_PLOT_CMD=GMT_PLOT_CMD.':';
  }

}

GMT_PLOT_CMD=GMT_PLOT_CMD." with table; unset table";

# print(GMT_PLOT_CMD)

eval(GMT_SET_TABLE);
eval(GMT_PLOT_CMD);

undefine GMT_SET_TABLE GMT_PLOT_CMD GMT_ARGVAL

