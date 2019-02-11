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


# filter a datablock into another datablock based on the given criteria
# NB datablocks have their column name headers stripped out in gnuplot
# therefore all column references are by number which is less than
# convenient but necessary under the current version of gnuplot.

# ARG1 is the input datablock name -- do not include the '$'
# ARG2 is the output datablock name -- do not include the '$'
# ARG3 is the filtered column number
# ARG4 is the filter expression where 'val' means the current value in the given #		column. If this expression evaluates to true, val is included in the results
# ARG5 ... are the remaining column numbers to be included in the block (can be #		repeated)

if(ARGC < 4) {
  print(sprintf("%s: [input blockname] [output blockname] [filter_column_no] [filter_expression] [[included_column] ... ]",ARG0));

  exit error 'exiting...'
}

set style data points
set datafile separator tab
set datafile missing NaN
set key autotitle columnhead

set xrange [*:*]
set yrange [*:*]

GMT_SET_TABLE=sprintf("set table $%s separator tab",ARG2);
#GMT_SET_TABLE=sprintf("set table '%s' separator tab",ARG2);

eval(sprintf("_filter(val)=((val %s)?val:NaN)",ARG4));

GMT_PLOT_CMD=sprintf("plot $%s using (_filter(strcol(%s)))",ARG1,ARG3);

do for [i=5:ARGC] {
	GMT_PLOT_CMD=GMT_PLOT_CMD.sprintf(":(strcol(%s))",value('ARG'.i));
}

GMT_PLOT_CMD=GMT_PLOT_CMD." with table";

#print(GMT_PLOT_CMD)

eval(GMT_SET_TABLE);
eval(GMT_PLOT_CMD);

unset table

set key autotitle

undefine GMT_SET_TABLE GMT_PLOT_CMD

