#!/bin/env bash

#SBATCH --job-name=encodingmodelMK2
#SBATCH --partition=witten
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem-per-cpu=4G
#SBATCH --time=6:00:00
#SBATCH --output=logs/%u_%x_%A_%a.out
#SBATCH --mail-user=cz15@princeton.edu
#SBATCH --mail-type=END

cd /jukebox/witten/Chris/matlab/cz/ibl_da_neuropixels_2022/encoding-model/
echo "directory: `pwd`"
echo "user:      `whoami`"
echo "host:      `hostname`"
echo "matlab:    R2019b5"

fpath=$1
module load matlab/R2019b5
mkdir -p /tmp/$USER-$SLURM_JOB_ID-$SLURM_ARRAY_TASK_ID
matlab -nodisplay -r "pause(rand); try; encodingmodel_batch('$fpath',$SLURM_ARRAY_TASK_ID,'CRAC',200); catch me; fprintf('%s\n %s\n %s\n %d\n',me.identifier,me.message,me.stack.file,me.stack.line); end; exit"
rm -rf /tmp/$USER-$SLURM_JOB_ID-$SLURM_ARRAY_TASK_ID
