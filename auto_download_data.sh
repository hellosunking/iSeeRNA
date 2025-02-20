#!/bin/bash

#
# Author: Ahfyth
#

if [ -z "$1" ]
then
	echo
	echo "Usage: $0 <hg19|mm9|mm10|all>"
	echo
	echo "This script is designed to download files for iSeeRNA from our website.";
	echo "Currently our website only support data for hg19 and mm9/mm10, for other species, please prepare them yourself.";
	echo "The genome fasta files will be put into genome/ directory and conservation files will be put into consv/ directory,";
	echo "which is just as the records in the configure files in the conf/ directory.";
	echo
	exit 1;
fi

cd `dirname $0`;

## test whether tar support xz file
tar cJf /tmp/testXz.tar.xz /dev/null 2>/dev/null
if [ $? -eq 0 ]
then
	echo "Info: Your tar supports xz format.";
	TAROPT="xJf";		## uncompress option for tar
	TARSUF="tar.xz";	## file suffix for tar
else
	echo "Info: Your tar does not support xz format, use bz2 instead.";
	TAROPT="xjf";
	TARSUF="tar.bz2";
fi

download()
{
	TARGET=$1
	BASE="http://sunlab.lihs.cuhk.edu.hk/iSeeRNA/data";

	echo "Downloading data for ${TARGET}";
	mkdir -p consv/${TARGET}
	cd consv/${TARGET}
	wget ${BASE}/${TARGET}/consv.${TARSUF}
	echo "Uncompressing file ..."
	tar ${TAROPT} consv.${TARSUF}
	mv consv/* .
	rm -rf consv.${TARSUF} consv
	cd ../../
	mkdir -p genome/${TARGET}
	cd genome/${TARGET}
	wget ${BASE}/${TARGET}/genome.${TARSUF}
	echo "Uncompressing file ..."
	tar ${TAROPT} genome.${TARSUF}
	mv genome/* .
	rm -rf genome.${TARSUF} genome
	cd ../../

	if [ ${TARGET} == 'hg19' ]
	then
		echo "Preparing for running example dataset ...";
		cd example/
		[ -e "chr22.fa" ] || ln -s ../genome/hg19/chr22.fa .
		[ -e "chr22.array" ] || ln -s ../consv/hg19/chr22.array .
	fi
}


if [ $1 == 'hg19' ] || [ $1 == 'mm9' ] || [ $1 == 'mm10' ]
then
	download $1;
elif [ $1 == 'all' ]
then
	download hg19;
	download mm9;
	download mm10;
else
	echo "Error: parameter must be hg19/mm9/mm10 or all.";
	exit 2;
fi

