%% setup
clearvars; close all; clc;
addpath(genpath('/jukebox/witten/Chris/matlab/cz/ibl_da_neuropixels_2022/utils/'));
cz_path = '/jukebox/witten/Chris/data/ibl_da_neuropixels/Data/Subjects/';

if ~isempty(gcp('nocreate'))
    delete(gcp('nocreate'));
end
pc = parcluster('local');
pc.NumWorkers = 44;
parpool(pc,pc.NumWorkers);

var1 = 'CRAC';
outputdir_suffix = 'SeqAC_noawin_m_avchoice_median_FINAL';

min_presence = 0.9;
min_trials   = 0;

null_sessions = 200;
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
%% initialize

betas = [];
r2 = [];
lambda1 = [];
lambda2 = [];
time = [];
firing_rate = [];

kernels = struct;
kernels.cue = [];
kernels.movement_contra = [];
kernels.movement_ipsi = [];
kernels.CS_plus = [];
kernels.CS_minus = [];
kernels.VTA_stim = [];

gains = struct;
gains.cue = [];
gains.movement_contra = [];
gains.movement_ipsi = [];
gains.CS_plus = [];
gains.CS_minus = [];
gains.VTA_stim = [];

pvalues = struct;
pvalues.pretest = [];
pvalues.AllKernels.remove_AllValues_AllKernels = [];
pvalues.AllKernels.remove_Vcs_AllKernels = [];
pvalues.AllKernels.remove_Vchoice_AllKernels = [];
pvalues.AllKernels.remove_Vcs_Vchoice_AllKernels = [];
pvalues.AllKernels.remove_PIchoice_AllKernels = [];

recording_id = [];
recording = cell(0,0);
probe = cell(0,0);
cluster = [];
iterations = [];

delta_r2 = struct;
delta_r2.AllKernels.remove_AllValues_AllKernels = [];
delta_r2.AllKernels.remove_Vcs_AllKernels = [];
delta_r2.AllKernels.remove_Vchoice_AllKernels = [];
delta_r2.AllKernels.remove_Vcs_Vchoice_AllKernels = [];
delta_r2.AllKernels.remove_PIchoice_AllKernels = [];
delta_r2.AllKernels.remove_AllValues_AllKernels_null = [];
delta_r2.AllKernels.remove_Vcs_AllKernels_null = [];
delta_r2.AllKernels.remove_Vchoice_AllKernels_null = [];
delta_r2.AllKernels.remove_Vcs_Vchoice_AllKernels_null = [];
delta_r2.AllKernels.remove_PIchoice_AllKernels_null = [];

excluded = struct;
excluded.animal_id = [];
excluded.recording_id = [];
excluded.recording_name = cell(0,0);
excluded.probe = cell(0,0);
excluded.cluster = [];
excluded.firing_rate = [];

realneurons = struct;
realneurons.region = [];

units = struct;
units.mua.total = [];
units.good.total = [];
units.good.included = [];
units.good.excluded_incomplete = [];
units.good.excluded_pretest = [];
units.good.excluded_presence = [];

