#!/usr/bin/perl

#
# Author : Ahfyth
#

use strict;
use warnings;

if( $#ARGV < 0 )
{
	print STDERR "\nUsage : $0 <input.fa> [output]\n";
	print STDERR "\nThis program is designed to calculate the features of the fasta.\n\n";
	exit 1;
}


open IN, "$ARGV[0]" || die( "$!" );

if( $#ARGV > 0 )
{
	open OUT, ">$ARGV[1]" || die( "$!" );
	select OUT;
}

my $id = <IN>;
$id =~ s/^>//;
my $fa = '';
while( <IN> )
{
	if( $_=~ s/^>// )
	{
		deal( $id, \$fa );
		$fa = '';
		$id = $_;
		next;
	}
	chomp;
	$fa .= uc($_);
}
close IN;

deal( $id, \$fa );

if( $#ARGV > 0 )
{
	close OUT;
}



sub deal
{
	my $id = shift;
	my $fa = shift;

	my ($realid, $unk) = split /\s+/, $id, 2;

	my $len = length( $$fa );

#	print "len : $len\n$$fa\n";
	my $CG  = $$fa =~ s/CG/CG/g;
	my $CT  = $$fa =~ s/CT/CT/g;
	my $TAG = $$fa =~ s/TAG/TAG/g;
	my $ACG = $$fa =~ s/ACG/ACG/g;
	my $TCG = $$fa =~ s/TCG/TCG/g;

#	print "CG:$CG\tCT:$CT\tTAG\t$TAG\tACG\t$ACG\tTCG\t$TCG\n";
	$CG /= $len - 1;
	$CT /= $len - 1;
	$TAG /= $len - 2;
	$ACG /= $len - 2;
	$TCG /= $len - 2;
#	print "CG:$CG\tCT:$CT\tTAG\t$TAG\tACG\t$ACG\tTCG\t$TCG\n";

	my $TGT = 0;
	for( my $i=0; $i<$len-2; ++$i )
	{
		my $here = substr( $$fa, $i, 3 );
		++$TGT if $here eq 'TGT';
	}
	$TGT /= $len - 2;

	#Amino Acid 'A' <- GCN
	my ($a0, $a1, $a2) = ( 0, 0, 0 );
	for( my $i=0; $i<$len-2; $i+=3 )
	{
		my $here = substr( $$fa, $i, 2 );
		++$a0 if $here eq 'GC';
	}
	for( my $i=1; $i<$len-2; $i+=3 )
	{
		my $here = substr( $$fa, $i, 2 );
		++$a1 if $here eq 'GC';
	}
	for( my $i=2; $i<$len-2; $i+=3 )
	{
		my $here = substr( $$fa, $i, 2 );
		++$a2 if $here eq 'GC';
	}
	my $a = ($a0+$a1+$a2)/3;
	$a /= $len - 2;

	print "$realid\t$CG\t$a\t$TAG\t$TGT\t$ACG\t$TCG\t$CT\n";
}


