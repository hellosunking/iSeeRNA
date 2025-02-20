#!/bin/bash

##
## Author : Ahfyth
##

set -o nounset
set -o errexit

if [ $# -lt 3 ]
then
	echo "Usage: $0 <src.wig.dir> <dest.array.dir> <chr.info>";
	echo
	echo "This program is designed to batch translate wig files to array files for iSeeRNA.";
	echo "The wig files should be named like 'chr?.phastCons.wig.gz' in the <src.wig.dir> where '?' is chromosome number.";
	echo "The <chr.info> file contains the <chrName chrLength> pairs for each chromosome. See 'hg19.info' for reference.";
	echo
	exit 1;
fi

PRG=`dirname $0`/wig2array

if [ ! -e "${PRG}" ]
then
	echo "Error: Program wig2array not found! Please compile it first.";
	exit 2;
fi

while read CHR LEN EXTRA
do
	echo "Dealing ${CHR}, length=${LEN}";
	less $1/${CHR}.phastCons.wig* | ${PRG} ${LEN} /dev/stdin $2/${CHR}.array
done < $3