temp = struct;
temp.FR = [];
temp.recording_id = [];
temp.region = struct;
temp.region = [];
%% run
for i = 1:length(input_paths)
    tic
    disp(' ')
    disp(repmat('-',[1 100]))
    disp(['Loading encoding models for session #',num2str(i),': ',input_paths{i}(1:end-9)])
    disp(repmat('-',[1 100]))
    input_dir = [cz_path,input_paths{i},'encodingmodels/inputs/neurons/'];
    load([cz_path,input_paths{i},'ephys_data.mat']);
    if isfield(ephys_data,'units')
        load([cz_path,input_paths{i},'behavior_data.mat']);
        N_total = length(ephys_data.units);
        disp(['Total units:       ',num2str(N_total,'%03.0f')])
        disp(repmat('-',[1 100]))
        A = []; B = []; BB = []; C = []; D = []; E = [];
        for j = 1:N_total
            if ephys_data.units(j).label == 1 && ephys_data.units(j).presence >= min_presence && AllenRegions_limited({ephys_data.units(j).location}).IDs<=10
                output_dir = [cz_path,input_paths{i},'encodingmodels/outputs/',var1,'_',outputdir_suffix,'/neuron_',num2str(j,'%03.0f'),'/'];
                if exist([input_dir,'neuron_',num2str(j,'%03.0f'),'_pretest.mat'],'file') == 2
                    load([input_dir,'neuron_',num2str(j,'%03.0f'),'_pretest.mat'],'output');
                    if isstruct(output.real) && output.pvalue.full<=0.01+1E-10% isfolder(output_dir) && length(dir([output_dir,'*.mat']))>0
                        if length(dir([output_dir,'*.mat'])) >= null_sessions+1
                            
                            recording_id(end+1) = i;
                            realneurons(end+1).region = ephys_data.units(j).location;
                            recording{end+1} = ephys_data.path(23:end);
                            probe{end+1} = ephys_data.units(j).probe;
                            cluster(end+1) = ephys_data.units(j).clusterid;
                            firing_rate(end+1) = ephys_data.units(j).firing_rate_estimate;
                                                        
                            load([output_dir,'neuron_',num2str(j,'%03.0f'),'_session_',num2str(0,'%03.0f'),'.mat'])
                            
                            r2(end+1) = output.AllValues(end).fit2.stats.R2;
                            lambda1(end+1) = output.AllValues(end).fit1.lambda;
                            lambda2(end+1) = output.AllValues(end).fit2.lambda;
                            iterations(end+1) = length(output.AllValues);
                            time(end+1) = output.time;
                            
                            kernels.cue(end+1,:) = output.AllValues(end).kernels{1}{1}(101:201);
                            kernels.movement_contra(end+1,:) = output.AllValues(end).kernels{2}{1}(51:151);
                            kernels.movement_ipsi(end+1,:) = output.AllValues(end).kernels{3}{1}(51:151);
                            kernels.CS_plus(end+1,:) = output.AllValues(end).kernels{5}{1}(201:401);
                            kernels.CS_minus(end+1,:) = output.AllValues(end).kernels{6}{1}(201:401);
                            kernels.VTA_stim(end+1,:) = output.AllValues(end).kernels{7}{1}(201:401);
                            
                            gains.cue(end+1,:)              = output.AllValues(end).coefficients{1};
                            gains.movement_contra(end+1,:)	= output.AllValues(end).coefficients{2};
                            gains.movement_ipsi(end+1,:)    = output.AllValues(end).coefficients{3};
                            gains.CS_plus(end+1,:)          = output.AllValues(end).coefficients{5};
                            gains.CS_minus(end+1,:)         = output.AllValues(end).coefficients{6};
                            gains.VTA_stim(end+1,:)         = output.AllValues(end).coefficients{7};
                            
                            real_remove_AllValues_AllKernels = output.remove_AllValues_AllKernels.Fstat.AllValues;
                            real_remove_Vcs_AllKernels = output.remove_Vcs_AllKernels.Fstat.AllValues;
                            real_remove_Vchoice_AllKernels = output.remove_Vchoice_AllKernels.Fstat.AllValues;
                            real_remove_Vcs_Vchoice_AllKernels = output.remove_Vcs_Vchoice_AllKernels.Fstat.AllValues;
                            real_remove_PIchoice_AllKernels = output.remove_PIchoice_AllKernels.Fstat.AllValues;
                            
                            null_remove_AllValues_AllKernels = [];
                            null_remove_Vcs_AllKernels = [];
                            null_remove_Vchoice_AllKernels = [];
                            null_remove_Vcs_Vchoice_AllKernels = [];
                            null_remove_PIchoice_AllKernels = [];
                            
                            null_remove_AllValues_AllKernels_r2 = [];
                            null_remove_Vcs_AllKernels_r2 = [];
                            null_remove_Vchoice_AllKernels_r2 = [];
                            null_remove_Vcs_Vchoice_AllKernels_r2 = [];
                            null_remove_PIchoice_AllKernels_r2 = [];
                            
                            parfor k = 1:null_sessions
                                a = load([output_dir,'neuron_',num2str(j,'%03.0f'),'_session_',num2str(k,'%03.0f'),'.mat']);
                                
                                null_remove_AllValues_AllKernels(k)         = a.output.remove_AllValues_AllKernels.Fstat.AllValues;
                                null_remove_Vcs_AllKernels(k)               = a.output.remove_Vcs_AllKernels.Fstat.AllValues;
                                null_remove_Vchoice_AllKernels(k)           = a.output.remove_Vchoice_AllKernels.Fstat.AllValues;
                                null_remove_Vcs_Vchoice_AllKernels(k)       = a.output.remove_Vcs_Vchoice_AllKernels.Fstat.AllValues;
                                null_remove_PIchoice_AllKernels(k)          = a.output.remove_PIchoice_AllKernels.Fstat.AllValues;
                                
                                null_remove_AllValues_AllKernels_r2(k)      = a.output.AllValues_refit.fit2.stats.R2 - a.output.remove_AllValues_AllKernels.fit2.stats.R2;
                                null_remove_Vcs_AllKernels_r2(k)            = a.output.AllValues_refit.fit2.stats.R2 - a.output.remove_Vcs_AllKernels.fit2.stats.R2;
                                null_remove_Vchoice_AllKernels_r2(k)        = a.output.AllValues_refit.fit2.stats.R2 - a.output.remove_Vchoice_AllKernels.fit2.stats.R2;
                                null_remove_Vcs_Vchoice_AllKernels_r2(k)    = a.output.AllValues_refit.fit2.stats.R2 - a.output.remove_Vcs_Vchoice_AllKernels.fit2.stats.R2;
                                null_remove_PIchoice_AllKernels_r2(k)       = a.output.AllValues_refit.fit2.stats.R2 - a.output.remove_PIchoice_AllKernels.fit2.stats.R2;
                            end
                            
                            pvalues.AllKernels.remove_AllValues_AllKernels(end+1)	= null_distribution_pvalue(real_remove_AllValues_AllKernels,null_remove_AllValues_AllKernels);
                            pvalues.AllKernels.remove_Vcs_AllKernels(end+1)         = null_distribution_pvalue(real_remove_Vcs_AllKernels,null_remove_Vcs_AllKernels);
                            pvalues.AllKernels.remove_Vchoice_AllKernels(end+1)     = null_distribution_pvalue(real_remove_Vchoice_AllKernels,null_remove_Vchoice_AllKernels);
                            pvalues.AllKernels.remove_Vcs_Vchoice_AllKernels(end+1) = null_distribution_pvalue(real_remove_Vcs_Vchoice_AllKernels,null_remove_Vcs_Vchoice_AllKernels);
                            pvalues.AllKernels.remove_PIchoice_AllKernels(end+1)	= null_distribution_pvalue(real_remove_PIchoice_AllKernels,null_remove_PIchoice_AllKernels);
                                                        
                            delta_r2.AllKernels.remove_AllValues_AllKernels(end+1)  = output.AllValues_refit.fit2.stats.R2 - output.remove_AllValues_AllKernels.fit2.stats.R2;
                            delta_r2.AllKernels.remove_Vcs_AllKernels(end+1)        = output.AllValues_refit.fit2.stats.R2 - output.remove_Vcs_AllKernels.fit2.stats.R2;
                            delta_r2.AllKernels.remove_Vchoice_AllKernels(end+1)    = output.AllValues_refit.fit2.stats.R2 - output.remove_Vchoice_AllKernels.fit2.stats.R2;
                            delta_r2.AllKernels.remove_Vcs_Vchoice_AllKernels(end+1)= output.AllValues_refit.fit2.stats.R2 - output.remove_Vcs_Vchoice_AllKernels.fit2.stats.R2;
                            delta_r2.AllKernels.remove_PIchoice_AllKernels(end+1)   = output.AllValues_refit.fit2.stats.R2 - output.remove_PIchoice_AllKernels.fit2.stats.R2;
                            
                            delta_r2.AllKernels.remove_AllValues_AllKernels_null(end+1)     = mean(null_remove_AllValues_AllKernels_r2);
                            delta_r2.AllKernels.remove_Vcs_AllKernels_null(end+1)           = mean(null_remove_Vcs_AllKernels_r2);
                            delta_r2.AllKernels.remove_Vchoice_AllKernels_null(end+1)       = mean(null_remove_Vchoice_AllKernels_r2);
                            delta_r2.AllKernels.remove_Vcs_Vchoice_AllKernels_null(end+1)   = mean(null_remove_Vcs_Vchoice_AllKernels_r2);
                            delta_r2.AllKernels.remove_PIchoice_AllKernels_null(end+1)      = mean(null_remove_PIchoice_AllKernels_r2);
                            
                            load([input_dir,'neuron_',num2str(j,'%03.0f'),'_pretest.mat'])
                            pvalues.pretest(end+1) = output.pvalue.full;
                            
                            D = [D j];
                        else
                            A = [A j]; % Fitting incomplete
                            temp(end+1).FR = ephys_data.units(j).firing_rate_estimate;
                            temp(end).region = ephys_data.units(j).location;
                            temp(end).recording_id = i;
                        end
                    else
                        B = [B j]; % Excluded/Pre-test
                        temp(end+1).FR = ephys_data.units(j).firing_rate_estimate;
                        temp(end).region = ephys_data.units(j).location;
                        temp(end).recording_id = i;
                    end
                else
                    BB = [BB j]; % Pre-test missing
                end
            else
                E = [E j]; % MUA
            end
            fprintf('|')
            if rem(j,100) == 0 || j == N_total
                fprintf('\n')
            end
        end
        
        disp(repmat('-',[1 100]))
        disp(    ['Single-units:       ',num2str(length(D)+length(A)+length(B),'%03.0f')])
        disp(repmat('-',[1 100]))
        disp(    ['Fitting complete:   ',num2str(length(D),'%03.0f'),'/',num2str(length(D)+length(A)+length(B),'%03.0f')])
        if isempty(A)
            disp(['Fitting incomplete: ',num2str(length(A),'%03.0f'),'/',num2str(length(D)+length(A)+length(B),'%03.0f')])
        else
            missing = sprintf('%.0f,' , A);
            missing = missing(1:end-1);
            disp(['Fitting incomplete: ',num2str(length(A),'%03.0f'),'/',num2str(length(D)+length(A)+length(B),'%03.0f'),' (',missing,')'])
        end
        disp(    ['Excluded/Pre-test:  ',num2str(length(B),'%03.0f'),'/',num2str(length(D)+length(A)+length(B),'%03.0f')])
        if isempty(BB)
            disp(['Pre-test missing:   None'])
        else
            missing = sprintf('%.0f,' , BB);
            missing = missing(1:end-1);
            disp(['Pre-test missing:   ',num2str(length(BB),'%03.0f'),' (',missing,')'])
        end
        disp(repmat('-',[1 100]))
        
        units.good.total(end+1) = length(D)+length(A)+length(B);
        units.good.included(end+1) = length(D);
        units.good.excluded_incomplete(end+1) = length(A);
        units.good.excluded_pretest(end+1) = length(B);
        
    end
