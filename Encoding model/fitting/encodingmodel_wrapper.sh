#!/bin/env bash

#SBATCH --job-name=wrapper
#SBATCH --partition=witten
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=20G
#SBATCH --time=2:00:00
#SBATCH --output=logs/%u_%x_%A.out
#SBATCH --mail-user=cz15@princeton.edu
#SBATCH --mail-type=END

cd /jukebox/witten/Chris/matlab/cz/ibl_da_neuropixels_2022/encoding-model/
echo "directory: `pwd`"
echo "user:      `whoami`"
echo "host:      `hostname`"
echo "matlab:    R2019b5"

module load matlab/R2019b5
matlab -nodisplay -r "try; encodingmodel_wrapper; catch me; fprintf('%s\n %s\n %s\n %d\n',me.identifier,me.message,me.stack.file,me.stack.line); end; exit"