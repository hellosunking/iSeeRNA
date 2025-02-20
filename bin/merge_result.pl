#!/usr/bin/perl

#
# Author : Ahfyth
#

use strict;
use warnings;

if( $#ARGV < 0 )
{
	print STDERR "\nUsage : $0 <input.result> [input.result ...]\n";
	print STDERR "\nThis program is designed to merge all the prediction results.\n\n";
	exit 1;
}

print "#transcript-id\tpredict-type\tnoncoding-score\n";

foreach ( @ARGV )
{
	open IN, "$_" || die( "$!" );
	<IN>;	# skip header line
	while( <IN> )
	{
		print $_;
	}
	close IN;
}