end

temp(1) = [];
out = AllenRegions_limited(temp);
Fails = struct;
Fails.firing_rate     = [temp(:).FR];
Fails.recording_id    = [temp(:).recording_id];
Fails.region_id       = out.IDs;
Fails.region_name     = {temp(:).region};
%% save data
realneurons(1) = [];
regions = AllenRegions_limited(realneurons);
[~,~,animal_id]          = unique(cellfun(@(x) str2double(x(5:6)),recording)); animal_id = animal_id';

EncodingSummary                 = struct;
EncodingSummary.model           = 'SeqAC_noawin_m_avchoice_median';
EncodingSummary.animal_id       = animal_id;
EncodingSummary.recording_id    = recording_id;
EncodingSummary.recording_name  = recording;
EncodingSummary.probe           = probe;
EncodingSummary.cluster         = cluster;
EncodingSummary.firing_rate     = firing_rate;
EncodingSummary.region_id       = regions.IDs;
EncodingSummary.region_name     = {realneurons(:).region};
EncodingSummary.region_key      = regions.key;
EncodingSummary.kernels         = kernels;
EncodingSummary.gains           = gains;
EncodingSummary.fit.r2          = r2;
EncodingSummary.fit.lambda1     = lambda1;
EncodingSummary.fit.lambda2     = lambda2;
EncodingSummary.fit.iterations  = iterations;
EncodingSummary.fit.time        = time;
EncodingSummary.pvalues         = pvalues;
EncodingSummary.delta_r2        = delta_r2;
EncodingSummary.inclusion_stats = units;
EncodingSummary.Fails           = Fails;

clearvars -except EncodingSummary
save(strcat('encoding-model-output-',string(datetime('now','Format','yyy-MM-dd-hh-mm-a')),'.mat'))
delete(gcp('nocreate'));