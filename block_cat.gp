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


# concatenate datablocks together

# ARG1 is out datablock name. Do not include the '$'.
# ARG2 ... are the datablock names to be concatenated together

if(ARGC < 2) {
  print(sprintf("%s: [output blockname] [input blockname 1] [input blockname 2] [[[input blockname N] ... ]",ARG0));

  exit error 'exiting...'
}

set style data points
set datafile separator tab
set datafile missing NaN
set key autotitle

set xrange [*:*]
set yrange [*:*]

eval(sprintf("stats $%s matrix nooutput name 'GMT_BLOCK_CAT_TMP'",ARG2));

# stats always includes the pseudocolumn 0
if(GMT_BLOCK_CAT_TMP_size_x < 2) {
	print( \
		sprintf("input datablock $%s requires at least one column of data",ARG1));

  exit error 'exiting...'
}

GMT_BLOCK_CAT_using_str='using (strcol(1))';

do for [i=2 : GMT_BLOCK_CAT_TMP_size_x-1] {
	GMT_BLOCK_CAT_using_str=GMT_BLOCK_CAT_using_str.':(strcol('.i.'))';
}

GMT_BLOCK_CAT_SET_TABLE=sprintf("set table $%s append separator tab",ARG1);
#GMT_BLOCK_CAT_SET_TABLE=sprintf("set table '%s' append separator tab",ARG1);

do for [i=2 : ARGC] {
	eval(GMT_BLOCK_CAT_SET_TABLE);
	eval(sprintf("plot $%s %s with table",value('ARG'.i),GMT_BLOCK_CAT_using_str));
	unset table;
}

undefine GMT_BLOCK_CAT_*
