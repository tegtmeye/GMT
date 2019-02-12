# Plot a cumulative histogram where each bin contains three values, two
# components and the cumulative amount. The first column in the input databases
# are used

# ARG1 is the output filename
# ARG2 is the binwidth
# ARG3 is empty, stddev, quartile for +/- brackets
# ARG4 is the input datatable name. Do not include the '$'
# ARG5 is the input datatable name. Do not include the '$'
# ARG6 is a command string evaluated prior to the actual plot. Use '' to ignore
# ARG7 is the title associated with the cumulative input [optional]
# ARG8 is the title associated with input datatable 2 [optional]
# ARG9 is the title associated with input datatable 1 [optional]

if(ARGC < 6 || !(ARG3 eq "empty" || ARG3 eq "stddev" || ARG3 eq "quartile")) \
{
  print(sprintf("%s: [output filename] [binwidth] [empty,stddev,quartile brackets] [cmd] [input1] [input2]",ARG0));
  exit error 'exiting...'
}

if(!exists("colorpalette") || |colorpalette| < 2) {
  print(sprintf("%s: requires at least a 2 color palette",ARG0));
  exit error 'exiting...'
}


set terminal postscript eps enhanced color font ",12"
set output ARG1

load 'gridstylexy.cfg'
load 'xyborder.cfg'

GMT_PAIRED_HISTOGRAM_nclusters = 2;
GMT_PAIRED_HISTOGRAM_clusterwidth = ARG2 * 0.9;
GMT_PAIRED_HISTOGRAM_subclusterwidth = \
	(GMT_PAIRED_HISTOGRAM_clusterwidth * 0.8);
GMT_PAIRED_HISTOGRAM_subboxwidth = \
	GMT_PAIRED_HISTOGRAM_subclusterwidth / GMT_PAIRED_HISTOGRAM_nclusters;

# concatenate the two datasets together for the cumulative
eval("call 'block_cat.gp' GMT_PAIRED_HISTOGRAM_BLOCK_ALL ".ARG4.' '.ARG5);

stats $GMT_PAIRED_HISTOGRAM_BLOCK_ALL using 1 name 'GMT_PAIRED_HISTOGRAM_INPUTCUM' nooutput
call 'histogram_dataset.gnuplot' \
  'GMT_PAIRED_HISTOGRAM_BLOCK_ALL' GMT_PAIRED_HISTOGRAM_BLOCK_ALL_HIST \
  	ARG2 0 1 (GMT_PAIRED_HISTOGRAM_clusterwidth)

call 'histogram_dataset.gnuplot' \
  ARG4 GMT_PAIRED_HISTOGRAM_BLOCK1_HIST ARG2 0 2 \
	(GMT_PAIRED_HISTOGRAM_subclusterwidth)

call 'histogram_dataset.gnuplot' \
  ARG5 GMT_PAIRED_HISTOGRAM_BLOCK2_HIST ARG2 1 2 \
	(GMT_PAIRED_HISTOGRAM_subclusterwidth)

