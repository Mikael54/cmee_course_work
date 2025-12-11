#!/bin/bash
#PBS -1 walltime=00:01:00
#PBS -1 select=1:ncpus=1:mem=1gb
module load anaconda3/personal
echo "R is about to run"
R --vanilla <$HOME/abc123_HPC_2025_demographic_cluster.R
mv output_* $HOME  
echo "R has finished running"X
# this comment is the end of the file




# Questions
# Do I need to load my other files to the HPC cluster as well??
# like Demographics.R


# Once I run it everything will be in my HOME directory on the HPC- should I move it to my laptop or not?