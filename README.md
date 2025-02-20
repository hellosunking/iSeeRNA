## iSeeRNA: identify long intergenic non-coding RNA transcripts from transcriptome sequencing data
**Authors**: Kun Sun, Huating Wang, and Hao Sun
**Version**: 1.2.2, Apr 2013
**Software written by**: Kun Sun

Distributed under the Boost Software License; for more information please read the license files in `LICENSE` directory.

If you use this program in your research, please cite:
Sun et al.: **iSeeRNA: identification of long intergenic non-coding RNA transcripts from transcriptome sequencing data.** *BMC Genomics* 2013; 14(Suppl 2):S7.

---
This README file covers the following topics:
1. Installation
2. Prepare iSeeRNA configuration files
3. Prepare iSeeRNA input (GFF/GTF/BED) files
4. Run iSeeRNA
5. iSeeRNA output files explanation
6. Training new models

We define the directory containing this README file `iSeeRNA_ROOT`, and all the following instructions assume that you are in the `iSeeRNA_ROOT` directory.

## 1. Installation
### 1.1 Basic system requirements:
- 64-bit standard linux distribution
- Perl 5.0 or higher

### 1.2 Third party programs:
- txCdsPredict (http://hgdownload.cse.ucsc.edu/admin/jksrc.zip), a utility program from the UCSC Genome Browser to calculate ORF length.
- gffread (http://cufflinks.cbcb.umd.edu/downloads/), a utility program from the `Cufflinks` package to read GFF file.
- libsvm package (http://www.csie.ntu.edu.tw/~cjlin/), an SVM implementation from Chih-Jen Lin, including `svm-scale`, `svm-train`, and `svm-predict`.

### 1.3 Installation
After uncompressing the package, the main program "iSeeRNA" can be found in the same directory as this README file. Note that this package contains the pre-compiled dependent programs. If you cann not run them, please install them using the source codes, then put the binaries into the "bin/" directory; in this case, you may also compile some C++ programs used in iSeeRNA:
```
user@linux$ make clean && make
```

### 1.4 Genomic data
iSeeRNA requires genome fasta files and conservation array files which you may download from UCSC Genome Browser. For conservation, download the `PhastCons` track in wiggle format. These wiggles are seperated into different chromosomes. You need to convert them to array file for iSeeRNA. Array files are much smaller in size and easier to get information for a given genomic position. Before convertion, you need to prepare a file for genome information which contains two columns: chromosome name and length (see "example/hg19.info" for example), let's say "/path/to/genome.info". Assume that all your PhastCons wiggle files are under "/path/to/myGenome/PhastCons.wiggle/" (DO NOT put any file that is not PhastCons wiggle file in this directory) and you want to store the converted array files in "/path/to/myGenome/array/", then you can do convertion by using our utililty:
```
user@linux$ util/Wig2Array/auto_Wig2Array.sh  /path/to/myGenome/PhastCons.wiggle/ /path/to/myGenome/array/ /path/to/genome.info
```

## 2. Prepare iSeeRNA configuration files
Before running iSeeRNA, you need to create a configuration file that contains the parameters. This configuration file has two fields per row: parameter and value. Two fields can be separated by space, tab or '='. Lines starting with '#' are considered as comments. The parameters are case-insensitive but capital letters are recommended. The value field records the absolute path  of the file (recommended) or relative path to the `iSeeRNA_ROOT` directory.

The following parameters are mandatory for running iSeeRNA:
```
GENOME     path to the directory of fasta format genome sequence directory
CONSV      path to the directory of conservation score files directory
SVMMODEL   path to the directory of svm-model files
SVMPARAM   path to the directory of svm-scale parameter files
```
Here is a template configuration file delivered with this package:
```
### start of iSeeRNA configuration file ###
# genome sequences
GENOME     genome/hg19
# conservation array directory
CONSV      consv/hg19
# configure for libsvm
# svm-prediction model location
SVMMODEL   model/hg19.model
# svm-scale parameter location
SVMPARAM   model/hg19.scale.param
### end of iSeeRNA configuration file ###
```

The genomic sequences defined by `GENOME` is a directory which contains the sequeces of all the chromosomes. The names of these sequence files need to start with "chr" followed by chromosome number then '.fa' suffix. For example, "chr1.fa", "chr2.fa", and "chrY.fa".

The conservation array directory defined by `CONSV` is also a directory which contains the conservation array files. The names of these conservation array files need to start with "chr" followed by chromosome number then '.array' suffix. For example, "chr1.array", "chr2.array", and "chrY.array".

## 3. Prepare iSeeRNA input (GFF/GTF/BED) files
The input GTF/GFF/BED files for `iSeeRNA` can be generated from the output file of *de novo* transcript assembly program such as `Cufflinks`. Note that iSeeRNA does not directly support fasta files (see `Utililty` section).

We have provided a testing dataset (`example.gtf`) which contains a list of transcripts from human chromosome 22 in GTF format under the directory "example". Detailed information for GFF/GTF/BED format can be found at: http://genome.ucsc.edu/FAQ/FAQformat.html.

## 4. Run iSeeRNA
To run iSeeRNA on prepared dataset (gff/gtf format):
```
user@linux$ perl iSeeRNA -c CONFIGURATION_FILE -i INPUT_ANNOTATION -o OUTPUT_DIRECTORY
```
This command will instruct `iSeeRNA` to load the configuration file "CONFIGURATION_FILE" (`-c` option), use "INPUT_ANNOTATION" as input annotation file (`-i` option), and prepare sub-directories, makefile, and other required files in "OUTPUT_DIRECTORY" (`-o` option).

If your dataset is in BED format, you need to add '--bed' option:
```
user@linux$ ./iSeeRNA --bed -c CONFIGURATION_FILE -i INPUT_ANNOTATION -o OUTPUT_DIRECTORY
```

For example, to run the example dataset ("example/example.gtf") using the example configuration file ("conf/example.conf") and write output files into "testOut" directory:
```
user@linux$ ./iSeeRNA -c conf/example.conf -i example/example.gtf -o testOut
```

Then go to the OUTPUT_DIRECTORY and run make:
```
user@linux$ cd OUTPUT_DIRECTORY && make
```

For testing purpose, we have provided a script (`run_example.sh`) to run iSeeRNA on the example dataset, please refer to it for more information.

## 5. iSeeRNA output files explanation
The output files will be stored in the directory defined by `-o` option in iSeeRNA command line. For example, if you run run_example.sh, the output directory is "testOut".

There are 12 output files and a subdirectory named "consv" to store intermediate files for conservation score calculation. The output files are named with the same file name as input file but with different suffix representing different outputs or intermediate results.

Here is the list of the expected output files in "testOut" and a brief description:
```
iSeeRNA.conf    a copy of your configuration file
Makefile        Makefile to run prediction
example.gtf     formatted input transcript file
example.fa      transcript sequence file in fasta format
example.feature sequence feature file
example.list    list of input transcript ID
example.orf     ORF length file
example.consv   conservation score file, the sub-directory 'consv' stores intermediate files
example.svm     raw libsvm-format file with all information
example.scaled  scaled svm file
example.predict raw svm-predict ouput file
example.result  final result file
```

The main output of the prediction is "example.result" which has 3 fields separated by tab. The first field is the transcript ID, the second is the predicted types of the transcripts (noncoding or coding), and the third field is the probability of the predicted category of transcripts specified in the field two. The score is a number ranging from 0 to 1 and if the prediction is 'coding', the score should be less than 0.5 and noncoding otherwise. If the prediction is 'noncoding', a higher (close to 1) score means higher confidence But if the prediction is 'coding', a lower (close to 0) score means higher confidence.

Here is the expected testing example output:
```
#id	type	score
ENST00000331428.5	coding	0.00450662
ENST00000359963.3	coding	4.73112e-07
ENST00000438850.1	noncoding	0.778479
ENST00000252835.4	coding	2.70858e-06
ENST00000428118.1	noncoding	0.955258
ENST00000426585.1	noncoding	0.901012
ENST00000400593.2	noncoding	0.936885
ENST00000343518.6	coding	1.82383e-05
```
The scores may be a little bit different depending on your machine's precision for rational number.

## 6. Training new models
We provide a program ("trainNewModel.pl") for training new models for your own species. To train a new model, you need an annotated dataset of lincRNAs and PCTs as Gold-Standard dataset. Typically for a "good" model you need at least 500 lincRNAs and 500 PCTs and we highly recommend you use 1000 or more. You also need to keep the number ratio of lincRNAs and PCTs to 1:1, or the trained model will have a bias towards the one with a larger size. After obtaining the annotation dataset, you need to prepare the genome fasta and conservation files. Then you need to write a "special" configuration file which looks like the one you use for prediction. But the SVMMODEL and SVMPARAM here are used to store the trained model and paramter files. Note that if they point to existing files then these files will be over-written, in this case you should bake up these files or change the values in the configuration file if you do not want to over-write them (the program will check this situation and give you a warning if these files already exist ).

After obtaining the data, run the program :
```
user@linux$ perl trainNewModel.pl -c configure_file -n lincRNA.gff -p mRNA.gff -o work_dir
```
then change to work_dir and run make:
```
user@linux$ cd work_dir && make
```
After this command finishes, the output svm parameter file and svm model file are generated using the path defined in your configuration file. This configuration file can be directly used by iSeeRNA without any changes made.

---
Please send bug reports to: sunkun@szbl.ac.cn
iSeeRNA is available at http://github.com/hellosunking/iSeeRNA/.