if(ARG3 eq "quartile") {
  #median +/- quartile
  set arrow \
  	from GMT_PAIRED_HISTOGRAM_INPUTCUM_median_y,graph 0 to \
  	GMT_PAIRED_HISTOGRAM_INPUTCUM_median_y, graph 1 nohead front \
  	lt 1 lw 1 lc rgb 'black'

  set object rectangle \
  	from GMT_PAIRED_HISTOGRAM_INPUTCUM_lo_quartile_y,graph 0 \
    to GMT_PAIRED_HISTOGRAM_INPUTCUM_up_quartile_y, graph 1 \
    fc rgb "black" fillstyle transparent solid .025 noborder back

  set object rectangle \
  	from GMT_PAIRED_HISTOGRAM_INPUTCUM_lo_quartile_y,graph 0 \
    to GMT_PAIRED_HISTOGRAM_INPUTCUM_up_quartile_y, graph 1 \
    fc rgb "black" fillstyle empty border \
    lc rgb 'grey20' lw 1 dt 4 front

  set arrow from GMT_PAIRED_HISTOGRAM_INPUTCUM_lo_quartile_y,graph 0.95 rto \
    graph -0.05,0 backhead lt 1 lw 0.5 lc rgb 'black' front

  GMT_PAIRED_HISTOGRAM_histogram_range= \
  	sprintf('\{%.1f,%.1f,%.1f\}',GMT_PAIRED_HISTOGRAM_INPUTCUM_lo_quartile_y, \
    	GMT_PAIRED_HISTOGRAM_INPUTCUM_median_y, \
    	GMT_PAIRED_HISTOGRAM_INPUTCUM_up_quartile_y)

  set label \
  	GMT_PAIRED_HISTOGRAM_histogram_range at \
  	GMT_PAIRED_HISTOGRAM_INPUTCUM_lo_quartile_y,graph 0.95 offset \
  	graph -0.05,0 right

  set arrow from GMT_PAIRED_HISTOGRAM_INPUTCUM_up_quartile_y,graph 0.95 rto \
    graph 0.05,0 backhead lt 1 lw 0.5 lc rgb 'black' front
}

if(exists("ARG5") && ARG5 eq "stddev") {
  # mean +/- 1 stddev
  set arrow from \
  	GMT_PAIRED_HISTOGRAM_INPUTCUM_mean_y,graph 0 to \
  	GMT_PAIRED_HISTOGRAM_INPUTCUM_mean_y, graph 1 nohead front \
  	lt 1 lw 0.5 lc rgb 'black'

  set object rectangle from \
  	(GMT_PAIRED_HISTOGRAM_INPUTCUM_mean_y - \
  		GMT_PAIRED_HISTOGRAM_INPUTCUM_stddev_y),graph 0 \
    to (GMT_PAIRED_HISTOGRAM_INPUTCUM_mean_y + \
    	GMT_PAIRED_HISTOGRAM_INPUTCUM_stddev_y), graph 1 \
    fc rgb "black" fillstyle transparent solid .025 noborder back

  set object rectangle from \
  	(GMT_PAIRED_HISTOGRAM_INPUTCUM_mean_y - \
  		GMT_PAIRED_HISTOGRAM_INPUTCUM_stddev_y),graph 0 \
    to (GMT_PAIRED_HISTOGRAM_INPUTCUM_mean_y + \
    	GMT_PAIRED_HISTOGRAM_INPUTCUM_stddev_y), graph 1 \
    fc rgb "black" fillstyle empty border \
    lc rgb 'grey20' lw .5 dt 4 front

  set arrow from \
  (GMT_PAIRED_HISTOGRAM_INPUTCUM_mean_y - \
  	GMT_PAIRED_HISTOGRAM_INPUTCUM_stddev_y),graph 0.95 rto \
    graph -0.05,0 backhead lt 1 lw 0.5 lc rgb 'black' front

  _range = sprintf("%.1f +/-%.1f", \
  	GMT_PAIRED_HISTOGRAM_INPUTCUM_mean_y,GMT_PAIRED_HISTOGRAM_INPUTCUM_stddev_y)

  set label \
  	_range at (GMT_PAIRED_HISTOGRAM_INPUTCUM_mean_y - \
  		GMT_PAIRED_HISTOGRAM_INPUTCUM_stddev_y),graph 0.95 \
    offset graph -0.05,0 right

  set arrow from \
  	(GMT_PAIRED_HISTOGRAM_INPUTCUM_mean_y + \
  		AGMT_PAIRED_HISTOGRAM_INPUTCUM_stddev_y),graph 0.95 rto \
    graph 0.05,0 backhead lt 1 lw 0.5 lc rgb 'black' front
}

if(exists("ARG6") && ARG6 ne "") {
  eval(ARG6)
}

GMT_PAIRED_HISTOGRAM_TOTAL_TITLE='notitle';
GMT_PAIRED_HISTOGRAM_TOTAL_KDE_TITLE='notitle';
if(exists("ARG7") && ARG7 ne "") {
  GMT_PAIRED_HISTOGRAM_TOTAL_TITLE=sprintf("title '%s'",ARG7);
	GMT_PAIRED_HISTOGRAM_TOTAL_KDE_TITLE=sprintf("title '%s KDE'",ARG7);
}

