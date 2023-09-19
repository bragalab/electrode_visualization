
# Code for producing images centered on electrode contact coordinates obtained from manual localization using BioImage Suite

# Code by R Braga and Chris Cyr - Aug 2021

# Usage: /projects/b1134/tools/elec_zoomer/elec_zoomer_210824.sh ATHUAT

module load fsl
. ${FSLDIR}/etc/fslconf/fsl.sh

SUB=$1

BASEDIR=/projects/b1134

FSPATH=$BASEDIR/processed/fs/$SUB/$SUB
coordir=$FSPATH/elec_recon
coords=$coordir/brainmask_coords_0_wlabels.txt
SPHEREDIR=$BASEDIR/analysis/elec2roi/$SUB/elecs_vol_3mm
BOLDDIR=$BASEDIR/processed/iProc/BNI/$SUB/cross_session_maps

OUTDIR=/projects/b1134/processed/elec_zoom/$SUB
mkdir -p $OUTDIR/niftis
mkdir -p $OUTDIR/pngs
cd $OUTDIR

window=15
width=$(($window*2))

#Paths to CT, T1 and mean BOLD
#ctimg=$coordir/postInPre.nii.gz
t1img=$coordir/T1.nii.gz
#mbimg=$BOLDDIR/allscans-oc_anat_mean_concat.nii.gz

#orient Bold to T1/CT
#fslswapdim $mbimg x -z y $BOLDDIR/allscans-oc_onT1_anat_mean_concat.nii.gz
#mbimgreorient=$BOLDDIR/allscans-oc_onT1_anat_mean_concat.nii.gz

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

xstart=$(($x-$window))
ystart=$(($y-$window))
zstart=$(($z-$window))

xslice=$((-$x))
yslice=$((-$y))
zslice=$((-$z))

#Save out image of zoomed in electrode sphere
sphere=$SPHEREDIR/${label}_sphere_${x}_${y}_${z}.nii.gz

fslroi $sphere ${OUTDIR}/niftis/${label}_sphere_zoom.nii.gz $xstart $width $ystart $width $zstart $width

#Save out image of zoomed CT
#fslroi $ctimg ${OUTDIR}/niftis/${label}_ct_zoom.nii.gz $xstart $width $ystart $width $zstart $width

#Overlay and save out zoomed CT + elec images
#overlay 0 0 ${OUTDIR}/niftis/${label}_ct_zoom.nii.gz 0 3096 ${OUTDIR}/niftis/${label}_sphere_zoom.nii.gz 0.99 1 ${OUTDIR}/niftis/${label}_ct_sphere_combined.nii.gz

#slicer ${OUTDIR}/niftis/${label}_ct_sphere_combined.nii.gz -l ${FSLDIR}/etc/luts/renderjet.lut -u -x 0.5 ${OUTDIR}/pngs/${label}_ct_sphere_combined_sag.png

#slicer ${OUTDIR}/niftis/${label}_ct_sphere_combined.nii.gz -l ${FSLDIR}/etc/luts/renderjet.lut -u -y 0.5 ${OUTDIR}/pngs/${label}_ct_sphere_combined_ax.png

#slicer ${OUTDIR}/niftis/${label}_ct_sphere_combined.nii.gz -l ${FSLDIR}/etc/luts/renderjet.lut -u -z 0.5 ${OUTDIR}/pngs/${label}_ct_sphere_combined_cor.png

#Save out image of zoomed T1
fslroi $t1img ${OUTDIR}/niftis/${label}_T1_zoom.nii.gz $xstart $width $ystart $width $zstart $width

#Overlay and save out zoomed T1 + elec images
overlay 0 0 ${OUTDIR}/niftis/${label}_T1_zoom.nii.gz -a ${OUTDIR}/niftis/${label}_sphere_zoom.nii.gz 0.99 1 ${OUTDIR}/niftis/${label}_T1_sphere_combined.nii.gz 

slicer ${OUTDIR}/niftis/${label}_T1_sphere_combined.nii.gz -l ${FSLDIR}/etc/luts/renderjet.lut -u -x 0.5 ${OUTDIR}/pngs/${label}_T1_sphere_combined_sag.png

slicer ${OUTDIR}/niftis/${label}_T1_sphere_combined.nii.gz -l ${FSLDIR}/etc/luts/renderjet.lut -u -y 0.5 ${OUTDIR}/pngs/${label}_T1_sphere_combined_ax.png

slicer ${OUTDIR}/niftis/${label}_T1_sphere_combined.nii.gz -l ${FSLDIR}/etc/luts/renderjet.lut -u -z 0.5 ${OUTDIR}/pngs/${label}_T1_sphere_combined_cor.png

#Overlay and save out whole brainT1 + elec images
overlay 0 0 $t1img -a $sphere 0.99 1 ${OUTDIR}/niftis/${label}_T1_sphere_combined_WB.nii.gz

slicer ${OUTDIR}/niftis/${label}_T1_sphere_combined_WB.nii.gz -l ${FSLDIR}/etc/luts/renderjet.lut -u -x $xslice ${OUTDIR}/pngs/${label}_T1_sphere_combined_WBsagittal.png

slicer ${OUTDIR}/niftis/${label}_T1_sphere_combined_WB.nii.gz -l ${FSLDIR}/etc/luts/renderjet.lut -u -y $yslice ${OUTDIR}/pngs/${label}_T1_sphere_combined_WBaxial.png

slicer ${OUTDIR}/niftis/${label}_T1_sphere_combined_WB.nii.gz -l ${FSLDIR}/etc/luts/renderjet.lut -u -z $zslice ${OUTDIR}/pngs/${label}_T1_sphere_combined_WBcoronal.png

#Save out image of zoomed in mean BOLD
#fslroi $mbimgreorient ${OUTDIR}/niftis/${label}_BOLD_zoom.nii.gz $xstart $width $ystart $width $zstart $width

#Overlay and save out zoomed BOLD + elec images
#overlay 0 0 ${OUTDIR}/niftis/${label}_BOLD_zoom.nii.gz 7000 10000 ${OUTDIR}/niftis/${label}_sphere_zoom.nii.gz 0.99 1 ${OUTDIR}/niftis/${label}_BOLD_sphere_combined.nii.gz 

#slicer ${OUTDIR}/niftis/${label}_BOLD_sphere_combined.nii.gz -l ${FSLDIR}/etc/luts/renderjet.lut -u -x 0.5 ${OUTDIR}/pngs/${label}_BOLD_sphere_combined_sag.png

#slicer ${OUTDIR}/niftis/${label}_BOLD_sphere_combined.nii.gz -l ${FSLDIR}/etc/luts/renderjet.lut -u -y 0.5 ${OUTDIR}/pngs/${label}_BOLD_sphere_combined_ax.png

#slicer ${OUTDIR}/niftis/${label}_BOLD_sphere_combined.nii.gz -l ${FSLDIR}/etc/luts/renderjet.lut -u -z 0.5 ${OUTDIR}/pngs/${label}_BOLD_sphere_combined_cor.png

done

