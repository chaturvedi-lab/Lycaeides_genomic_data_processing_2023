#!/bin/bash
#SBATCH --job-name=parsebarcodes
#SBATCH --time=140:00:00 #walltime
#SBATCH --nodes=1 #number of cluster nodes
#SBATCH --account=usubio-kp #PI account
#SBATCH --partition=usubio-kp #specify computer cluster, other option is kinspeak

## This script is to run the parse_barcodes.pl script on the cluster


cd /uufs/chpc.utah.edu/common/home/gompert-group1/data/lycaeides/lycaeides_dubois/Alignments/fastqfiles

module load perl
module load bwa
perl wrap_qsub_slurm_bwa_mem.pl *.fastq
