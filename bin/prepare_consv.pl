#!/usr/bin/perl

#
# Author : Ahfyth
#

use strict;
use warnings;

if( $#ARGV < 2 )
{
	print STDERR "\nUsage: $0 <input.gtf> <consv> <prg> <target>\n";
	print STDERR "\nThis program is designed to prepare data and Makefile for calculating conservation.\n\n";
	exit 1;
}


my $consv = $ARGV[1];
my $prg = $ARGV[2];
my $target = $ARGV[3];

my $status = 'exon';

my %gtf = ();
my %chr = ();
my %tmp = ();
open GTF, "$ARGV[0]" or die( "$!" );
print STDERR "Loading gtf ...\n";
while( <GTF> )
{
	chomp;
	my @line = split /\t/;	#chr unk exon start end . strand . anno

	next unless $line[2] eq $status;
	next unless $line[-1] =~ /transcript_id/;

	my $CHR = $line[0];
	my $s = $line[3];
	my $e = $line[4];

	my $key = $line[-1];
	$key =~ s/transcript_id //;
	push @{$gtf{$key}}, $s-1;
	push @{$gtf{$key}}, $e+1;
	unless( exists $tmp{$key} )
	{
		push @{$chr{$CHR}}, $key;
		$tmp{$key} = 0;
	}
}
close GTF;
print STDERR "Loading gtf done...\n";

my @all = keys %chr;
foreach my $chr( @all )
{
	print STDERR "Writing $chr ...";
	open OUT, ">$chr.dat"  or die( "$!" );
	open LST, ">$chr.list" or die( "$!" );
	my $count = 0;
	foreach( @{$chr{$chr}} )
	{
		my @sorted = sort { $a <=> $b } @{$gtf{$_}};
		my $len = ($#sorted + 1) >> 1;
		print OUT "$_\t$len\t", join( "\t", @sorted ), "\n";
		print LST "$_\n";
		$count ++;
	}
	close OUT;
	close LST;
	print STDERR "Done $count .\n" ;
}

print "$target: ", join( ".consv\t", @all ), ".consv\n\tcat chr*.consv > ../$target\n\n";

print "CONSV:=$consv\n";
print "CALC:=$prg\n";

foreach( @all )
{
	print "$_.consv: $_.dat \$(CONSV)/$_.array\n";
	print "\t\$(CALC) \$(CONSV)/$_.array $_.dat $_.consv\n";
}


