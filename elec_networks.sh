#!/bin/bash
#
#SBATCH --account=b1134                	# Our account/allocation
#SBATCH --partition=buyin      		# 'Buyin' submits to our node qhimem0018
#SBATCH --mem=4GB
#SBATCH -t 8:00:00
#SBATCH --job-name elecnetwork
#SBATCH -o /projects/b1134/processed/elec_zoom/logs/elecnetwork_%A_%a.out
#SBATCH -e /projects/b1134/processed/elec_zoom/logs/elecnetwork_%A_%a.err
##############################
#For appreciating orientation of electrode ROIs and networks in volume space.
#This package of scripts takes a surface-based parcellation file in workbench format,
#converts it into a volume-based parcellation file in freesurfer format, and then takes
#zoomed in images around each electrode and organizes them into one pdf document.
#Created in January 2023 by Chris Cyr
#USAGE: sbatch elec_networks.sh $SUB $parcdir

module purge
module load fsl
. ${FSLDIR}/etc/fslconf/fsl.sh
module load freesurfer/7.3.2
source $FREESURFER_HOME/SetUpFreeSurfer.sh 
module load matlab/r2020b

SUB=$1
parcdir=$2

BASEDIR=/projects/b1134
SUBJECTS_DIR=$BASEDIR/processed/fs/$SUB
FSPATH=$BASEDIR/processed/fs/$SUB/$SUB
coordir=$FSPATH/elec_recon
SPHEREDIR=$BASEDIR/analysis/elec2roi/${SUB}/elecs_vol_3mm
OUTDIR=/projects/b1134/processed/elec_zoom/$SUB
mkdir -p $OUTDIR
mkdir -p $OUTDIR/niftis
mkdir -p $OUTDIR/pngs

#convert surface-based parcellation workbench file to surface-based freesurfer file
matlab -batch "addpath('$BASEDIR/tools/electrode_modeling'); parcellations_wb2fs('$parcdir'); exit"

#convert parcellations from surface to volume
surface=/projects/b1134/processed/fs/${SUB}/${SUB}_41k/surf/lh.orig
overlay=${parcdir}/lh_parcellations.thickness
mri_surf2vol --so $surface $overlay --o ${parcdir}/lh_parcellations.nii.gz --subject ${SUB}_41k

surface=/projects/b1134/processed/fs/${SUB}/${SUB}_41k/surf/rh.orig
overlay=${parcdir}/rh_parcellations.thickness
mri_surf2vol --so $surface $overlay --o ${parcdir}/rh_parcellations.nii.gz --subject ${SUB}_41k

#Path to T1
t1img=$coordir/T1.nii.gz

#Path to volumetric parcellations
parcimg_l=$parcdir/lh_parcellations.nii.gz
parcimg_r=$parcdir/rh_parcellations.nii.gz
parcimg=$parcdir/wb_parcellations.nii.gz
#combine hemispheres
fslmaths $parcimg_l -add $parcimg_r $parcimg

#split up by network
OLDIFS=$IFS
IFS='/'
read -a info <<< "$parcdir"
end=${#INPATH[*]}
IFS=$OLDIFS
knumber=${info[end-1]}
SUB=${info[end-5]}
for k in $(seq 1 $knumber); do 
	3dcalc -a $parcimg -expr "equals(a,${k})" -prefix $parcdir/wb_parcellations_${k}
	3dAFNItoNIFTI -prefix $parcdir/wb_parcellations_${k}.nii.gz $parcdir/wb_parcellations_${k}+orig
	rm $parcdir/wb_parcellations_${k}+orig*
done

module purge
module load freesurfer
source $FREESURFER_HOME/SetUpFreeSurfer.sh

cat $coordir/${SUB}_bipolarelectrodeNames.txt | while read line
do
i=$line
echo $i
#Path to stim site ROIs
elec1label=$(echo $i | cut -d "-" -f 1)
elec1file=`ls ${SPHEREDIR}/${elec1label}_sphere*nii.gz 2> /dev/null`
elec2label=$(echo $i | cut -d "-" -f 2)
elec2file=`ls ${SPHEREDIR}/${elec2label}_sphere*nii.gz 2> /dev/null`

#calculate ROI central coordinates
x1=$(echo $elec1file | cut -d "_" -f 5)
x2=$(echo $elec2file | cut -d "_" -f 5)
x=$(((x1+x2)/2))
y1=$(echo $elec1file | cut -d "_" -f 6)
y2=$(echo $elec2file | cut -d "_" -f 6)
y=$(((y1+y2)/2))
z1info=$(echo $elec1file | cut -d "_" -f 7)
z1=$(echo $z1info | cut -d "." -f 1)
z2info=$(echo $elec2file | cut -d "_" -f 7)
z2=$(echo $z2info | cut -d "." -f 1)
z=$(((z1+z2)/2))

#load everything into Freeview and take pictures
freeview -v ${t1img}:colormap=grayscale:grayscale=25,99.5:percentile=yes ${parcimg}:colormap=lut:lut=$parcdir/Network_colors.txt ${elec1file}:colormap=binary:opacity=0.85 ${elec2file}:colormap=binary:opacity=0.85 -viewport sagittal -viewsize 280 168 -slice $x $y $z -cc -zoom 2 -ss ${OUTDIR}/pngs/${elec1label}-${elec2label}_stimROI_parc_T1_sag.png

freeview -v ${t1img}:colormap=grayscale:grayscale=25,99.5:percentile=yes ${parcimg}:colormap=lut:lut=$parcdir/Network_colors.txt ${elec1file}:colormap=binary:opacity=0.85 ${elec2file}:colormap=binary:opacity=0.85 -viewport axial -viewsize 280 168 -slice $x $y $z -cc -zoom 2 -ss ${OUTDIR}/pngs/${elec1label}-${elec2label}_stimROI_parc_T1_ax.png

freeview -v ${t1img}:colormap=grayscale:grayscale=25,99.5:percentile=yes ${parcimg}:colormap=lut:lut=$parcdir/Network_colors.txt ${elec1file}:colormap=binary:opacity=0.85 ${elec2file}:colormap=binary:opacity=0.85 -viewport coronal -viewsize 280 168 -slice $x $y $z -cc -zoom 2 -ss ${OUTDIR}/pngs/${elec1label}-${elec2label}_stimROI_parc_T1_cor.png

done

#arrange images on a pdf
module load fftw/3.3.3-gcc
module load R/4.0.3
Rscript /projects/b1134/tools/electrode_visualization/elec_networks.R $SUB

