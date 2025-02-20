#!/usr/bin/perl

#
# Author : Ahfyth
#

use strict;
use warnings;

if( $#ARGV < 3 )
{
	print STDERR "\nUsage : $0 <input.list> <input.consv> <input.orf.raw> <input.feature> [label=0] [limit=200]\n";
	print STDERR "\nThis program is designed to merge all the files into one svm-file.\n\n";
	exit 1;
}

my $label = $ARGV[4] || '0';

my %LENGTH;
my %CONSV;
my %ORF;
my %FEATURE;

my $limit = $ARGV[5] || 200;

open IN, "$ARGV[0]" || die( "$!" );
my $all = 0;
while( <IN> )
{
	next if /^#/;
	chomp;
	my @line = split /\t/;
	my @tmp = split /\s+/, $line[0];
	if( $line[1] < $limit )
	{
		print STDERR "Length for $tmp[0] is $line[1], skip.\n";
		next;
	}
	$LENGTH{$tmp[0]} = $line[1];
	$all ++;
}
close IN;
print STDERR "Loading   LIST  file done. Totally $all records.\n";

open IN, "$ARGV[1]" || die( "$!" );
$all = 0;
while( <IN> )
{
	chomp;
	my @line = split /\t/;
	my @tmp = split /\s+/, $line[0];

	next unless exists $LENGTH{$tmp[0]};

	$CONSV{$tmp[0]} = "1:$line[2]\t";
	$all ++;
}
close IN;
print STDERR "Loading   CONSV file done. Totally $all records.\n";


open IN, "$ARGV[2]" || die( "$!" );
$all = 0;
while( <IN> )
{
	chomp;
	my @line = split /\t/;
	my @tmp = split /\s+/, $line[0];

	next unless exists $LENGTH{$tmp[0]};

	my $orflen = $line[2]-$line[1];
	$ORF{$tmp[0]} = "4:" . $orflen / $LENGTH{$tmp[0]} * 100;
	$ORF{$tmp[0]} .= "\t5:$orflen\t";
	$all ++;
}
close IN;
print STDERR "Loading    ORF  file done. Totally $all records.\n";


open IN, "$ARGV[3]" || die( "$!" );
$all = 0;
while( <IN> )
{
	chomp;
	my @line = split /\t/;
	next unless exists $LENGTH{$line[0]};
	$FEATURE{$line[0]} = "6:$line[1]\t7:$line[2]\t8:$line[3]\t9:$line[4]\t10:$line[5]\t11:$line[6]\t12:$line[7]";
	$all ++;
}
close IN;
print STDERR "Loading FEATURE file done. Totally $all records.\n";


$all = 0;
foreach( keys %CONSV )
{
	if( exists $ORF{$_} && exists $FEATURE{$_} )
	{
		print "$label\t$CONSV{$_}\t$ORF{$_}\t$FEATURE{$_}\t#$_\n";
		$all ++;
	}
}

print STDERR "\nDone.Totally $all records written.\n\n";