GMT_PAIRED_HISTOGRAM_INPUT1_TITLE='notitle';
GMT_PAIRED_HISTOGRAM_INPUT1_KDE_TITLE='notitle';
if(exists("ARG8") && ARG8 ne "") {
  GMT_PAIRED_HISTOGRAM_INPUT1_TITLE=sprintf("title '%s'",ARG8);
	GMT_PAIRED_HISTOGRAM_INPUT1_KDE_TITLE=sprintf("title '%s KDE'",ARG8);
}

GMT_PAIRED_HISTOGRAM_INPUT2_TITLE='notitle';
GMT_PAIRED_HISTOGRAM_INPUT2_KDE_TITLE='notitle';
if(exists("ARG9") && ARG9 ne "") {
  GMT_PAIRED_HISTOGRAM_INPUT2_TITLE=sprintf("title '%s'",ARG9);
	GMT_PAIRED_HISTOGRAM_INPUT2_KDE_TITLE=sprintf("title '%s KDE'",ARG9);
}


GMT_PAIRED_HISTOGRAM_PLOT_CMD=sprintf("plot \
  newhistogram, \
    $GMT_PAIRED_HISTOGRAM_BLOCK_ALL_HIST \
    	u 1:2:(GMT_PAIRED_HISTOGRAM_clusterwidth) with boxes %s \
      fs solid 0.5 noborder fc rgb 'gray', \
  newhistogram, \
    $GMT_PAIRED_HISTOGRAM_BLOCK1_HIST \
    	u 1:2:(GMT_PAIRED_HISTOGRAM_subboxwidth) with boxes %s \
      fs solid 0.5 border lc rgb 'black' lw 0.5 fc rgb colorpalette[1], \
  newhistogram, \
    $GMT_PAIRED_HISTOGRAM_BLOCK2_HIST \
    	u 1:2:(GMT_PAIRED_HISTOGRAM_subboxwidth) with boxes %s \
      fs solid 0.5 border lc rgb 'black' lw 0.5 fc rgb colorpalette[2], \
  $GMT_PAIRED_HISTOGRAM_BLOCK_ALL \
  	using 1:(1./GMT_PAIRED_HISTOGRAM_INPUTCUM_records) smooth kdensity \
  	axis x1y2 lw 2 dt 1 lc rgb 'gray' %s, \
  $%s using 1:(1./GMT_PAIRED_HISTOGRAM_INPUTCUM_records) smooth kdensity \
  	axis x1y2 lw 2 dt 2 lc rgb colorpalette[1] %s, \
  $%s using 1:(1./GMT_PAIRED_HISTOGRAM_INPUTCUM_records) smooth kdensity \
  	axis x1y2 lw 2 dt 4 lc rgb colorpalette[2] %s", \
  GMT_PAIRED_HISTOGRAM_TOTAL_TITLE, \
	 GMT_PAIRED_HISTOGRAM_INPUT1_TITLE, \
 	GMT_PAIRED_HISTOGRAM_INPUT2_TITLE, \
 	GMT_PAIRED_HISTOGRAM_TOTAL_KDE_TITLE, \
  ARG4,GMT_PAIRED_HISTOGRAM_INPUT1_KDE_TITLE, \
  ARG5,GMT_PAIRED_HISTOGRAM_INPUT2_KDE_TITLE);

eval(GMT_PAIRED_HISTOGRAM_PLOT_CMD)

undefine GMT_PAIRED_HISTOGRAM_* \
	$GMT_PAIRED_HISTOGRAM_BLOCK_ALL \
	$GMT_PAIRED_HISTOGRAM_BLOCK_ALL_HIST \
	$GMT_PAIRED_HISTOGRAM_BLOCK1_HIST \
	$GMT_PAIRED_HISTOGRAM_BLOCK2_HIST

