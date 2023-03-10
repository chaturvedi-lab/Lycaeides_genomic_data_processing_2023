# Lycaeides genomic data processing 2023
This repository contains scripts for general processing of genomic data. Scripts are available for dealing with raw date to generating final VCF and genotype likelihood files. 

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

Most programs are installed as modules on the cluster. It is important to note the versions of the program that we use to version control our pipeline. For this program we will require the following programs/languages which can be loaded as modules on the cluster as follows:

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

Since we are ~3800 files here, we will write out our alignments in the scratch directory on the cluster. 

## 3. Alignments
