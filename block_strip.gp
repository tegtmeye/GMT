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

# strip invalid and missing values from column data, essentially just
# sets datafile missing ARG

# ARG1 is the input datablock name -- do not include the '$'
# ARG2 is the output datablock name -- do not include the '$'
# ARG3 is the argument to 'set datafile missing X'
# ARG4 ... are the remaining column numbers to be included in the block (can be #		repeated)

if(ARGC < 4) {
  print(sprintf("%s: [input blockname] [output blockname] [missing value]  [[included_column] ... ]",ARG0));

  exit error 'exiting...'
}

set style data points
unset datafile
set datafile separator tab
set key autotitle

set xrange [*:*]
set yrange [*:*]

GMT_SET_TABLE=sprintf("set table $%s separator tab",ARG2);

GMT_PLOT_CMD=sprintf("plot $%s using (column(%s))",ARG1,ARG4);

do for [i=5:ARGC] {
	GMT_PLOT_CMD=GMT_PLOT_CMD.sprintf(":(column(%s))",value('ARG'.i));
}

GMT_PLOT_CMD=GMT_PLOT_CMD." with table; unset table";

eval(sprintf("set datafile missing %s",ARG3));

eval(GMT_SET_TABLE);
eval(GMT_PLOT_CMD);

undefine GMT_SET_TABLE GMT_PLOT_CMD

