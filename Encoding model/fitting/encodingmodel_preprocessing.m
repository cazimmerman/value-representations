%% setup
clearvars; close all; clc
addpath('/jukebox/witten/Chris/matlab/cz/ibl_da_neuropixels_2022/utils/');
mainpath = '/jukebox/witten/Chris/data/ibl_da_neuropixels/Data/Subjects/';
%% data paths
input_paths = cell(0,0);
%%%%% animal: dop_47 %%%%%
input_paths{end+1}  = 'dop_47/2022-06-05/001/alf/';
input_paths{end+1}  = 'dop_47/2022-06-06/001/alf/';
input_paths{end+1}  = 'dop_47/2022-06-09/003/alf/';
input_paths{end+1}  = 'dop_47/2022-06-10/002/alf/';
%%%%% animal: dop_48 %%%%%
input_paths{end+1}  = 'dop_48/2022-06-19/002/alf/';
input_paths{end+1}  = 'dop_48/2022-06-20/001/alf/';
input_paths{end+1}  = 'dop_48/2022-06-27/002/alf/';
input_paths{end+1}  = 'dop_48/2022-06-28/001/alf/';
%%%%% animal: dop_49 %%%%%
input_paths{end+1} = 'dop_49/2022-06-14/001/alf/';
input_paths{end+1} = 'dop_49/2022-06-15/001/alf/';
input_paths{end+1} = 'dop_49/2022-06-16/001/alf/';
input_paths{end+1} = 'dop_49/2022-06-17/001/alf/';
input_paths{end+1} = 'dop_49/2022-06-18/002/alf/';
input_paths{end+1} = 'dop_49/2022-06-19/001/alf/';
input_paths{end+1} = 'dop_49/2022-06-20/001/alf/';
input_paths{end+1} = 'dop_49/2022-06-27/003/alf/';
%%%%% animal: dop_50 %%%%%
input_paths{end+1} = 'dop_50/2022-09-12/001/alf/';
input_paths{end+1} = 'dop_50/2022-09-13/001/alf/';
input_paths{end+1} = 'dop_50/2022-09-14/003/alf/';
input_paths{end+1} = 'dop_50/2022-09-16/003/alf/';
input_paths{end+1} = 'dop_50/2022-09-17/001/alf/';
input_paths{end+1} = 'dop_50/2022-09-18/001/alf/';
%%%%% animal: dop_53 %%%%%
input_paths{end+1} = 'dop_53/2022-10-02/001/alf/';
input_paths{end+1} = 'dop_53/2022-10-03/001/alf/';
input_paths{end+1} = 'dop_53/2022-10-04/001/alf/';
input_paths{end+1} = 'dop_53/2022-10-05/001/alf/';
input_paths{end+1} = 'dop_53/2022-10-07/001/alf/';
%%%%% animal: dop_56 %%%%%
input_paths{end+1} = 'dop_56/2023-09-30/001/alf/';
input_paths{end+1} = 'dop_56/2023-10-01/001/alf/';
input_paths{end+1} = 'dop_56/2023-10-02/001/alf/';
input_paths{end+1} = 'dop_56/2023-10-03/001/alf/';
input_paths{end+1} = 'dop_56/2023-10-05/001/alf/';
%%%%% animal: dop_57 %%%%%
input_paths{end+1} = 'dop_57/2023-10-17/002/alf/';
input_paths{end+1} = 'dop_57/2023-10-19/002/alf/';
input_paths{end+1} = 'dop_57/2023-10-20/001/alf/';
%%%%% animal: dop_59 %%%%%
input_paths{end+1} = 'dop_59/2023-10-23/003/alf/';
input_paths{end+1} = 'dop_59/2023-10-24/001/alf/';
input_paths{end+1} = 'dop_59/2023-10-25/001/alf/';
input_paths{end+1} = 'dop_59/2023-10-26/001/alf/';
input_paths{end+1} = 'dop_59/2023-10-28/001/alf/';
input_paths{end+1} = 'dop_59/2023-10-29/001/alf/';
%% load and prep
pc = parcluster('local');
pc.NumWorkers = 12;
parpool(pc,pc.NumWorkers);

