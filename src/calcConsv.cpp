
#include <iostream>
#include <fstream>
#include <string>
#include <sstream>
#include <vector>
#include <map>
#include <stdio.h>
#include <stdlib.h>
#include <memory.h>

using namespace std;

/*
 * Author : Ahfyth
 */

const unsigned int MAXEXON = 1<<14;		// 16K
const unsigned int MAXGENE = 1<<24;		// 16M

int main( int argc, char *argv[] )
{
	if( argc != 4 )
	{
		cerr << "\nUsage: " << argv[0] << " <array.file> <input.anno> <output.dat>\n";
		cerr << "\nThis program is designed to calculate the conservation value for the gene annotations.\n\n";
		return 1;
	}

	FILE * fp = fopen( argv[1], "rb" );
	if( fp == NULL )
	{
		cerr << "Error : open array file failed.\n";
		return 2;
	}
	fseek( fp, 0, SEEK_END );
	unsigned int len = ftell( fp );
	unsigned char * consv = new unsigned char [len];
	fseek( fp, 0, SEEK_SET );
	cout << "Loading array : " << len << '\n';
	fread( consv, sizeof(unsigned char), len, fp );
	fclose( fp );

	ifstream fin( argv[2] );
	if( fin.fail() )
	{
		cerr << "Error : open input.anno failed!\n";
		delete [] consv;
		return 2;
	}
	ofstream fout( argv[3] );
	if( fout.fail() )
	{
		cerr << "Error : write file failed.\n";
		fin.close();
		delete [] consv;
		return 4;
	}

	unsigned int * exonpos = new unsigned int [ MAXEXON ];

	string line;
	stringstream ss;

	string transcript;
	unsigned long allexon, allintron;
	register unsigned int i, j, k;
	unsigned int exoncount, exonlen, intronlen;
	register bool flag;

	cerr << "Loading anno file ...\n";
	while( 1 )
	{
		if( ! getline( fin, line ) )
			break;

		ss.str( line );
		ss.clear();
		ss >> transcript >> exoncount;

		if( exoncount == 1 )
		{
			ss >> exonpos[0] >> exonpos[1];
			allexon = 0;
			for( i=exonpos[0]; i<=exonpos[1]; ++i )
			{
				allexon += (unsigned int)consv[i];
			}
			fout << transcript << '\t' << exoncount << '\t' << allexon*1.0/(exonpos[1]-exonpos[0]+1) << '\n';
		}
		else
		{
			k = 0;
			for( i=0; i<exoncount; ++i )
			{
				ss >> exonpos[k++];
				ss >> exonpos[k++];
			}
			allexon = 0;
			allintron = 0;
			exonlen = 0;
			intronlen = 0;
			flag = true;
			-- k;
//			cerr << "Begin : " << allexon << allintron << exonlen << intronlen << '\n';
			for( i=0; i<k; ++i )
			{
				if( flag )	//exon
				{
					for( j=exonpos[i]; j<=exonpos[i+1]; ++j )
					{
						allexon += (unsigned int)consv[j];
					}
					exonlen += exonpos[i+1] - exonpos[i] + 1;
//					cerr << "Exon  : " << exonpos[i] << '-' << exonpos[i+1] << '\t' << allexon << '/' << exonlen << '\n';
					flag = false;
				}
				else
				{
					for( j=exonpos[i]+1; j<exonpos[i+1]; ++j )
					{
						allintron += (unsigned int)consv[j];
					}
					intronlen += exonpos[i+1] - exonpos[i] - 1;
//					cerr << "Intron  : " << exonpos[i] << '-' << exonpos[i+1] << '\t' << allintron << '/' << intronlen << '\n';
					flag = true;
				}
			}
			fout << transcript << '\t' << exoncount << '\t' << allexon*1.0/exonlen << '\t' << allintron*1.0/intronlen << '\t'
				 << (allexon+allintron)*1.0/(exonlen+intronlen) << '\n';
		}
	}
	fin.close();
	fout.close();

	cerr << "All Done.\n";

	delete [] exonpos;
	delete [] consv;

	return 0;
}


