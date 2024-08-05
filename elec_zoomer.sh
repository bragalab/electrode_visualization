
# Code for visualizing electrode contact coordinates obtained from manual localization using BioImage Suite

# Code by Chris Cyr - December 2023

# Usage: sh /projects/b1134/tools/electrode_visualization/elec_zoomer.sh ATHUAT

module purge
module load fsl
module load freesurfer
source $FREESURFER_HOME/SetUpFreeSurfer.sh
SUB=$1

BASEDIR=/projects/b1134

FSPATH=$BASEDIR/processed/fs/$SUB/$SUB
coordir=$FSPATH/elec_recon
coords=$coordir/brainmask_coords_0_wlabels.txt
SPHEREDIR=$BASEDIR/analysis/elec2roi/$SUB/elecs_vol_3mm
BOLDDIR=$BASEDIR/processed/iProc/BNI/$SUB/cross_session_maps

OUTDIR=/projects/b1134/processed/elec_zoom/$SUB
mkdir -p $OUTDIR/pngs

#Paths to CT, T1 and mean BOLD
ctimg=$coordir/postInPre.nii.gz
ctimg_thresh=$coordir/postInPre_thresholded.nii.gz
t1img=$coordir/T1.nii.gz
mbimg=$BOLDDIR/allscans-oc_anat_mean_concat.nii.gz
mbimgreorient=$BOLDDIR/allscans-oc_onT1_anat_mean_concat.nii.gz

#orient Bold to T1/CT
if [ -f $mbimg ];
then
	fslswapdim $mbimg x -z y $mbimgreorient
fi

#Loop over each line in the brainmask_coord_0 
OLDIFS=$IFS

IFS=$'\n'
set -f

for i in $(cat $coordir/brainmask_coords_0_wlabels.txt)
do

IFS=$OLDIFS #reset internal field separator
set +f


label=$(echo $i | awk '{print $1}')
x=$(echo $i | awk '{print $2}')
y=$(echo $i | awk '{print $3}')
z=$(echo $i | awk '{print $4}')

echo $label $x $y $z

sphere=$SPHEREDIR/${label}_sphere_${x}_${y}_${z}.nii.gz

#unthresholded CT images
freeview -v ${ctimg}:colormap=grayscale:grayscale=0,3000 ${sphere}:colormap=binary:binary_color=red:opacity=0.5 -viewsize 300 300 -viewport sagittal -zoom 10 -slice $x $y $z -cc -ss ${OUTDIR}/pngs/${label}_elecROI_CT_zoom_sag.png

freeview -v ${ctimg}:colormap=grayscale:grayscale=0,3000 ${sphere}:colormap=binary:binary_color=red:opacity=0.5 -viewsize 300 300 -viewport coronal -zoom 10 -slice $x $y $z -cc -ss ${OUTDIR}/pngs/${label}_elecROI_CT_zoom_cor.png

freeview -v ${ctimg}:colormap=grayscale:grayscale=0,3000 ${sphere}:colormap=binary:binary_color=red:opacity=0.5 -viewsize 300 300 -viewport axial -zoom 10 -slice $x $y $z -cc -ss ${OUTDIR}/pngs/${label}_elecROI_CT_zoom_ax.png

#BOLD images
if [ -f $mbimg ];
then
	freeview -v ${mbimgreorient}:colormap=grayscale ${sphere}:colormap=binary:binary_color=red:opacity=0.5 -viewsize 300 300 -viewport sagittal -zoom 10 -slice $x $y $z -cc -ss ${OUTDIR}/pngs/${label}_elecROI_BOLD_zoom_sag.png

	freeview -v ${mbimgreorient}:colormap=grayscale ${sphere}:colormap=binary:binary_color=red:opacity=0.5 -viewsize 300 300 -viewport coronal -zoom 10 -slice $x $y $z -cc -ss ${OUTDIR}/pngs/${label}_elecROI_BOLD_zoom_cor.png

	freeview -v ${mbimgreorient}:colormap=grayscale ${sphere}:colormap=binary:binary_color=red:opacity=0.5 -viewsize 300 300 -viewport axial -zoom 10 -slice $x $y $z -cc -ss ${OUTDIR}/pngs/${label}_elecROI_BOLD_zoom_ax.png
fi

#T1 images
freeview -v ${t1img}:colormap=grayscale:grayscale=0,110 ${sphere}:colormap=binary:binary_color=red:opacity=0.5 -viewsize 300 300 -viewport sagittal -zoom 10 -slice $x $y $z -cc -ss ${OUTDIR}/pngs/${label}_elecROI_T1_zoom_sag.png

freeview -v ${t1img}:colormap=grayscale:grayscale=0,110 ${sphere}:colormap=binary:binary_color=red:opacity=0.5 -viewsize 300 300 -viewport coronal -zoom 10 -slice $x $y $z -cc -ss ${OUTDIR}/pngs/${label}_elecROI_T1_zoom_cor.png

freeview -v ${t1img}:colormap=grayscale:grayscale=0,110 ${sphere}:colormap=binary:binary_color=red:opacity=0.5 -viewsize 300 300 -viewport axial -zoom 10 -slice $x $y $z -cc -ss ${OUTDIR}/pngs/${label}_elecROI_T1_zoom_ax.png

freeview -v ${t1img}:colormap=grayscale:grayscale=0,110 ${sphere}:colormap=binary:binary_color=red:opacity=0.5 -viewsize 300 300 -viewport axial -slice $x $y $z -ss ${OUTDIR}/pngs/${label}_elecROI_T1_WB_ax.png

done

