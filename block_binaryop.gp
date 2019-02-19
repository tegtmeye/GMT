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
#

# apply the given binary operator to two specified columns of data on an input
# block to produce a column in an output block. The given binary operator is
# provided 'x' for the first column and 'y' for the second. eg
# "x + y" or "x < y" or "external_function(x,y)" etc

# ARG1 is the input datablock name -- do not include the '$'
# ARG2 is the output datablock name -- do not include the '$'
# ARG3 is the first column in the input datablock
# ARG4 is the second column in the input datablock
# ARG5 is the binary operation in 'x' and 'y'
# ARG6 ... are the remaining column numbers to be included in the block (can be #		repeated)

if(ARGC < 5) {
  print(sprintf("%s: [input blockname] [output blockname] [column1] [column2] [binary operator] [[included_column] ... ]",ARG0));

  exit error 'exiting...'
}

set style data points
unset datafile
set datafile separator tab
set key autotitle

set xrange [*:*]
set yrange [*:*]

eval(sprintf("GMT_BLOCK_BINARYOP_fn(x,y)=%s",ARG5));

GMT_BLOCK_BINARYOP_SET_TABLE=sprintf("set table $%s separator tab",ARG2);

GMT_BLOCK_BINARYOP_PLOT_CMD= \
  sprintf("plot $%s using (GMT_BLOCK_BINARYOP_fn(column(%s),column(%s)))", \
    ARG1,ARG3,ARG4);

do for [i=6:ARGC] {
	GMT_BLOCK_BINARYOP_PLOT_CMD= \
	  GMT_BLOCK_BINARYOP_PLOT_CMD.sprintf(":(column(%s))",value('ARG'.i));
}

GMT_BLOCK_BINARYOP_PLOT_CMD= \
  GMT_BLOCK_BINARYOP_PLOT_CMD." with table; unset table";

# print(GMT_BLOCK_BINARYOP_SET_TABLE)
# print(GMT_BLOCK_BINARYOP_PLOT_CMD)

eval(GMT_BLOCK_BINARYOP_SET_TABLE);
eval(GMT_BLOCK_BINARYOP_PLOT_CMD);

undefine GMT_BLOCK_BINARYOP_* GPFUN_GMT_BLOCK_BINARYOP_*

