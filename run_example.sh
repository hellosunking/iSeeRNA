#!/bin/bash

#
# Author: Ahfyth
#

URL_FA='http://sunlab.lihs.cuhk.edu.hk/iSeeRNA/data/hg19/genome/chr22.fa.bz2'
URL_CONSV='http://sunlab.lihs.cuhk.edu.hk/iSeeRNA/data/hg19/consv/chr22.array.bz2'


echo 'This is the example shell script for running iSeeRNA on the example dataset.'
echo 'Note that he output message of iSeeRNA are not shown here.'
echo
echo 'The original input file is "example/example.gtf".'
echo
#cat example/example.gtf

echo 'Checking dependent files ...'
if [ -e 'example/chr22.fa' ]
then
	echo 'Fasta file found.'
else
	echo 'Genome fasta file not found! I will try to download it from the web.'
	echo
	cd example;
	wget ${URL_FA}
	echo
	if [ $? != 0 ] || [ ! -e 'chr22.fa.bz2' ]
	then
		echo 'Error: cannot download file! please check your network.'
		exit 1;
	fi
	bzip2 -d chr22.fa.bz2
	cd ..
fi

if [ -e 'example/chr22.array' ]
then
	echo 'Conservation file found.'
else
	echo 'Conservation file not found! I will try to download it from the web.'
	echo
	cd example;
	wget ${URL_CONSV}
	echo
	if [ $? != 0 ] || [ ! -e 'chr22.array.bz2' ]
	then
		echo 'Error: cannot download file! please check your network.'
		exit 2;
	fi
	bzip2 -d chr22.array.bz2
	cd ..
fi

echo
# prepare makefile
echo 'Prepare Makefile:'
echo './iSeeRNA -c example/example.conf -i example/example.gtf -o testOut'
[ -d 'testOut' ] && rm -rf testOut;
./iSeeRNA -c example/example.conf -i example/example.gtf -o testOut

echo
# run prediction
echo 'Run prediction:'
echo 'cd testOut && make'
cd testOut && make >& /dev/null
echo

echo 'Change back to iSeeRNA directory:'
echo 'cd ..'
cd ..

echo
echo 'The prediction result is stored in testOut/example.result:'
echo
cat testOut/example.result

echo
echo 'For more information please refer to the README file.'
echo

