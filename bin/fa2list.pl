#!/usr/bin/perl

#
# Author : Ahfyth
#

use strict;
use warnings;

if( $#ARGV < 0 )
{
	print STDERR "\nUsage : $0 <input.fa> [output]\n";
	print STDERR "\nThis program is designed to generate the list of the fasta.\n\n";
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
		my ($realid, $unk) = split /\s+/, $id, 2;
		print "$realid\t", length( $fa ), "\n";
		$fa = '';
		$id = $_;
		next;
	}
	chomp;
	$fa .= uc($_);
}
close IN;

my ($realid, $unk) = split /\s+/, $id, 2;
print "$realid\t", length( $fa ), "\n";

if( $#ARGV > 0 )
{
	close OUT;
}

