% Creates iElvis whole brain visualizations of electrodes. To be used
% within the elec_master.sh script. Relies on Bioimage suite coordinates,
% channellabels.txt, and brainmask_coords_0_wlabels.txt
% 
% Created by Chris Cyr, Braga Lab, September 2021
function elec_plotter(SubjectID)
%% load paths
addpath(genpath('/projects/b1134/tools/iELVis'))
PNGPATH = sprintf('/projects/b1134/processed/fs/%s/%s/elec_recon/PICS', SubjectID, SubjectID);
FSPATH = sprintf('/projects/b1134/processed/fs/%s/%s/elec_recon', SubjectID, SubjectID);

%% load channel info from mgrid file

[~, elecLabels, elecRgb, elecPairs, elecPresent]=mgrid2matlab(SubjectID);

elec_info = cell(length(elecLabels),4); %hemisphere, electrode type, shaft ID, channel number
for i = 1:length(elecLabels)
    elec_info(i,2:4) = strsplit(elecLabels{i}, '_');
    elec_info{i,1} = elec_info{i,2}(1);
    elec_info{i,2} = elec_info{i,2}(2:end);
end

[electrode_shafts, edges] = unique(elec_info(:,3),'stable');
Type = elec_info(edges, 2);

Dimensions = cell(length(Type),1);
%if ~isempty(Grid_indices) %if there are grids
    index = 1;
    mgridFname = sprintf('%s/%s.mgrid', FSPATH, SubjectID);
    fid = fopen(mgridFname, 'r');
    while feof(fid) == 0
        line = fgetl(fid);
        if strcmp(line,'#Dimensions')
            line = fgetl(fid);
            line = strsplit(line, ' ');
            Dimensions{index} = sprintf('%s x %s', line{2}, line{3});
            index = index+1;
        end
    end
%end    
edges(end+1) = length(elecLabels)+1;

%% create info table

t1 = table(electrode_shafts, Type, Dimensions);    
writetable(t1,[FSPATH,'/electrodeinfotable.csv'])

 %% plot
 
if ~exist(PNGPATH, 'dir')
   mkdir(PNGPATH)
end
cd(PNGPATH)

%create images for individual electrode shafts
for i = 1:length(electrode_shafts)

    cfg=[];
    cfg.view = sprintf('%s', lower(elec_info{edges(i),1}));
    cfg.ignoreDepthElec='n';
    cfg.opaqueness=0.5;
    cfg.elecNames = cell(1, edges(i+1) - edges(i));
    for j = 1:length(cfg.elecNames)
        cfg.elecNames{j} = sprintf('%s%i', electrode_shafts{i}, j);
    end
    cfg.elecColors = 'r';
    cfg.title= ' ';
    cfg.showLabels = 'y';
    cfg.elecCoord = 'LEPTO';
    plotPialSurf(SubjectID,cfg);
    ax = gca;
    ax.Units = 'inches';
    fig = gcf;
    fig.Units = 'inches';
    ax.Position = [0.1 0 2.26 1.78];
    fig.Position = [13.9 1.8 2.375 1.75];
    print(fig, sprintf('%s_WBview_%s_lateral', SubjectID, electrode_shafts{i}), '-dpng', '-r0')
    close(fig)
    
    cfg.view = sprintf('%sm', lower(elec_info{edges(i),1}));
    plotPialSurf(SubjectID,cfg);
    ax = gca;
    ax.Units = 'inches';
    fig = gcf;
    fig.Units = 'inches';
    ax.Position = [0.1 0 2.26 1.78];
    fig.Position = [13.9 1.8 2.375 1.75];    
    print(fig, sprintf('%s_WBview_%s_medial', SubjectID, electrode_shafts{i}), '-dpng', '-r0')
    close(fig)
    
    cfg.view = sprintf('%so', lower(elec_info{edges(i),1}));
    plotPialSurf(SubjectID,cfg);
    ax = gca;
    ax.Units = 'inches';
    fig = gcf;
    fig.Units = 'inches';
    ax.Position = [-0.5 0.05 2.251 1.75];
    fig.Position = [13.85 2.15 1.25 1.875];
    print(fig, sprintf('%s_WBview_%s_occipital', SubjectID, electrode_shafts{i}), '-dpng', '-r0')
    close(fig)
    
    cfg.view = sprintf('%sf', lower(elec_info{edges(i),1}));
    cfg.title= ' ';
    cfg.showLabels = 'y';
    plotPialSurf(SubjectID,cfg);
    ax = gca;
    ax.Units = 'inches';
    fig = gcf;
    fig.Units = 'inches';
    ax.Position = [-0.5 0.05 2.251 1.75];
    fig.Position = [13.85 2.15 1.5 1.875];    
    print(fig, sprintf('%s_WBview_%s_frontal', SubjectID, electrode_shafts{i}), '-dpng', '-r0')
    close(fig)
    
end

%%
    %create images for all electrode shafts together
    plotAllSubduralGroups_CC(SubjectID,'mgrid',1)
end
