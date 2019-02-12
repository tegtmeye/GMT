# Produce 2 columns of histogram-worthy data
# First colmn is the bins and the second is the count of input items in
# those bins

# ARG1 is the input tablename
# ARG2 is the output tablename
# ARG3 is the binwidth
# ARG4 is the cluster number
# ARG5 is the total cluster number
# ARG6 is total cluster display width

# print argvals(ARG0)

if(ARGC != 6) {
  print(sprintf("%s: [input tablename] [output tablename] [binwidth] [cluster number] [total cluster number] [display width]",ARG0));
  exit error 'exiting...'
}

if(exists("ARG4") && ARG4 ne "" && (ARG4 < 0 || floor(ARG4) != ARG4)) {
  print(sprintf("%s: cluster number must be a non-negative integer",ARG0));
  exit error 'exiting...'
}

if(exists("ARG5") && ARG5 ne "" && \
  (ARG5 < 0 || floor(ARG5) != ARG5 || ARG5 < ARG4)) \
{
  print(sprintf("%s: total cluster number must be an integer greater than cluster number",ARG0));
  exit error 'exiting...'
}

if(exists("ARG6") && ARG6 ne "" && \
  (ARG6 < 0 ||  ARG3 < ARG6)) \
{
  print(sprintf("%s: display width cannot be larger than the bin width",ARG0));
  exit error 'exiting...'
}


GMT_HISTOGRAM_DATASET_cluster_off = \
	(ARG6*(1+2*ARG4-ARG5))/(2.0*ARG5);

GMT_HISTOGRAM_DATASET_bin(val,width)= \
  (width*floor(((val*2.0)+width)/(width*2.0))) + \
  	GMT_HISTOGRAM_DATASET_cluster_off;


set style data points
set datafile separator tab
set datafile missing NaN
set key autotitle

set xrange [*:*]
set yrange [*:*]

# use 2 tables because 'separator tab' only appears to work 'with table'
GMT_HISTOGRAM_DATASET_CALL_PLOT=sprintf(\
  "set table $tmp%s separator tab; \
  plot $%s u (GMT_HISTOGRAM_DATASET_bin(column(1),ARG3)):(1.0) smooth freq; \
  unset table;",ARG2,ARG1);

GMT_HISTOGRAM_DATASET_CALL_TABLE=sprintf(\
  "set table $%s separator tab; \
  plot $tmp%s u 1:2 with table; \
  unset table;undefine $tmp%s",ARG2,ARG2,ARG2);

eval(GMT_HISTOGRAM_DATASET_CALL_PLOT)

# plotting to table using smooth freq qlways outputs space separated for
# some reason
set datafile separator whitespace

eval(GMT_HISTOGRAM_DATASET_CALL_TABLE)

set datafile separator tab

undefine GMT_HISTOGRAM_DATASET_* GPFUN_GMT_HISTOGRAM_DATASET_*

