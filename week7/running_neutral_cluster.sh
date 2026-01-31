#!/bin/bash
#PBS -l walltime=12:00:00
#PBS -l select=1:ncpus=1:mem=1gb
cd $HOME
module load anaconda3/personal
echo "R is about to run"
R --vanilla <$HOME/abc123_HPC_2025_neutral_cluster.R
mv neutral_sim_* $HOME
echo "R has finished running"

