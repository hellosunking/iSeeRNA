
#include <iostream>
#include <fstream>
#include <string>
#include <sstream>
#include <stdio.h>
#include <stdlib.h>
#include <memory.h>
using namespace std;

/*
 * Author : Ahfyth
 */

int main( int argc, char *argv[] )
{
	if( argc != 4 )
	{
		cerr << "\nUsage : " << argv[0] << " <length> <input.wig> <output>\n";
		cerr << "\nThis program is designed to translate the input wiggle data( between 0-1 ) to an char array.\n\n";

		return 1;
	}

	cout << "Use len : " << argv[1] << '\n'
		 << "Use wig : " << argv[2] << '\n'
		 << "Use out : " << argv[3] << '\n';

	ifstream fin( argv[2] );
	if( fin.fail() )
	{
		cerr << "Error open file.\n";
		return 2;
	}

	unsigned int len = atoi( argv[1] );
	unsigned char * dat = new unsigned char[ len + 1 ];
	memset( dat, 0, len+1 );

	string line;
	register unsigned int i, j, curr=1;

	while( 1 )
	{
		getline( fin, line );
		if( fin.eof() )break;

		if( line[0] == 'f' )	//
		{
			i = line.find( "start" );
			j = line.length();
			curr = 0;
			for( i+=6; i!=j; ++i )
			{
				if( line[i] == ' ' )break;
				curr *= 10;
				curr += line[i] - '0';
			}
		}
		else
		{
			dat[curr++] = (unsigned char)( atof(line.c_str()) * 255 );
		}
	}
	fin.close();

	FILE * fp = fopen( argv[3], "wr");
	if( fp == NULL )
	{
		delete [] dat;
		return 4;
	}
	fwrite( dat, sizeof(unsigned char), len+1, fp );
	fclose( fp );

	delete [] dat;

	return 0;
}


