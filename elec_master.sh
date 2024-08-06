#!/bin/bash
#
#SBATCH --account=b1134                	# Our account/allocation
#SBATCH --partition=buyin      		# 'Buyin' submits to our node qhimem0018
#SBATCH --mem=15GB
#SBATCH -t 30:00:00
#SBATCH --job-name eleczoom
#SBATCH -o /projects/b1134/processed/elec_zoom/logs/eleczoom_%A_%a.out
#SBATCH -e /projects/b1134/processed/elec_zoom/logs/eleczoom_%A_%a.err
##############################
#Description: Master script for creating electrode visualiztion pdf for BNI participants
#electrodes must be localized in Bioimages suite ahead of time, and several scripts must be run afterwards in order to create the file brainmask_coords_0_wlabels, as well as individual 3mm volumetric sphere files.
#
#Usage: sbatch /projects/b1134/tools/electrode_visualization/elec_master.sh SUBJECTID

SubjectID=$1
## cut out small CT, T1, and BOLD images and overlay electrode spheres
sh /projects/b1134/tools/electrode_visualization/elec_zoomer.sh $SubjectID

#create iELVIS pictures
module load freesurfer/7.1
source $FREESURFER_HOME/SetUpFreeSurfer.sh
SUBJECTS_DIR=/projects/b1134/processed/fs/$SubjectID
module load matlab/r2020b
matlab -batch "addpath('/projects/b1134/tools/electrode_visualization');elec_plotter('$SubjectID')"

#arrange images on a pdf
module load fftw/3.3.3-gcc
module load R/4.0.3
Rscript /projects/b1134/tools/electrode_visualization/elec_combiner.R $SubjectID


