# Electrode_visualization

This toolbox is an assortment of scripts needed for visualizing implanted electrodes on the brian, and calculating metrics to describe electrodes (ex. distances between electrodes). 

elec_master.sh utilizes elec_distance.m, elec_combiner...R and elec_plotter.m to create one document showing the locations of electrodes on the brain. This can be run for a specific patient/subject, and utilizes a SLURM workload manager.

geodesic_distance.py can calculate geodesic distances between contacts.

stim_distance.m calculates distance from each electrode to the stimulation site for stim data.

# Requirements

You will need to have FreeSurfer, iELVIs, matlab/r2020b or later and R/4.0.3 installed.

elec_master.sh requires the subject to have a freesurfer directory with the organization of /processed/fs/SUB/SUB with subdirectories surf and elec_recon. Thus, you will need to run the subject through the freesurfer pipeline before using this tool.

elec_master.sh also requires that electrode reconstruction has been completed, and that voxel-based electrode coordinates are in a text file at /processed/fs/SUB/SUB/elec_recon/brainmask_0_w_labels.txt with the format of 

A1 173 172 172

A2 173 171 171

.   .   .   .

.   .   .   .

# Usage
to run locally:
sh elec_master.sh SubjectID

to utilize parallel computing resources:
sbatch elec_master.sh SubjectID




