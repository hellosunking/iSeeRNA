#!/usr/bin/perl

#
# Author : Ahfyth
#

use strict;
use warnings;

use Getopt::Long;

my $conffile;
my ($lincfile, $mfile);
my $outdir;
    
GetOptions
(
 "conf|c:s" => \$conffile,
 "pos|p:s"  => \$lincfile,
 "neg|n:s"  => \$mfile,
 "out|o:s"  => \$outdir,
);

unless( $conffile && $lincfile && $mfile && $outdir )
{
	print STDERR "\nUsage : $0 -c configure_file -n lncRNA.gff -p mRNA.gff -o work_dir\n";
	print STDERR "\nThis program is designed to prepare data and Makefile for make models.";
	print STDERR "\nNote : this program uses the path of SVMMODEL and SVMPARAM in your configuration file for outputs.";
	print STDERR "\nSee README file for more information.\n\n";
	exit 1;
}

my $pwd = `pwd`;
chomp( $pwd );
my $root;
if( $0 =~ /^\// ){$root = $0;}
else{$root = "$pwd/$0";}
$root =~ s/\/[^\/]*$//;
$root = "$root/..";

my $prg = "$root/bin";

$lincfile = "$pwd/$lincfile" unless( $lincfile =~ /^\// );
my $lincbase = $lincfile;
$lincbase =~ s/^.*\///;
$lincbase =~ s/\.g[tf]f$//;

$mfile = "$pwd/$mfile" unless( $mfile =~ /^\// );
my $mbase = $mfile;
$mbase =~ s/^.*\///;
$mbase =~ s/\.g[tf]f$//;

if( $lincbase eq $mbase )
{
	print STDERR "Error : your lincRNA.gtf and mRNA.gtf file have the same name !\n";
	exit 200;
}

open IN, "$conffile" || die( "$!" );
my %conf;
while( <IN> )
{
	chomp;
	next if $_=~ /^#/;
	next unless $_;

	my @tmp = split /[\s=]+/;
	$tmp[1] = "$root/$tmp[1]" unless( $tmp[1] =~ /^\// );
	$conf{ uc($tmp[0]) } = $tmp[1];
#	print "$tmp[0] => $tmp[1]\n";
}
close IN;

my $GENOME	= $conf{ 'GENOME'	};
my $CONSV	= $conf{ 'CONSV'	};
my $model	= $conf{ 'SVMMODEL' };	# here it is the target
my $param	= $conf{ 'SVMPARAM' };  # here it is the target


my $THREAD	= $conf{ 'THREAD'	} || 1;
$THREAD =~ s/^.*\///;

unless( $GENOME && $CONSV && $model && $param )
{
	print STDERR "\nError : configure file not complete !\n";
	exit 2;
}

my $modelbase = $model;
$modelbase =~ s/\/[^\/]*$//;
unless( -e $modelbase )
{
	system "mkdir -p $modelbase";
}
my $parambase = $param;
$parambase =~ s/\/[^\/]*$//;
unless( -e $parambase )
{
	system "mkdir -p $parambase";
}

if( -e $outdir )
{
    print STDERR "\n\nWARNING : Directory '$outdir' EXISTS !\n\n";
}
else
{
    system "mkdir -p $outdir";
}

system "mkdir -p $outdir/linc_consv";
system "mkdir -p $outdir/m_consv";


open MK, ">$outdir/Makefile" || die( "$!" );
select MK;

print "all.finished : all.model all.scaled\n\tcp all.model $model && cp scale.param $param && touch all.finished\n\n";


print "all.model : all.scaled\n\t$prg/svm-train -c 512 -g 1 -b 1 all.scaled all.model\n";
print "all.scaled : all.svm\n\t$prg/svm-scale -l 0 -s scale.param all.svm > all.scaled\n";

print "all.svm : $lincbase.svm $mbase.svm\n\tcat $lincbase.svm $mbase.svm > all.svm\n";

# lincRNA.svm
print "$lincbase.svm : $lincbase.list $lincbase.orf $lincbase.feature all_$lincbase.consv\n\tperl $prg/merge.pl $lincbase.list all_$lincbase.consv $lincbase.orf $lincbase.feature -1 > $lincbase.svm\n\n";
print "$lincbase.gtf : $lincfile\n\t$prg/gffread -o /dev/stdout $lincfile | perl -ne 'print unless /^#/' | perl -ne '\$\$_=\"chr\$\$_\" unless /^chr/; \$\$_=~s/Parent=/transcript_id /; print ' > $lincbase.gtf\n\n";
print "$lincbase.fa : $lincbase.gtf\n\t$prg/gffread -g $GENOME -w $lincbase.fa $lincbase.gtf\n\n";
print "$lincbase.list : $lincbase.fa\n\tperl $prg/fa2list.pl $lincbase.fa $lincbase.list\n\n";
print "$lincbase.feature : $lincbase.fa\n\tperl $prg/fa2feature.pl $lincbase.fa $lincbase.feature\n\n";
print "$lincbase.orf : $lincbase.fa\n\t$prg/txCdsPredict -anyStart $lincbase.fa $lincbase.orf\n\n";
print "linc_consv/Makefile : $lincbase.gtf\n\tcd linc_consv && perl $prg/prepare_consv.pl ../$lincbase.gtf $CONSV $prg/calcConsv all_$lincbase.consv > Makefile && cd ..\n\n";
print "all_$lincbase.consv : linc_consv/Makefile\n\tcd linc_consv && make -j $THREAD && cd ..\n\n";

# mRNA.svm
print "$mbase.svm : $mbase.list $mbase.orf $mbase.feature all_$mbase.consv\n\tperl $prg/merge.pl $mbase.list all_$mbase.consv $mbase.orf $mbase.feature 1 > $mbase.svm\n\n";
print "$mbase.gtf : $mfile\n\t$prg/gffread -o /dev/stdout $mfile | perl -ne 'print unless /^#/' | perl -ne '\$\$_=\"chr\$\$_\" unless /^chr/; \$\$_=~s/Parent=/transcript_id /; print ' > $mbase.gtf\n\n";
print "$mbase.fa : $mbase.gtf\n\t$prg/gffread -g $GENOME -w $mbase.fa $mbase.gtf\n\n";
print "$mbase.list : $mbase.fa\n\tperl $prg/fa2list.pl $mbase.fa $mbase.list\n\n";
print "$mbase.feature : $mbase.fa\n\tperl $prg/fa2feature.pl $mbase.fa $mbase.feature\n\n";
print "$mbase.orf : $mbase.fa\n\t$prg/txCdsPredict -anyStart $mbase.fa $mbase.orf\n\n";
print "m_consv/Makefile : $mbase.gtf\n\tcd m_consv && perl $prg/prepare_consv.pl ../$mbase.gtf $CONSV $prg/calcConsv all_$mbase.consv > Makefile && cd ..\n\n";
print "all_$mbase.consv : m_consv/Makefile\n\tcd m_consv && make -j $THREAD && cd ..\n\n";

print "clean :\n\trm -rf *consv*\n";

close MK;

print STDERR "Done. Change directory to $outdir and run make.\nThe final scale-parameter file is '$model' and the final model is '$param'.\n\n";


