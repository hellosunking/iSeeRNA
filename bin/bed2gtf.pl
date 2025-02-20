#!/usr/bin/perl

#
# Author : Ahfyth
#

use strict;
use warnings;

if( $#ARGV < 0 )
{
	print STDERR "\nUsage: $0 <ucsc_12.bed> [flag=iSeeRNA]\n";
	print STDERR "\nThis program is designed to translate the bed format (MUST contain 12 fields) to gtf format.\n\n";
	exit 1;
}

my $flag= $ARGV[1] || 'iSeeRNA';

open IN, "$ARGV[0]" or die( "$!" );
my $pass = 0;
while( <IN> )
{
	chomp;
	my @l = split /\s+/;	#chr13	70682043	70705678	n1175	1000	+	70682043	70705678	0	4	108,158,101,869,	0,7229,21872,22766,
	if( $#l != 11 )
	{
#		print STDERR "Skip line $. : format error.\n";
		next;
	}
	my ($chr, $start, $end, $name, $strand) = ( $l[0], $l[1]+1, $l[2], $l[3], $l[5] );	# note the 0-base thing
	unless( $strand eq '+' || $strand eq '-' )
	{
#		print STDERR "Skip line $. : strand unknown.\n";
		next;
	}
	print "$chr\t$flag\ttranscript\t$start\t$end\t.\t$strand\t.\tid $name\n";

	my @len = split /,/, $l[10];
	my @ss  = split /,/, $l[11];

	for( my $i=0; $i<=$#len; ++$i )
	{
		my $hs = $start + $ss[$i];
		my $he = $hs + $len[$i] - 1;

		print "$chr\t$flag\texon\t$hs\t$he\t.\t$strand\t.\ttranscript_id $name\n";
	}
	$pass ++;
}
close IN;

if( $pass == 0 )
{
	print STDERR "Error: Your bed file is invalid! Please note that it MUST contains 12 fields as discribed by UCSC.\n\n";
	exit 1;
}


