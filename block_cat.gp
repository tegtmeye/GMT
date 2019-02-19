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
# N.B. The data is read in as strings. This means that:
#   a) Any 'set datafile missing ...' specification is reset
#   b) The read values may be invalid and contain things like NaNs etc
#   c) Invalid data processing is deferred to the use of the block, not
#       here.

# ARG1 is out datablock name. Do not include the '$'.
# ARG2 is the number of columns to include
# ARG3 ... are the datablock names to be concatenated together

if(ARGC < 3 || ARG2 < 1) {
  print(sprintf("%s: [output blockname] [num columns] [input blockname 1] [input blockname 2] [[[input blockname N] ... ]",ARG0));

  exit error 'exiting...'
}

set style data points
unset datafile
set datafile separator tab
set key autotitle

set xrange [*:*]
set yrange [*:*]

GMT_BLOCK_CAT_using_str='using (strcol(1))';

if(ARG2 > 1) {
  do for [i=2 : ARG2] {
    GMT_BLOCK_CAT_using_str=GMT_BLOCK_CAT_using_str.':(strcol('.i.'))';
  }
}

GMT_BLOCK_CAT_SET_TABLE=sprintf("set table $%s append separator tab",ARG1);
#GMT_BLOCK_CAT_SET_TABLE=sprintf("set table '%s' append separator tab",ARG1);

do for [i=3 : ARGC] {
#   eval(sprintf("call 'block_dump.gp' %s '%s.txt' %s", \
#     value('ARG'.i),value('ARG'.i),ARG2));
	eval(GMT_BLOCK_CAT_SET_TABLE);
	eval(sprintf("plot $%s %s with table",value('ARG'.i),GMT_BLOCK_CAT_using_str));
	unset table;
}

undefine GMT_BLOCK_CAT_*
