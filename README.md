# Lycaeides genomic data processing 2023
This repository contains scripts for alignment and variant calling of Lycaeides data set for several projects in the Gompert Lab at Utah State University. However, this is a general pipeline to process Genotyping by Sequencing data and can be used to process this kind of genomic data for any study system. The repository contains folders with scripts for each step. The scripts are also available in this file.

## 1. Initial setup

We are going to create a working directory in a dedicated space in the HPC cluster (/data/$USER) and copy the necessary scripts and data files to run this pipeline.

Connect to UofU HPC cluster (change myuser by your username):

```bash
ssh myuser@kingspeak.chpc.utah.edu
```

Request an interactive session:

```bash
srun --time=1:00:00 --nodes=1 --account=usubio-kp --partition=usubio-kp --pty /bin/bash -l
```
You can use two script editors on the cluster: [Vi](https://www.linuxjournal.com/content/how-use-vi-editor-linux) or [Nano](https://www.nano-editor.org/).

Most programs are installed as modules on the cluster. It is important to note the versions of the program that we use to version control our pipeline. For this round of data processing, we will require the following programs/languages which can be loaded as modules on the cluster as follows:

```bash
module load perl
module load bwa
module load bamtools
module load samtools
module load vcftools
```

## 2. Data 

**GENOME**

For doing the alignments and variant calling for genomic data, we need a reference genome assembly of our target study species or a closely related species. The genome file is in the Fasta format. Read more about this format [here](https://software.broadinstitute.org/software/igv/FASTA#:~:text=A%20FASTA%20file%20is%20a,followed%20by%20the%20sequence%20name.) Additionally, we need to index the genome. Prior to mapping, most aligners require you to construct and index the genome, so that the aligner can quickly and efficiently retrieve reference sequence information.

I have created symbolic link of the **Lycaeides melissa** genome assembly and associated index files in my working directory so that we do not alter the original genome file. We will use this file for all our downstream processing. 

Create symbolic link of file:

```bash
#my working directory: /uufs/chpc.utah.edu/common/home/u6007910/projects/lycaeides_data_processing_2023

#create symbolic link for the genome and index files in the Genome subdirectory
ln -s ln -s /uufs/chpc.utah.edu/common/home/gompert-group3/data/LmelGenome/Lmel_dovetailPacBio_genome.fasta* ./Genome
```
**POPULATION GENOMIC DATA - FASTQ FILES**

Our raw data is in the *fastq* format. The details of these populations are [here] (https://docs.google.com/spreadsheets/d/1BoQ_zMOSQMFbnDQyQUjsOTpUrj0nobVzOOEQ_V504Ak/edit#gid=0). I have organised all these files in this folder: /uufs/chpc.utah.edu/common/home/gompert-group1/data/lycaeides/lycaeides_gbs/Parsed_Sam/

**IN TOTAL WE HAVE 3903 INDIVIDUALS**

Since we are ~3800 files here, we will write out our alignments in the scratch directory on the cluster. Here is the path to my scratch directory:
/scratch/general/nfs1/u6007910/lyc_data_processing_2023

## 3. Alignments

## 4. Variant calling
Total number of individuals = 3903
I followed the following steps for variant calling and filtering. The steps are listed based on the name of the scripts which corresponds to the scripts in the Variants folder.
Step 1. Calling variants from bam files and converting bcf to vcf

Script: 1_variantcalling.sh
Output file: raw_variants.bcf, raw_variants.vcf
The number of variants retained in this file = 3,058,172

2. First round of filtering

Script: 2_vcffilter_af.pl, 2_runvcffilter_af.sh
Output file: filtered2x_variants.vcf
Variants retained after first round of filtering = 145,647

I then got the depth for the retained variants and created a scaffold position SNPs file for the next round of filtering as follows:

```bash
grep ^Sc filtered2x_raw_variants.vcf | cut -f 8 | cut -d ';' -f 1| grep -o '[0-9]*' > depth_filtered2X.txt

grep ^Sc filtered2x_raw_variants.vcf | cut -f 1 | cut -d '_' -f 2 | cut -d ';' -f 1 > scaffold_filtered2X.txt

grep ^Sc filtered2x_raw_variants.vcf | cut -f 2 > positions_filtered2X.txt

paste scaffold_filtered2X.txt positions_filtered2X.txt > snps_filtered2X.txt
```
I then used R to calculate some basic stats about the depth we have for the retained variants.

```R
#calculate coverage for second round of filtering in R
d<-read.table("depth_filtered2X.txt", header=F)
mean = mean(as.numeric(d[,1]))
sd = sd(as.numeric(d[,1]))
cov = mean + 2*sd
```
Here are the basic stats I got for the next round of filtering:
Max depth/cov = 638965
Max depth/cov = 12579
Mean depth/cov = 46473.89
SD depth/cov = 24391.27
Median depth/cov = 40720
#This is what I used for the next step:
cov calculated as mean + 2sd = 95256.44

3. Second round of filtering

Script: 3_vcffilter_somemore.pl
Output file: morefilter_variants.vcf
Variants retained after second round of filtering = 89,294

Here the parameters I specified for the data that I have is as follows:


4. Convert vcf to genotype likelihood file

Script: 4_convert_vcf2gl_depth.pl

Usage:
```perl
perl 4_convert_vcf2gl_depth.pl 0.05 morefilter_variants.vcf #Number of loci: 72937; number of individuals 3912

```
