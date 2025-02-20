#!/usr/bin/perl

#
# Author : Ahfyth
#

use strict;
use warnings;

if( $#ARGV!=1 && $#ARGV!=2 )
{
	print STDERR "\nUsage : $0 <original.svm> <libsvm_out> [output=stdout]\n";
	print STDERR "\nThis program is designed to make the prediction result.\n\n";
	exit 1;
}

open IN, "$ARGV[0]" || die( "$!" );
my @svm;
while( <IN> )
{
	chomp;
	if( $_=~s/^.*#// )
	{
		push @svm, $_;
	}
	else
	{
		print STDERR "ERROR : No id record for line $. ! STOP. \n";
		close IN;
		exit 2;
	}
}
close IN;

my $out = $ARGV[2] || '/dev/stdout';
open OUT, ">$out" || die( "$!" );
select OUT;

print "#id\ttype\tscore\n";

open IN, "$ARGV[1]" || die( "$!" );
<IN>;
while( <IN> )
{
	my( $class, $p1, $p2 ) = split /\s+/;
	my $id = shift @svm;
	my $ev = $p1;
#	$ev = $p2 if $class == 1;
	my $type = 'noncoding';
	$type = 'coding' if $class == 1;
	print "$id\t$type\t$ev\n";
}

close IN;


