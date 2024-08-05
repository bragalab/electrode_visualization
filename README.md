# Electrode_visualization

This toolbox is an assortment of scripts needed for calculating metrics to describe electrodes (distances between electrodes, network membership of electrodes), and then visualizing them in a multi-page document. 

elec_master.sh utilizes elec_distance.m, elec_combiner...R and elec_plotter.m to create one document showing the locations of electrodes on the brain. This can be run for a specific subject.

plot_all_membership_pies.sh utilizes plot_all_membership_pies.m and plot_all_membership_pies.R to plot network membership pie charts for each bipolar electrode pair. This can be run for a specific subject or a specific run.

geodesic_distance.py can calculate geodesic distances between contacts but has yet to be utilized by any pipeline.

stim_distance.m calculates distance from each electrode to the stimulation site for STIM data and is used by the eegpreproc and eeganalysis toolboxes.

# Requirements

elec_master.sh requires the subject to have a freesurfer directory within with the organization of /processed/fs/SUB/SUB with subdirectories surf and elec_recon. Thus, you will need to run the subject through the freesurfer pipeline before using this tool.

plot_all_membership_pies.sh requires the subject to have their rs-fMRI-FC networks defined and within the organization of .../analysis/surfFC/ProjectID/SUB/REST/2mm/parcellations/k/. Thus, you will need to run the subject through the iProc pipeline and then define networks via seed choosing and kmeans clustering. plot_all_membership_pies.m will need to be updated with the path to the specific kmeans clustering version of networks that you'd like to use.

You will also need to have matlab/r2020b or later and R/4.0.3 installed.

# Usage
From a quest login node terminal, within the electrode_visualization directory:
sh elec_master.sh SubjectID

sh plot_all_membership+pies.sh SubjectID
or
sh plot_all_membership+pies.sh ProcessedDataPath

# Troubleshooting