for p = 1:length(input_paths)
    sessionpath = input_paths{p};
    disp(' ')
    disp('-----------------------------')
    disp(['Session ID: ',sessionpath(1:end-9)])
    load([mainpath,sessionpath,'ephys_data.mat'],'ephys_data');
    if isfield(ephys_data,'units')
        neurons_include	= 1:length(ephys_data.units);
        disp(['Number of good units: ',num2str(length(neurons_include))])
        disp('-----------------------------')
        firing = cell(1,length(neurons_include));
        trials_include = cell(1,length(neurons_include));
        kfold_partition = cell(1,length(neurons_include));
        hemisphere = nan(1,length(neurons_include));
        
        load([mainpath,sessionpath,'/behavior_data.mat'],'behavior_data');
        behavior_trials = behavior_data.analysis.trials_include;

%         output_dir = [mainpath,sessionpath,'encodingmodels/inputs/neurons/'];
%         if exist(output_dir,'dir')
%             rmdir(output_dir,'s')
%         end
%         mkdir(output_dir)
%         parfor j = 1:length(neurons_include)
%             Y                       = struct;
%             Y.firing                = cellfun(@(x) x*0.01,ephys_data.units(neurons_include(j)).trials.raw,'UniformOutput',false);
%             Y.events                = ephys_data.units(neurons_include(j)).trials.idx;
%             Y.licks                 = ephys_data.units(neurons_include(j)).trials.licks;
%             Y.trials_include        = ephys_data.units(neurons_include(j)).trials.trials_include;
%             Y.kfold_partition       = MakeXvalPartitions2(Y.trials_include,5,behavior_data.events);
%             Y.firing                = Y.firing(Y.trials_include);
%             Y.events                = Y.events(Y.trials_include);
%             Y.licks                 = Y.licks(Y.trials_include);
%             [~,Y.trials_include]    = intersect(behavior_trials,Y.trials_include,'stable');
%             Y.hemisphere            = ephys_data.units(neurons_include(j)).hemisphere;
%             Y.metadata.session      = sessionpath;
%             Y.metadata.probe        = ephys_data.units(neurons_include(j)).probe;
%             Y.metadata.clusterid	= ephys_data.units(neurons_include(j)).clusterid;
%             Y.metadata.location     = ephys_data.units(neurons_include(j)).location;
%             Y.metadata.label        = ephys_data.units(neurons_include(j)).label;
%             Y.metadata.firing_rate  = ephys_data.units(neurons_include(j)).firing_rate_estimate;
%             Y.metadata.presence     = ephys_data.units(neurons_include(j)).presence;
%             parsave([output_dir,'neuron_',num2str(j,'%03.0f'),'.mat'],[],Y)
%         end
        
        output_dir = [mainpath,sessionpath,'encodingmodels/inputs/sessions_SeqAC_noawin_m_avchoice_median/'];
        if exist(output_dir,'dir')
            rmdir(output_dir,'s')
        end
        mkdir(output_dir)
        parfor k = 0:200
            if k == 0
                bd = load([mainpath,sessionpath,'/behavior_data.mat'],'behavior_data');
                idx = bd.behavior_data.analysis.trials_include;
                bd.behavior_data.events.prev_laser = circshift(~isnan(bd.behavior_data.times.laser_onset),1);
                bd.behavior_data.events.prev_CS    = circshift(bd.behavior_data.events.feedback==1,1);
            else
                bd = load([mainpath(1:end-9),'null_sessions_SeqAC_noawin_m_avchoice_median/',num2str(k,'%04.0f'),'.mat'],'behavior_data');
                idx = 1:length(behavior_trials);
            end
            X = [];
            fnames = fieldnames(bd.behavior_data.events);
            for i = 1:length(fnames)
                X.events.(fnames{i}) = bd.behavior_data.events.(fnames{i})(idx);
            end
            fnames = fieldnames(bd.behavior_data.wheel);
            for i = 1:length(fnames)
                X.wheel.(fnames{i}) = bd.behavior_data.wheel.(fnames{i})(idx);
            end
            parsave([output_dir,'session_',num2str(k,'%04.0f'),'.mat'],X,[])
        end
    else
        disp('Number of good units: 0')
        disp('-----------------------------')
    end
end
%% functions
function [] = parsave(fpath,X,Y)

if isempty(X)
    save(fpath,inputname(3))
elseif isempty(Y)
    save(fpath,inputname(2))
end

end