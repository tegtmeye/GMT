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


# select, reorder, and duplicate columns in a datablock

# ARG1 is the input datablock name -- do not include the '$'
# ARG2 is the output datablock name -- do not include the '$'
# ARG3 ... are the remaining column numbers to be included in the block (can be #		repeated)

if(ARGC < 3) {
  print(sprintf("%s: [input blockname] [output blockname] [included_column]  [[included_column] ... ]",ARG0));

  exit error 'exiting...'
}

set style data points
set datafile separator tab
set datafile missing NaN
set key autotitle

set xrange [*:*]
set yrange [*:*]

GMT_SET_TABLE=sprintf("set table $%s separator tab",ARG2);
#GMT_SET_TABLE=sprintf("set table '%s' separator tab",ARG2);

GMT_PLOT_CMD=sprintf("plot $%s using (strcol(%s))",ARG1,ARG3);

do for [i=4:ARGC] {
	GMT_PLOT_CMD=GMT_PLOT_CMD.sprintf(":(strcol(%s))",value('ARG'.i));
}

GMT_PLOT_CMD=GMT_PLOT_CMD." with table";

#print(GMT_PLOT_CMD)

eval(GMT_SET_TABLE);
eval(GMT_PLOT_CMD);

unset table

undefine GMT_SET_TABLE GMT_PLOT_CMD

