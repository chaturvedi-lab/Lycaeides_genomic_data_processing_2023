#!/bin/bash
#SBATCH --job-name=genomeindex
#SBATCH --time=140:00:00 #walltime
#SBATCH --nodes=1 #number of cluster nodes
#SBATCH --account=gompert-kp #PI account
#SBATCH --partition=gompert-kp #specify computer cluster, other option is kinspeak

cd /uufs/chpc.utah.edu/common/home/gompert-group1/data/lycaeides/lycaeides_dubois/Variants

module load perl
perl ../Scripts/filterSomeMore.pl filtered2x_variantsLycaeides.vcf
