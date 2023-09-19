#!/usr/bin/env python3
# -*- coding: utf-8 -*-
###############################################
# Created by Chris Cyr, Braga Lab, September 2022
# Utilized surfdist package to calculate interelectrode geodesic distances.
# Inputs are a file path to stimulation run, and a hemisphere for implanted electrodes
# Output is a csv with distance from stim site to all other bipolar electrodes.
# Needs to be run from a virtual environment will all packages below installed
# 
# Usage: python /projects/b1134/tools/electrode_visualization/geodesic_distance.py /projects/b1134/processed/ieeg_stim/ATHUAT/EMU0018/STIM01/W7-W8 l
#
###############################################
#import packages
import sys
import nibabel as nib
import numpy as np
import pandas as pd
import os
import surfdist as sd
from surfdist import load, utils, analysis
import cifti

#interpret command line arguments
OUTPATH = sys.argv[1]
StimSite = OUTPATH.split('/')[-1]
SubjectID = OUTPATH.split('/')[-4]
hemisphere = sys.argv[2]

#load electrode ROIs
elec_dir = '/projects/b1134/analysis/elec2roi/%s/elecs_surf_3mm_41k_bipolar' % SubjectID
elec_list = []
for file in os.listdir(elec_dir):
    if file.endswith('.dlabel.nii'):
        elec_list.append(file)         

#load surfaces
sub_dir = '/projects/b1134/processed/fs/%s/%s_41k' % (SubjectID, SubjectID)
surf = nib.freesurfer.read_geometry('%s/surf/%sh.pial.T1' % (sub_dir, hemisphere))
cortex = np.sort(nib.freesurfer.read_label('%s/label/%sh.cortex.label' % (sub_dir, hemisphere))

#find StimSite ROI        
source_elec_file = [x for x in elec_list if StimSite in x][0]      
source_elec_data = cifti.read('%s/%s' % (elec_dir, source_elec_file))
source_elec_vertices = np.argwhere(source_elec_data[0] > 0)[:,1]
if source_elec_vertices[0] > 40962: #correct vertices if its in right hemisphere
    source_elec_vertices = source_elec_vertices - 40962

#calculate distance from source to rest of surface
dist = sd.analysis.dist_calc(surf,cortex,source_elec_vertices)
dist[np.argwhere(dist == 0)] = float("NAN")

#calculate distance to other electrode
geodesic_distances = [[],[]]
for i in range(len(elec_list)): #for each electrode
    current_elec_file = elec_list[i]
    current_elec_label = elec_list[i].split('_')[0]
    current_elec_data = cifti.read('%s/%s' % (elec_dir, current_elec_file))
    current_elec_vertices = np.argwhere(current_elec_data[0] > 0)[:,1]
    if current_elec_vertices[0] > 40962: #correct vertices if its in right hemisphere
        current_elec_vertices = current_elec_vertices - 40962
    current_elec_dist = np.nanmean(dist[current_elec_vertices])
    
    geodesic_distances[0].append(current_elec_label)
    geodesic_distances[1].append(current_elec_dist)   
    
#convert to dataframe
geodesic_distances = pd.DataFrame(data=geodesic_distances).T
geodesic_distances = geodesic_distances.sort_values(geodesic_distances.columns[0])

#save out
geodesic_distances.to_csv('%s/geodesic_distances.csv' % OUTPATH)

#let them know
print("Chris is the man")

