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

var1 = 'QLEARNING';
outputdir_suffix = 'ActionValueStateValue_Qmedian';

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
kernels.movement_ipsi = [];
kernels.movement_contra = [];
kernels.outcome_water = [];
kernels.CS_plus = [];
kernels.CS_minus = [];
kernels.VTA_stim = [];

gains = struct;
gains.cue = [];
gains.movement_contra = [];
gains.movement_ipsi = [];
gains.outcome_water = [];
gains.CS_plus = [];
gains.CS_minus = [];
gains.VTA_stim = [];

psth = struct;
psth.cue = [];
psth.movement_ipsi = [];
psth.movement_contra = [];
psth.CS_plus = [];
psth.CS_minus = [];
psth.VTA_stim = [];

PSTH_final = struct;

PSTH_final.all.cue = [];
PSTH_final.all.movement_ipsi = [];
PSTH_final.all.movement_contra = [];
PSTH_final.all.CS_plus = [];
PSTH_final.all.CS_minus = [];
PSTH_final.all.VTA_stim = [];

PSTH_final.all_predictions.cue = [];
PSTH_final.all_predictions.movement_ipsi = [];
PSTH_final.all_predictions.movement_contra = [];
PSTH_final.all_predictions.CS_plus = [];
PSTH_final.all_predictions.CS_minus = [];
PSTH_final.all_predictions.VTA_stim = [];

PSTH_final.even.cue = [];
PSTH_final.even.movement_ipsi = [];
PSTH_final.even.movement_contra = [];
PSTH_final.even.CS_plus = [];
PSTH_final.even.CS_minus = [];
PSTH_final.even.VTA_stim = [];

PSTH_final.even_predictions.cue = [];
PSTH_final.even_predictions.movement_ipsi = [];
PSTH_final.even_predictions.movement_contra = [];
PSTH_final.even_predictions.CS_plus = [];
PSTH_final.even_predictions.CS_minus = [];
PSTH_final.even_predictions.VTA_stim = [];

PSTH_final.odd.cue = [];
PSTH_final.odd.movement_ipsi = [];
PSTH_final.odd.movement_contra = [];
PSTH_final.odd.CS_plus = [];
PSTH_final.odd.CS_minus = [];
PSTH_final.odd.VTA_stim = [];

pvalues = struct;
pvalues.pretest = [];
pvalues.gocue = [];
pvalues.movement = [];
pvalues.outcome = [];
pvalues.movement_ID = [];
pvalues.outcome_ID = [];
pvalues.CSplus = [];
pvalues.AllKernels.remove_AllValues = [];
pvalues.AllKernels.remove_RelativeValue = [];
pvalues.AllKernels.remove_StateValue = [];

fits = struct;
fits.alpha.R2.AllValues = [];
fits.alpha.R2.remove_AllValues_AllKernels = [];
fits.alpha.R2.remove_RelativeValue_AllKernels = [];
fits.alpha.R2.remove_StateValue_AllKernels = [];
fits.alpha.R2.AllValues_null = [];
fits.alpha.R2.remove_AllValues_AllKernels_null = [];
fits.alpha.R2.remove_RelativeValue_AllKernels_null = [];
fits.alpha.R2.remove_StateValue_AllKernels_null = [];
fits.gamma.R2.AllValues = [];
fits.gamma.R2.remove_AllValues_AllKernels = [];
fits.gamma.R2.remove_RelativeValue_AllKernels = [];
fits.gamma.R2.remove_StateValue_AllKernels = [];
fits.gamma.R2.AllValues_null = [];
fits.gamma.R2.remove_AllValues_AllKernels_null = [];
fits.gamma.R2.remove_RelativeValue_AllKernels_null = [];
fits.gamma.R2.remove_StateValue_AllKernels_null = [];
fits.alpha.pvalues.remove_AllValues_AllKernels = [];
fits.alpha.pvalues.remove_RelativeValue_AllKernels = [];
fits.alpha.pvalues.remove_StateValue_AllKernels = [];
fits.gamma.pvalues.remove_AllValues_AllKernels = [];
fits.gamma.pvalues.remove_RelativeValue_AllKernels = [];
fits.gamma.pvalues.remove_StateValue_AllKernels = [];

recording_id = [];
recording = cell(0,0);
probe = cell(0,0);
cluster = [];
iterations = [];

delta_r2 = struct;
delta_r2.AllKernels.remove_AllValues = [];
delta_r2.AllKernels.remove_RelativeValue = [];
delta_r2.AllKernels.remove_StateValue = [];
delta_r2.AllKernels.remove_AllValues_null = [];
delta_r2.AllKernels.remove_RelativeValue_null = [];
delta_r2.AllKernels.remove_StateValue_null = [];

fstats.AllKernels.remove_AllValues = [];
fstats.AllKernels.remove_RelativeValue = [];
fstats.AllKernels.remove_StateValue = [];

r2v2 = struct;
r2v2.BilinearKernelsGains = [];
r2v2.BilinearKernelsNoGains = [];
r2v2.LinearKernels = [];
r2v2.LinearNoKernels = [];
r2v2.gocue = [];
r2v2.movement = [];
r2v2.outcome = [];
r2v2.movement_ID = [];
r2v2.outcome_ID = [];
r2v2.CSplus = [];

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

pvalues.AllKernels.remove_StateValue_Q_total = [];
pvalues.AllKernels.remove_StateValue_Q_total_weighted = [];
pvalues.AllKernels.remove_StateValue_matched = [];
delta_r2.AllKernels.remove_StateValue_Q_total = [];
delta_r2.AllKernels.remove_StateValue_Q_total_null = [];
delta_r2.AllKernels.remove_StateValue_Q_total_weighted = [];
delta_r2.AllKernels.remove_StateValue_Q_total_weighted_null = [];
delta_r2.AllKernels.remove_StateValue_matched = [];
delta_r2.AllKernels.remove_StateValue_matched_null = [];

