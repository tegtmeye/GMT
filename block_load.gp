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

# create a datablock from an input file of column data with headers
# N.B. The data is read in as strings. This means that:
#   a) Any 'set datafile missing ...' specification is reset
#   b) The read values may be invalid and contain things like NaNs etc
#   c) Invalid data processing is deferred to the use of the block, not
#       here.
#   d) Missing values are replaced by NaNs because of current limitations with
#       how gnuplot handles missing data in columns.

# ARG1 is the data filename
# ARG2 is the datablock name -- do not include the '$'
# ARG3 ... are the column names to include in the block (can be repeated)

if(ARGC <3) {
  print(sprintf("%s: [data filename] [output blockname] [columnname] [[columnname] ... ]",ARG0));

  exit error 'exiting...'
}

set style data points
unset datafile
set datafile separator tab
set key autotitle columnhead

set xrange [*:*]
set yrange [*:*]

GMT_sanitize(val)=(word(val,1) eq '' ? NaN : val);

GMT_SET_TABLE=sprintf("set table $%s separator tab",ARG2);
#GMT_SET_TABLE=sprintf("set table '%s' separator tab",ARG2);

GMT_PLOT_CMD=sprintf("plot '%s' using (GMT_sanitize(strcol('%s')))",ARG1,ARG3);

do for [i=4:ARGC] {
	GMT_PLOT_CMD=GMT_PLOT_CMD.sprintf(":(GMT_sanitize(strcol('%s')))",value('ARG'.i));
}

GMT_PLOT_CMD=GMT_PLOT_CMD." with table";

# print(GMT_PLOT_CMD)

eval(GMT_SET_TABLE);
eval(GMT_PLOT_CMD);

unset table

set key autotitle

undefine GMT_SET_TABLE GMT_PLOT_CMD

