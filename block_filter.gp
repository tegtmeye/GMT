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
# N.B. The data is read in as strings. This means that:
#   a) Any 'set datafile missing ...' specification is reset
#   b) The read values may be invalid and contain things like NaNs etc
#   c) Invalid data processing is deferred to the use of the block, not
#       here.

# ARG1 is the input datablock name -- do not include the '$'
# ARG2 is the output datablock name -- do not include the '$'
# ARG3 is the filtered column number
# ARG4 is a unary predicate expression name. If this expression
#     evaluates to true, val is included in the results otherwise the
#     column value is 'NaN'. For example, given the predicates:
#       pred(val)=val == 5;  or pred(val)=(val eq 'hello');
#     The the value of ARG4 is the string 'pred'
#
# ARG5 ... are the remaining column numbers to be included in the block (can be #		repeated)

# There is currently a bug in gnuplot that causes extra whitespace to be added
# at the end or the beginning of table plotting. See bug #2140. Unfortunately
# another bug exists where attempts to sanitize this extra value causes bad data
# to be encoded in the result. Unclear what is going on or even how to
# reliably reproduce. Until a fix is made, ensure the predicate can
# handle the extra padding.

if(ARGC < 4) {
  print(sprintf("%s: [input blockname] [output blockname] [filter_column_no] [filter_expression] [[included_column] ... ]",ARG0));

  exit error 'exiting...'
}

if(exists('GPFUN_'.ARG4) == 0) {
  print("Unary predicate '".ARG4."' does not exist.");

  exit error 'exiting...'
}




set style data points
unset datafile
set datafile separator tab
set key autotitle

set xrange [*:*]
set yrange [*:*]

# GMT_BLOCK_FILTER_sanitize(val)=word(val,1);

# eval( \
#   sprintf("GMT_BLOCK_FILTER_unary_filter(val)= \
#     ((%s(GMT_BLOCK_FILTER_sanitize(val)))?val:NaN)",ARG4));
#
# eval( \
#   sprintf("GMT_BLOCK_FILTER_binary_filter(val,outval)= \
#     ((%s(GMT_BLOCK_FILTER_sanitize(val)))?outval:NaN)",ARG4));

eval( \
  sprintf("GMT_BLOCK_FILTER_unary_filter(val)= \
    ((%s(val))?val:NaN)",ARG4));

eval( \
  sprintf("GMT_BLOCK_FILTER_binary_filter(val,outval)= \
    ((%s(val))?outval:NaN)",ARG4));



GMT_BLOCK_FILTER_SET_TABLE=sprintf("set table $%s separator tab",ARG2);
#GMT_BLOCK_FILTER_SET_TABLE=sprintf("set table '%s' separator tab",ARG2);


GMT_BLOCK_FILTER_PLOT_CMD= \
	sprintf("plot $%s using \
	  (GMT_BLOCK_FILTER_unary_filter(strcol(%s)))",ARG1,ARG3);

do for [i=5:ARGC] {
	GMT_BLOCK_FILTER_PLOT_CMD=GMT_BLOCK_FILTER_PLOT_CMD.\
    sprintf(":(GMT_BLOCK_FILTER_binary_filter(strcol(%s),strcol(%s)))", \
      ARG3,value('ARG'.i));
}

GMT_BLOCK_FILTER_PLOT_CMD=GMT_BLOCK_FILTER_PLOT_CMD." with table; unset table";

#print(GMT_BLOCK_FILTER_SET_TABLE)
#print(GMT_BLOCK_FILTER_PLOT_CMD)

eval(GMT_BLOCK_FILTER_SET_TABLE);
eval(GMT_BLOCK_FILTER_PLOT_CMD);


undefine GMT_BLOCK_FILTER_* GPFUN_GMT_BLOCK_FILTER_*