pvalues.AllKernels.CS_plus_by_laser = [];
delta_r2.AllKernels.CS_plus_by_laser = [];
delta_r2.AllKernels.CS_plus_by_laser_null = [];

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
                            
                            t = ephys_data.units(j).trials.trials_include;
                            a = ephys_data.units(j).trials.raw(t);
                            b = ephys_data.units(j).trials.idx(t);
                            mgw = myGaussWin(0.025,1/.01); mgw(1:round(numel(mgw)/2)-1) = 0; mgw = mgw./sum(mgw);
                            a = cellfun(@(x) conv(x,mgw,'same'),a,'UniformOutput',false);
                            tdata = cellfun(@(x,y) x(rmmissing(unique([y(1):y(1)+100,y(2)-50:y(2)+50,y(4):y(4)+200,y(5):y(5)+200]))),a,b,'UniformOutput',false);
                            mu = mean([tdata{:}]);
                            sigma = std([tdata{:}]);
                            a = cellfun(@(x) (x-mu)./sigma,a,'UniformOutput',false);
                            psth.cue(end+1,:) = mean(reshape(cell2mat(cellfun(@(x,y) x(y(1):y(1)+100),a,b,'UniformOutput',0)),[101,length(b)]),2);
                            if ~isnan(ephys_data.units(j).hemisphere) & ephys_data.units(j).hemisphere
                                [~,t1]=ismember(find(behavior_data.events.choice ~= 1),t'); t1 = t1(t1~=0); a1 = a(t1); b1 = b(t1);
                                psth.movement_contra(end+1,:) = mean(reshape(cell2mat(cellfun(@(x,y) x(y(2)-50:y(2)+50),a1,b1,'UniformOutput',0)),[101,length(b1)]),2);
                                [~,t1]=ismember(find(behavior_data.events.choice == 1),t'); t1 = t1(t1~=0); a1 = a(t1); b1 = b(t1);
                                psth.movement_ipsi(end+1,:) = mean(reshape(cell2mat(cellfun(@(x,y) x(y(2)-50:y(2)+50),a1,b1,'UniformOutput',0)),[101,length(b1)]),2);
                            else
                                [~,t1]=ismember(find(behavior_data.events.choice == 1),t'); t1 = t1(t1~=0); a1 = a(t1); b1 = b(t1);
                                psth.movement_contra(end+1,:) = mean(reshape(cell2mat(cellfun(@(x,y) x(y(2)-50:y(2)+50),a1,b1,'UniformOutput',0)),[101,length(b1)]),2);
                                [~,t1]=ismember(find(behavior_data.events.choice ~= 1),t'); t1 = t1(t1~=0); a1 = a(t1); b1 = b(t1);
                                psth.movement_ipsi(end+1,:) = mean(reshape(cell2mat(cellfun(@(x,y) x(y(2)-50:y(2)+50),a1,b1,'UniformOutput',0)),[101,length(b1)]),2);
                            end
                            [~,t1]=ismember(find(behavior_data.events.laser == 1),t'); t1 = t1(t1~=0); a1 = a(t1); b1 = b(t1);
                            psth.CS_plus(end+1,:) = mean(reshape(cell2mat(cellfun(@(x,y) x(y(4):y(4)+200),a1,b1,'UniformOutput',0)),[201,length(b1)]),2);
                            [~,t1]=ismember(find(behavior_data.events.feedback == -1),t'); t1 = t1(t1~=0); a1 = a(t1); b1 = b(t1);
                            psth.CS_minus(end+1,:) = mean(reshape(cell2mat(cellfun(@(x,y) x(y(4):y(4)+200),a1,b1,'UniformOutput',0)),[201,length(b1)]),2);
                            [~,t1]=ismember(find(~isnan(behavior_data.times.laser_onset)),t'); t1 = t1(t1~=0); a1 = a(t1); b1 = b(t1);
                            psth.VTA_stim(end+1,:) = mean(reshape(cell2mat(cellfun(@(x,y) x(y(5):y(5)+200),a1,b1,'UniformOutput',0)),[201,length(b1)]),2);
                            
                            
                            trials = behavior_data.analysis.trials_include;
                            trials_odd = find(ismember(trials,trials(1:2:end)));
                            trials_even = find(ismember(trials,trials(2:2:end)));
                            trials_cue = find(trials);
                            if ~isnan(ephys_data.units(j).hemisphere) & ephys_data.units(j).hemisphere
                                trials_ipsi = find(behavior_data.events.choice(trials) == 1);
                                trials_contra = find(behavior_data.events.choice(trials) ~= 1);
                            else
                                trials_ipsi = find(behavior_data.events.choice(trials) ~= 1);
                                trials_contra = find(behavior_data.events.choice(trials) == 1);
                            end
                            trials_CSplus = find(behavior_data.events.feedback(trials) == 1);
                            trials_laser = find(behavior_data.events.feedback(trials) == 1 .* ~isnan(behavior_data.times.laser_onset(trials)));
                            trials_CSminus = find(behavior_data.events.feedback(trials) == -1);
                            
                            load([output_dir,'neuron_',num2str(j,'%03.0f'),'_session_',num2str(0,'%03.0f'),'.mat'])
                            
                            PSTH_final.all.cue(end+1,:)  = mean(reshape(cell2mat(cellfun(@(x,y) x(y(1):y(1)+100),output.AllValues(end).fit2.stats.y_real,b,'UniformOutput',0)),[101,length(output.AllValues(end).fit2.stats.y_real)]),2);
                            PSTH_final.all_predictions.cue(end+1,:) = mean(reshape(cell2mat(cellfun(@(x,y) x(y(1):y(1)+100),output.AllValues(end).fit2.stats.y_pred,b,'UniformOutput',0)),[101,length(output.AllValues(end).fit2.stats.y_pred)]),2);
                            PSTH_final.even.cue(end+1,:) = mean(reshape(cell2mat(cellfun(@(x,y) x(y(1):y(1)+100),output.AllValues(end).fit2.stats.y_real(trials_even),b(trials_even),'UniformOutput',0)),[101,length(output.AllValues(end).fit2.stats.y_real(trials_even))]),2);
                            PSTH_final.even_predictions.cue(end+1,:)  = mean(reshape(cell2mat(cellfun(@(x,y) x(y(1):y(1)+100),output.AllValues(end).fit2.stats.y_pred(trials_even),b(trials_even),'UniformOutput',0)),[101,length(output.AllValues(end).fit2.stats.y_pred(trials_even))]),2);
                            PSTH_final.odd.cue(end+1,:)  = mean(reshape(cell2mat(cellfun(@(x,y) x(y(1):y(1)+100),output.AllValues(end).fit2.stats.y_real(trials_odd),b(trials_odd),'UniformOutput',0)),[101,length(output.AllValues(end).fit2.stats.y_real(trials_odd))]),2);
                            
                            PSTH_final.all.movement_ipsi(end+1,:)  = mean(reshape(cell2mat(cellfun(@(x,y) x(y(2)-50:y(2)+50),output.AllValues(end).fit2.stats.y_real(trials_ipsi),b(trials_ipsi),'UniformOutput',0)),[101,length(output.AllValues(end).fit2.stats.y_real(trials_ipsi))]),2);
                            PSTH_final.all_predictions.movement_ipsi(end+1,:) = mean(reshape(cell2mat(cellfun(@(x,y) x(y(2)-50:y(2)+50),output.AllValues(end).fit2.stats.y_pred(trials_ipsi),b(trials_ipsi),'UniformOutput',0)),[101,length(output.AllValues(end).fit2.stats.y_pred(trials_ipsi))]),2);
                            PSTH_final.even.movement_ipsi(end+1,:) = mean(reshape(cell2mat(cellfun(@(x,y) x(y(2)-50:y(2)+50),output.AllValues(end).fit2.stats.y_real(intersect(trials_ipsi,trials_even)),b(intersect(trials_ipsi,trials_even)),'UniformOutput',0)),[101,length(output.AllValues(end).fit2.stats.y_real(intersect(trials_ipsi,trials_even)))]),2);
                            PSTH_final.even_predictions.movement_ipsi(end+1,:)  = mean(reshape(cell2mat(cellfun(@(x,y) x(y(2)-50:y(2)+50),output.AllValues(end).fit2.stats.y_pred(intersect(trials_ipsi,trials_even)),b(intersect(trials_ipsi,trials_even)),'UniformOutput',0)),[101,length(output.AllValues(end).fit2.stats.y_pred(intersect(trials_ipsi,trials_even)))]),2);
                            PSTH_final.odd.movement_ipsi(end+1,:)  = mean(reshape(cell2mat(cellfun(@(x,y) x(y(2)-50:y(2)+50),output.AllValues(end).fit2.stats.y_real(intersect(trials_ipsi,trials_odd)),b(intersect(trials_ipsi,trials_odd)),'UniformOutput',0)),[101,length(output.AllValues(end).fit2.stats.y_real(intersect(trials_ipsi,trials_odd)))]),2);
                            
                            PSTH_final.all.movement_contra(end+1,:)  = mean(reshape(cell2mat(cellfun(@(x,y) x(y(2)-50:y(2)+50),output.AllValues(end).fit2.stats.y_real(trials_contra),b(trials_contra),'UniformOutput',0)),[101,length(output.AllValues(end).fit2.stats.y_real(trials_contra))]),2);
                            PSTH_final.all_predictions.movement_contra(end+1,:) = mean(reshape(cell2mat(cellfun(@(x,y) x(y(2)-50:y(2)+50),output.AllValues(end).fit2.stats.y_pred(trials_contra),b(trials_contra),'UniformOutput',0)),[101,length(output.AllValues(end).fit2.stats.y_pred(trials_contra))]),2);
                            PSTH_final.even.movement_contra(end+1,:) = mean(reshape(cell2mat(cellfun(@(x,y) x(y(2)-50:y(2)+50),output.AllValues(end).fit2.stats.y_real(intersect(trials_contra,trials_even)),b(intersect(trials_contra,trials_even)),'UniformOutput',0)),[101,length(output.AllValues(end).fit2.stats.y_real(intersect(trials_contra,trials_even)))]),2);
                            PSTH_final.even_predictions.movement_contra(end+1,:)  = mean(reshape(cell2mat(cellfun(@(x,y) x(y(2)-50:y(2)+50),output.AllValues(end).fit2.stats.y_pred(intersect(trials_contra,trials_even)),b(intersect(trials_contra,trials_even)),'UniformOutput',0)),[101,length(output.AllValues(end).fit2.stats.y_pred(intersect(trials_contra,trials_even)))]),2);
                            PSTH_final.odd.movement_contra(end+1,:)  = mean(reshape(cell2mat(cellfun(@(x,y) x(y(2)-50:y(2)+50),output.AllValues(end).fit2.stats.y_real(intersect(trials_contra,trials_odd)),b(intersect(trials_contra,trials_odd)),'UniformOutput',0)),[101,length(output.AllValues(end).fit2.stats.y_real(intersect(trials_contra,trials_odd)))]),2);
                            
                            PSTH_final.all.CS_plus(end+1,:)  = mean(reshape(cell2mat(cellfun(@(x,y) x(y(4):y(4)+200),output.AllValues(end).fit2.stats.y_real(trials_CSplus),b(trials_CSplus),'UniformOutput',0)),[201,length(output.AllValues(end).fit2.stats.y_real(trials_CSplus))]),2);
                            PSTH_final.all_predictions.CS_plus(end+1,:) = mean(reshape(cell2mat(cellfun(@(x,y) x(y(4):y(4)+200),output.AllValues(end).fit2.stats.y_pred(trials_CSplus),b(trials_CSplus),'UniformOutput',0)),[201,length(output.AllValues(end).fit2.stats.y_pred(trials_CSplus))]),2);
                            PSTH_final.even.CS_plus(end+1,:) = mean(reshape(cell2mat(cellfun(@(x,y) x(y(4):y(4)+200),output.AllValues(end).fit2.stats.y_real(intersect(trials_CSplus,trials_even)),b(intersect(trials_CSplus,trials_even)),'UniformOutput',0)),[201,length(output.AllValues(end).fit2.stats.y_real(intersect(trials_CSplus,trials_even)))]),2);
                            PSTH_final.even_predictions.CS_plus(end+1,:)  = mean(reshape(cell2mat(cellfun(@(x,y) x(y(4):y(4)+200),output.AllValues(end).fit2.stats.y_pred(intersect(trials_CSplus,trials_even)),b(intersect(trials_CSplus,trials_even)),'UniformOutput',0)),[201,length(output.AllValues(end).fit2.stats.y_pred(intersect(trials_CSplus,trials_even)))]),2);
                            PSTH_final.odd.CS_plus(end+1,:)  = mean(reshape(cell2mat(cellfun(@(x,y) x(y(4):y(4)+200),output.AllValues(end).fit2.stats.y_real(intersect(trials_CSplus,trials_odd)),b(intersect(trials_CSplus,trials_odd)),'UniformOutput',0)),[201,length(output.AllValues(end).fit2.stats.y_real(intersect(trials_CSplus,trials_odd)))]),2);
                            
                            PSTH_final.all.VTA_stim(end+1,:)  = mean(reshape(cell2mat(cellfun(@(x,y) x(y(5):y(5)+200),output.AllValues(end).fit2.stats.y_real(trials_laser),b(trials_laser),'UniformOutput',0)),[201,length(output.AllValues(end).fit2.stats.y_real(trials_laser))]),2);
                            PSTH_final.all_predictions.VTA_stim(end+1,:) = mean(reshape(cell2mat(cellfun(@(x,y) x(y(5):y(5)+200),output.AllValues(end).fit2.stats.y_pred(trials_laser),b(trials_laser),'UniformOutput',0)),[201,length(output.AllValues(end).fit2.stats.y_pred(trials_laser))]),2);
                            PSTH_final.even.VTA_stim(end+1,:) = mean(reshape(cell2mat(cellfun(@(x,y) x(y(5):y(5)+200),output.AllValues(end).fit2.stats.y_real(intersect(trials_laser,trials_even)),b(intersect(trials_laser,trials_even)),'UniformOutput',0)),[201,length(output.AllValues(end).fit2.stats.y_real(intersect(trials_laser,trials_even)))]),2);
                            PSTH_final.even_predictions.VTA_stim(end+1,:)  = mean(reshape(cell2mat(cellfun(@(x,y) x(y(5):y(5)+200),output.AllValues(end).fit2.stats.y_pred(intersect(trials_laser,trials_even)),b(intersect(trials_laser,trials_even)),'UniformOutput',0)),[201,length(output.AllValues(end).fit2.stats.y_pred(intersect(trials_laser,trials_even)))]),2);
                            PSTH_final.odd.VTA_stim(end+1,:)  = mean(reshape(cell2mat(cellfun(@(x,y) x(y(5):y(5)+200),output.AllValues(end).fit2.stats.y_real(intersect(trials_laser,trials_odd)),b(intersect(trials_laser,trials_odd)),'UniformOutput',0)),[201,length(output.AllValues(end).fit2.stats.y_real(intersect(trials_laser,trials_odd)))]),2);
                            
                            PSTH_final.all.CS_minus(end+1,:)  = mean(reshape(cell2mat(cellfun(@(x,y) x(y(4):y(4)+200),output.AllValues(end).fit2.stats.y_real(trials_CSminus),b(trials_CSminus),'UniformOutput',0)),[201,length(output.AllValues(end).fit2.stats.y_real(trials_CSminus))]),2);
                            PSTH_final.all_predictions.CS_minus(end+1,:) = mean(reshape(cell2mat(cellfun(@(x,y) x(y(4):y(4)+200),output.AllValues(end).fit2.stats.y_pred(trials_CSminus),b(trials_CSminus),'UniformOutput',0)),[201,length(output.AllValues(end).fit2.stats.y_pred(trials_CSminus))]),2);
                            PSTH_final.even.CS_minus(end+1,:) = mean(reshape(cell2mat(cellfun(@(x,y) x(y(4):y(4)+200),output.AllValues(end).fit2.stats.y_real(intersect(trials_CSminus,trials_even)),b(intersect(trials_CSminus,trials_even)),'UniformOutput',0)),[201,length(output.AllValues(end).fit2.stats.y_real(intersect(trials_CSminus,trials_even)))]),2);
                            PSTH_final.even_predictions.CS_minus(end+1,:)  = mean(reshape(cell2mat(cellfun(@(x,y) x(y(4):y(4)+200),output.AllValues(end).fit2.stats.y_pred(intersect(trials_CSminus,trials_even)),b(intersect(trials_CSminus,trials_even)),'UniformOutput',0)),[201,length(output.AllValues(end).fit2.stats.y_pred(intersect(trials_CSminus,trials_even)))]),2);
                            PSTH_final.odd.CS_minus(end+1,:)  = mean(reshape(cell2mat(cellfun(@(x,y) x(y(4):y(4)+200),output.AllValues(end).fit2.stats.y_real(intersect(trials_CSminus,trials_odd)),b(intersect(trials_CSminus,trials_odd)),'UniformOutput',0)),[201,length(output.AllValues(end).fit2.stats.y_real(intersect(trials_CSminus,trials_odd)))]),2);
                            
                            r2(end+1) = output.AllValues(end).fit2.stats.R2;
                            lambda1(end+1) = output.AllValues(end).fit1.lambda;
                            lambda2(end+1) = output.AllValues(end).fit2.lambda;
                            iterations(end+1) = length(output.AllValues);
                            time(end+1) = output.time;
                            
                            kernels.cue(end+1,:) = output.AllValues(end).kernels{1}{1}(101:201);
                            kernels.movement_contra(end+1,:) = output.AllValues(end).kernels{2}{1}(51:151);
                            kernels.movement_ipsi(end+1,:) = output.AllValues(end).kernels{3}{1}(51:151);
                            kernels.outcome_water(end+1,:) = output.AllValues(end).kernels{4}{1}(201:401);
                            kernels.CS_plus(end+1,:) = output.AllValues(end).kernels{5}{1}(201:401);
                            kernels.CS_minus(end+1,:) = output.AllValues(end).kernels{6}{1}(201:401);
                            kernels.VTA_stim(end+1,:) = output.AllValues(end).kernels{7}{1}(201:401);
                            
                            gains.cue(end+1,:)              = [output.AllValues(end).coefficients{1}(1) output.remove_StateValue_AllKernels.coefficients{1}(2:4) output.remove_ActionValue_AllKernels.coefficients{1}(5:7)];
                            gains.movement_contra(end+1,:)  = [output.AllValues(end).coefficients{2}(1) output.remove_StateValue_AllKernels.coefficients{2}(2:4) output.remove_ActionValue_AllKernels.coefficients{2}(5:7)];
                            gains.movement_ipsi(end+1,:)    = [output.AllValues(end).coefficients{3}(1) output.remove_StateValue_AllKernels.coefficients{3}(2:4) output.remove_ActionValue_AllKernels.coefficients{3}(5:7)];
                            gains.outcome_water(end+1,:)    = [output.AllValues(end).coefficients{4}(1) output.remove_StateValue_AllKernels.coefficients{4}(2:4) output.remove_ActionValue_AllKernels.coefficients{4}(5:7)];
                            gains.CS_plus(end+1,:)    = [output.AllValues(end).coefficients{5}(1) output.remove_StateValue_AllKernels.coefficients{5}(2:4) output.remove_ActionValue_AllKernels.coefficients{5}(5:7)];
                            gains.CS_minus(end+1,:)     = [output.AllValues(end).coefficients{6}(1) output.remove_StateValue_AllKernels.coefficients{6}(2:4) output.remove_ActionValue_AllKernels.coefficients{6}(5:7)];
                            gains.VTA_stim(end+1,:)   = [output.AllValues(end).coefficients{7}(1) output.remove_StateValue_AllKernels.coefficients{7}(2:4) output.remove_ActionValue_AllKernels.coefficients{7}(5:7)];
                            
                            real_remove_ActionValue_AllKernels = output.remove_ActionValue_AllKernels.Fstat.AllValues;
                            real_remove_StateValue_AllKernels = output.remove_StateValue_AllKernels.Fstat.AllValues;
                            real_remove_AllValues_AllKernels = output.remove_AllValues_AllKernels.Fstat.AllValues;
                            
                            null_remove_AllValues_AllKernels = [];
                            null_remove_ActionValue_AllKernels = [];
                            null_remove_StateValue_AllKernels = [];
                            null_remove_AllValues_AllKernels_r2 = [];
                            null_remove_ActionValue_AllKernels_r2 = [];
                            null_remove_StateValue_AllKernels_r2 = [];
                            
                            parfor k = 1:null_sessions
                                a = load([output_dir,'neuron_',num2str(j,'%03.0f'),'_session_',num2str(k,'%03.0f'),'.mat']);
                                null_remove_ActionValue_AllKernels(k)    = a.output.remove_ActionValue_AllKernels.Fstat.AllValues;
                                null_remove_StateValue_AllKernels(k)     = a.output.remove_StateValue_AllKernels.Fstat.AllValues;
                                null_remove_AllValues_AllKernels(k)      = a.output.remove_AllValues_AllKernels.Fstat.AllValues;
                                null_remove_AllValues_AllKernels_r2(k)   = a.output.AllValues_refit.fit2.stats.R2 - a.output.remove_AllValues_AllKernels.fit2.stats.R2;
                                null_remove_ActionValue_AllKernels_r2(k) = a.output.AllValues_refit.fit2.stats.R2 - a.output.remove_ActionValue_AllKernels.fit2.stats.R2;
                                null_remove_StateValue_AllKernels_r2(k)  = a.output.AllValues_refit.fit2.stats.R2 - a.output.remove_StateValue_AllKernels.fit2.stats.R2;
                            end
                            
                            pvalues.AllKernels.remove_AllValues(end+1)	 = null_distribution_pvalue(real_remove_AllValues_AllKernels,null_remove_AllValues_AllKernels);
                            pvalues.AllKernels.remove_RelativeValue(end+1) = null_distribution_pvalue(real_remove_ActionValue_AllKernels,null_remove_ActionValue_AllKernels);
                            pvalues.AllKernels.remove_StateValue(end+1)	 = null_distribution_pvalue(real_remove_StateValue_AllKernels,null_remove_StateValue_AllKernels);
                            
                            fstats.AllKernels.remove_AllValues(end+1)	 = real_remove_AllValues_AllKernels;
                            fstats.AllKernels.remove_RelativeValue(end+1)	 = real_remove_ActionValue_AllKernels;
                            fstats.AllKernels.remove_StateValue(end+1)	 = real_remove_StateValue_AllKernels;
                            
                            delta_r2.AllKernels.remove_AllValues(end+1)         = output.AllValues_refit.fit2.stats.R2 - output.remove_AllValues_AllKernels.fit2.stats.R2;
                            delta_r2.AllKernels.remove_RelativeValue(end+1)       = output.AllValues_refit.fit2.stats.R2 - output.remove_ActionValue_AllKernels.fit2.stats.R2;
                            delta_r2.AllKernels.remove_StateValue(end+1)        = output.AllValues_refit.fit2.stats.R2 - output.remove_StateValue_AllKernels.fit2.stats.R2;
                            
                            delta_r2.AllKernels.remove_AllValues_null(end+1)    = mean(null_remove_AllValues_AllKernels_r2);
                            delta_r2.AllKernels.remove_RelativeValue_null(end+1)  = mean(null_remove_ActionValue_AllKernels_r2);
                            delta_r2.AllKernels.remove_StateValue_null(end+1)   = mean(null_remove_StateValue_AllKernels_r2);
                            
                            r2v2.BilinearKernelsGains(end+1) = output.AllValues_refit.fit2.stats.R2;
                            r2v2.BilinearKernelsNoGains(end+1) = output.remove_AllValues_AllKernels.fit2.stats.R2;
                            
                            load([input_dir,'neuron_',num2str(j,'%03.0f'),'_pretest.mat'])
                            pvalues.pretest(end+1) = output.pvalue.full;
                            pvalues.gocue(end+1)   = output.pvalue.gocue;
                            pvalues.movement(end+1)   = output.pvalue.movement;
                            pvalues.outcome(end+1)   = output.pvalue.outcome;
                            pvalues.movement_ID(end+1)   = output.pvalue.movement_ID;
                            pvalues.outcome_ID(end+1)   = output.pvalue.outcome_ID;
                            pvalues.CSplus(end+1)   = output.pvalue.CSplus;
                            
                            r2v2.LinearKernels(end+1) = output.R2.full;
                            r2v2.LinearNoKernels(end+1) = output.R2.none;
                            r2v2.gocue(end+1) = output.R2.gocue;
                            r2v2.movement(end+1) = output.R2.movement;
                            r2v2.outcome(end+1) = output.R2.outcome;
                            r2v2.movement_ID(end+1) = output.R2.movement_ID;
                            r2v2.outcome_ID(end+1) = output.R2.outcome_ID;
                            r2v2.CSplus(end+1) = output.R2.CSplus;
                            
                            reg = AllenRegions_limited(realneurons(end));
                            if ismember(reg.IDs,5:8)
                                load([output_dir,'neuron_',num2str(j,'%03.0f'),'_session_000_alpha_gamma_Qlaser.mat']);
                                idx = size(fits.alpha.R2.AllValues,1)+1;
                                fits.alpha.R2.alphas = alphas(34:end);
                                for a = 1:40
                                    fits.alpha.R2.AllValues(idx,a)                          = output_alpha(a+33).AllValues_refit.fit2.stats.R2;
                                    fits.alpha.R2.remove_RelativeValue_AllKernels(idx,a)    = output_alpha(a+33).remove_ActionValue_AllKernels.fit2.stats.R2;
                                    fits.alpha.R2.remove_StateValue_AllKernels(idx,a)       = output_alpha(a+33).remove_StateValue_AllKernels.fit2.stats.R2;
                                    fits.alpha.R2.remove_AllValues_AllKernels(idx,a)        = output_alpha(a+33).remove_AllValues_AllKernels.fit2.stats.R2;
                                end
                                fits.gamma.R2.gammas = gammas(34:end);
                                for a = 1:40
                                    fits.gamma.R2.AllValues(idx,a)                          = output_gamma(a+33).AllValues_refit.fit2.stats.R2;
                                    fits.gamma.R2.remove_RelativeValue_AllKernels(idx,a)    = output_gamma(a+33).remove_ActionValue_AllKernels.fit2.stats.R2;
                                    fits.gamma.R2.remove_StateValue_AllKernels(idx,a)       = output_gamma(a+33).remove_StateValue_AllKernels.fit2.stats.R2;
                                    fits.gamma.R2.remove_AllValues_AllKernels(idx,a)        = output_gamma(a+33).remove_AllValues_AllKernels.fit2.stats.R2;
                                end
                                
                                null_alpha_remove_AllValues_AllKernels      = nan(40,200);
                                null_alpha_remove_ActionValue_AllKernels    = nan(40,200);
                                null_alpha_remove_StateValue_AllKernels     = nan(40,200);
                                null_alpha_AllValues_r2                     = nan(40,200);
                                null_alpha_remove_AllValues_AllKernels_r2   = nan(40,200);
                                null_alpha_remove_ActionValue_AllKernels_r2 = nan(40,200);
                                null_alpha_remove_StateValue_AllKernels_r2  = nan(40,200);
                                null_gamma_remove_AllValues_AllKernels      = nan(40,200);
                                null_gamma_remove_ActionValue_AllKernels    = nan(40,200);
                                null_gamma_remove_StateValue_AllKernels     = nan(40,200);
                                null_gamma_AllValues_r2                     = nan(40,200);
                                null_gamma_remove_AllValues_AllKernels_r2   = nan(40,200);
                                null_gamma_remove_ActionValue_AllKernels_r2 = nan(40,200);
                                null_gamma_remove_StateValue_AllKernels_r2  = nan(40,200);
                                parfor k = 1:null_sessions
                                    a = load([output_dir,'neuron_',num2str(j,'%03.0f'),'_session_',num2str(k,'%03.0f'),'_alpha_gamma_Qlaser.mat']);
                                    for b = 1:40
                                        null_alpha_remove_AllValues_AllKernels(b,k)      = a.output_alpha(b).remove_AllValues_AllKernels.Fstat.AllValues;
                                        null_alpha_remove_ActionValue_AllKernels(b,k)    = a.output_alpha(b).remove_ActionValue_AllKernels.Fstat.remove_AllValues_AllKernels;
                                        null_alpha_remove_StateValue_AllKernels(b,k)     = a.output_alpha(b).remove_StateValue_AllKernels.Fstat.remove_AllValues_AllKernels;
                                        null_alpha_AllValues_r2(b,k)                     = a.output_alpha(b).AllValues_refit.fit2.stats.R2;
                                        null_alpha_remove_AllValues_AllKernels_r2(b,k)   = a.output_alpha(b).remove_AllValues_AllKernels.fit2.stats.R2;
                                        null_alpha_remove_ActionValue_AllKernels_r2(b,k) = a.output_alpha(b).remove_ActionValue_AllKernels.fit2.stats.R2;
                                        null_alpha_remove_StateValue_AllKernels_r2(b,k)  = a.output_alpha(b).remove_StateValue_AllKernels.fit2.stats.R2;
                                        null_gamma_remove_AllValues_AllKernels(b,k)      = a.output_gamma(b).remove_AllValues_AllKernels.Fstat.AllValues;
                                        null_gamma_remove_ActionValue_AllKernels(b,k)    = a.output_gamma(b).remove_ActionValue_AllKernels.Fstat.remove_AllValues_AllKernels;
                                        null_gamma_remove_StateValue_AllKernels(b,k)     = a.output_gamma(b).remove_StateValue_AllKernels.Fstat.remove_AllValues_AllKernels;
                                        null_gamma_AllValues_r2(b,k)                     = a.output_gamma(b).AllValues_refit.fit2.stats.R2;
                                        null_gamma_remove_AllValues_AllKernels_r2(b,k)   = a.output_gamma(b).remove_AllValues_AllKernels.fit2.stats.R2;
                                        null_gamma_remove_ActionValue_AllKernels_r2(b,k) = a.output_gamma(b).remove_ActionValue_AllKernels.fit2.stats.R2;
                                        null_gamma_remove_StateValue_AllKernels_r2(b,k)  = a.output_gamma(b).remove_StateValue_AllKernels.fit2.stats.R2;
                                    end
                                end
                                fits.alpha.R2.AllValues_null(idx,1:40)                          = mean(null_alpha_AllValues_r2,2);
                                fits.alpha.R2.remove_AllValues_AllKernels_null(idx,1:40)        = mean(null_alpha_remove_AllValues_AllKernels_r2,2);
                                fits.alpha.R2.remove_RelativeValue_AllKernels_null(idx,1:40)    = mean(null_alpha_remove_ActionValue_AllKernels_r2,2);
                                fits.alpha.R2.remove_StateValue_AllKernels_null(idx,1:40)       = mean(null_alpha_remove_StateValue_AllKernels_r2,2);
                                fits.gamma.R2.AllValues_null(idx,1:40)                          = mean(null_gamma_AllValues_r2,2);
                                fits.gamma.R2.remove_AllValues_AllKernels_null(idx,1:40)        = mean(null_gamma_remove_AllValues_AllKernels_r2,2);
                                fits.gamma.R2.remove_RelativeValue_AllKernels_null(idx,1:40)    = mean(null_gamma_remove_ActionValue_AllKernels_r2,2);
                                fits.gamma.R2.remove_StateValue_AllKernels_null(idx,1:40)       = mean(null_gamma_remove_StateValue_AllKernels_r2,2);
                                for b = 1:40
                                    fits.alpha.pvalues.remove_AllValues_AllKernels(idx,b)       = null_distribution_pvalue(output_alpha(b+33).remove_AllValues_AllKernels.Fstat.AllValues,null_alpha_remove_AllValues_AllKernels(b,:));
                                    fits.alpha.pvalues.remove_RelativeValue_AllKernels(idx,b)   = null_distribution_pvalue(output_alpha(b+33).remove_ActionValue_AllKernels.Fstat.remove_AllValues_AllKernels,null_alpha_remove_ActionValue_AllKernels(b,:));
                                    fits.alpha.pvalues.remove_StateValue_AllKernels(idx,b)      = null_distribution_pvalue(output_alpha(b+33).remove_StateValue_AllKernels.Fstat.remove_AllValues_AllKernels,null_alpha_remove_StateValue_AllKernels(b,:));
                                    fits.gamma.pvalues.remove_AllValues_AllKernels(idx,b)       = null_distribution_pvalue(output_gamma(b+33).remove_AllValues_AllKernels.Fstat.AllValues,null_gamma_remove_AllValues_AllKernels(b,:));
                                    fits.gamma.pvalues.remove_RelativeValue_AllKernels(idx,b)   = null_distribution_pvalue(output_gamma(b+33).remove_ActionValue_AllKernels.Fstat.remove_AllValues_AllKernels,null_gamma_remove_ActionValue_AllKernels(b,:));
                                    fits.gamma.pvalues.remove_StateValue_AllKernels(idx,b)      = null_distribution_pvalue(output_gamma(b+33).remove_StateValue_AllKernels.Fstat.remove_AllValues_AllKernels,null_gamma_remove_StateValue_AllKernels(b,:));
                                end
                                
                                load([output_dir,'neuron_',num2str(j,'%03.0f'),'_session_000_REVISIONS_state_value.mat']);
                                real_remove_StateValue_Q_total              = output.Q_total.remove_StateValue_AllKernels.Fstat.AllValues;
                                null_remove_StateValue_Q_total              = [];
                                null_remove_StateValue_Q_total_r2           = [];
                                real_remove_StateValue_Q_total_weighted     = output.Q_total_weighted.remove_StateValue_AllKernels.Fstat.AllValues;
                                null_remove_StateValue_Q_total_weighted     = [];
                                null_remove_StateValue_Q_total_weighted_r2  = [];
                                real_remove_StateValue_matched              = output.state_value.remove_StateValue_AllKernels.Fstat.AllValues;
                                null_remove_StateValue_matched              = [];
                                null_remove_StateValue_matched_r2           = [];
                                parfor k = 1:null_sessions
                                    a = load([output_dir,'neuron_',num2str(j,'%03.0f'),'_session_',num2str(k,'%03.0f'),'_REVISIONS_state_value.mat']);
                                    null_remove_StateValue_Q_total(k)             = a.output.Q_total.remove_StateValue_AllKernels.Fstat.AllValues;
                                    null_remove_StateValue_Q_total_weighted(k)    = a.output.Q_total_weighted.remove_StateValue_AllKernels.Fstat.AllValues;
                                    null_remove_StateValue_matched(k)             = a.output.state_value.remove_StateValue_AllKernels.Fstat.AllValues;
                                    null_remove_StateValue_Q_total_r2(k)          = a.output.Q_total.AllValues_refit.fit2.stats.R2          - a.output.Q_total.remove_StateValue_AllKernels.fit2.stats.R2;
                                    null_remove_StateValue_Q_total_weighted_r2(k) = a.output.Q_total_weighted.AllValues_refit.fit2.stats.R2 - a.output.Q_total_weighted.remove_StateValue_AllKernels.fit2.stats.R2;
                                    null_remove_StateValue_matched_r2(k)          = a.output.state_value.AllValues_refit.fit2.stats.R2      - a.output.state_value.remove_StateValue_AllKernels.fit2.stats.R2;
                                end
                                pvalues.AllKernels.remove_StateValue_Q_total(end+1)                 = null_distribution_pvalue(real_remove_StateValue_Q_total,          null_remove_StateValue_Q_total);
                                delta_r2.AllKernels.remove_StateValue_Q_total(end+1)                = output.Q_total.AllValues_refit.fit2.stats.R2          - output.Q_total.remove_StateValue_AllKernels.fit2.stats.R2;
                                delta_r2.AllKernels.remove_StateValue_Q_total_null(end+1)           = mean(null_remove_StateValue_Q_total_r2);
                                pvalues.AllKernels.remove_StateValue_Q_total_weighted(end+1)        = null_distribution_pvalue(real_remove_StateValue_Q_total_weighted, null_remove_StateValue_Q_total_weighted);
                                delta_r2.AllKernels.remove_StateValue_Q_total_weighted(end+1)       = output.Q_total_weighted.AllValues_refit.fit2.stats.R2 - output.Q_total_weighted.remove_StateValue_AllKernels.fit2.stats.R2;
                                delta_r2.AllKernels.remove_StateValue_Q_total_weighted_null(end+1)  = mean(null_remove_StateValue_Q_total_weighted_r2);
                                pvalues.AllKernels.remove_StateValue_matched(end+1)                 = null_distribution_pvalue(real_remove_StateValue_matched, null_remove_StateValue_matched);
                                delta_r2.AllKernels.remove_StateValue_matched(end+1)                = output.state_value.AllValues_refit.fit2.stats.R2 - output.state_value.remove_StateValue_AllKernels.fit2.stats.R2;
                                delta_r2.AllKernels.remove_StateValue_matched_null(end+1)           = mean(null_remove_StateValue_matched_r2);

                                
                                load([output_dir,'neuron_',num2str(j,'%03.0f'),'_session_000_REVISIONS_prev_trial.mat']);
                                real_CS_plus_by_laser              = output.prev_CS_by_laser.Fstat.AllValues;
                                null_CS_plus_by_laser              = [];
                                null_CS_plus_by_laser_r2           = [];
                                parfor k = 1:null_sessions
                                    a = load([output_dir,'neuron_',num2str(j,'%03.0f'),'_session_',num2str(k,'%03.0f'),'_REVISIONS_prev_trial.mat']);
                                    null_CS_plus_by_laser(k)       = a.output.prev_CS_by_laser.Fstat.AllValues;
                                    null_CS_plus_by_laser_r2(k)     = a.output.prev_CS_by_laser.fit2.stats.R2 - a.output.prev_CS.fit2.stats.R2;
                                end
                                pvalues.AllKernels.CS_plus_by_laser(end+1)       = null_distribution_pvalue(real_CS_plus_by_laser, null_CS_plus_by_laser);
                                delta_r2.AllKernels.CS_plus_by_laser(end+1)      = output.prev_CS_by_laser.fit2.stats.R2 - output.prev_CS.fit2.stats.R2;
                                delta_r2.AllKernels.CS_plus_by_laser_null(end+1) = mean(null_CS_plus_by_laser_r2);

                            else
                                
                                idx = size(fits.alpha.R2.AllValues,1)+1;
                                fits.alpha.R2.AllValues(idx,1:40) = NaN;
                                fits.alpha.R2.remove_RelativeValue_AllKernels(idx,1:40) = NaN;
                                fits.alpha.R2.remove_StateValue_AllKernels(idx,1:40) = NaN;
                                fits.alpha.R2.remove_AllValues_AllKernels(idx,1:40) = NaN;
                                fits.gamma.R2.AllValues(idx,1:40) = NaN;
                                fits.gamma.R2.remove_RelativeValue_AllKernels(idx,1:40) = NaN;
                                fits.gamma.R2.remove_StateValue_AllKernels(idx,1:40) = NaN;
                                fits.gamma.R2.remove_AllValues_AllKernels(idx,1:40) = NaN;
                                fits.alpha.R2.AllValues_null(idx,1:40) = NaN;
                                fits.alpha.R2.remove_AllValues_AllKernels_null(idx,1:40) = NaN;
                                fits.alpha.R2.remove_RelativeValue_AllKernels_null(idx,1:40) = NaN;
                                fits.alpha.R2.remove_StateValue_AllKernels_null(idx,1:40) = NaN;
                                fits.gamma.R2.AllValues_null(idx,1:40) = NaN;
                                fits.gamma.R2.remove_AllValues_AllKernels_null(idx,1:40) = NaN;
                                fits.gamma.R2.remove_RelativeValue_AllKernels_null(idx,1:40) = NaN;
                                fits.gamma.R2.remove_StateValue_AllKernels_null(idx,1:40) = NaN;
                                fits.alpha.pvalues.remove_AllValues_AllKernels(idx,1:40) = NaN;
                                fits.alpha.pvalues.remove_RelativeValue_AllKernels(idx,1:40) = NaN;
                                fits.alpha.pvalues.remove_StateValue_AllKernels(idx,1:40) = NaN;
                                fits.gamma.pvalues.remove_AllValues_AllKernels(idx,1:40) = NaN;
                                fits.gamma.pvalues.remove_RelativeValue_AllKernels(idx,1:40) = NaN;
                                fits.gamma.pvalues.remove_StateValue_AllKernels(idx,1:40) = NaN;
                                
                                pvalues.AllKernels.remove_StateValue_Q_total(end+1) = NaN;
                                pvalues.AllKernels.remove_StateValue_Q_total_weighted(end+1) = NaN;
                                pvalues.AllKernels.remove_StateValue_matched(end+1) = NaN;
                                delta_r2.AllKernels.remove_StateValue_Q_total(end+1) = NaN;
                                delta_r2.AllKernels.remove_StateValue_Q_total_null(end+1) = NaN;
                                delta_r2.AllKernels.remove_StateValue_Q_total_weighted(end+1) = NaN;
                                delta_r2.AllKernels.remove_StateValue_Q_total_weighted_null(end+1) = NaN;
                                delta_r2.AllKernels.remove_StateValue_matched(end+1) = NaN;
                                delta_r2.AllKernels.remove_StateValue_matched_null(end+1) = NaN;
                                
                                pvalues.AllKernels.CS_plus_by_laser(end+1) = NaN;
                                delta_r2.AllKernels.CS_plus_by_laser(end+1) = NaN;
                                delta_r2.AllKernels.CS_plus_by_laser_null(end+1) = NaN;

                            end
                            
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
EncodingSummary.model           = 'RelativeValue_StateValue';
EncodingSummary.animal_id       = animal_id;
EncodingSummary.recording_id    = recording_id;
EncodingSummary.recording_name  = recording;
EncodingSummary.probe           = probe;
EncodingSummary.cluster         = cluster;
EncodingSummary.firing_rate     = firing_rate;
EncodingSummary.region_id       = regions.IDs;
EncodingSummary.region_name     = {realneurons(:).region};
EncodingSummary.region_key      = regions.key;
EncodingSummary.PSTHs           = psth;
EncodingSummary.PSTHs_final     = PSTH_final;
EncodingSummary.kernels         = kernels;
EncodingSummary.gains           = gains;
EncodingSummary.fit.r2          = r2;
EncodingSummary.fit.lambda1     = lambda1;
EncodingSummary.fit.lambda2     = lambda2;
EncodingSummary.fit.iterations  = iterations;
EncodingSummary.fit.time        = time;
EncodingSummary.pvalues         = pvalues;
EncodingSummary.delta_r2        = delta_r2;
EncodingSummary.raw_r2          = r2v2;
EncodingSummary.fstats          = fstats;
EncodingSummary.inclusion_stats = units;
EncodingSummary.varyalpha       = fits;
EncodingSummary.Fails           = Fails;

clearvars -except EncodingSummary
save(strcat('encoding-model-output-',string(datetime('now','Format','yyy-MM-dd-hh-mm-a')),'.mat'))
delete(gcp('nocreate'));