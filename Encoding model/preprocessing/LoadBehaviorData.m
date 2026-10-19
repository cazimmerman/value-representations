function LoadBehaviorData(input_dir)

%% load behavior data

testdata.path       = input_dir;
testdata.times      = struct;
testdata.events     = struct;
%testdata.wheel      = struct;
testdata.analysis	= struct;

% --- trial start --- %
loadpaths.intervals      = '_ibl_trials.intervals.npy';
trialtimes = readNPY([testdata.path,loadpaths.intervals]);
testdata.times.ITI_before = trialtimes(1:end-1,2);
med_ITI_length = median(trialtimes(2:end,1)-trialtimes(1:end-1,2));
testdata.times.ITI_before = [trialtimes(1,1) - med_ITI_length; testdata.times.ITI_before];
testdata.times.start = trialtimes(:,1);

% --- go cue time ---%
loadpaths.gocue = '_ibl_trials.goCue_times.npy';
testdata.times.gocue = readNPY([testdata.path,loadpaths.gocue]);

% --- choice time --- %
testdata.times.first_movement = nan(size(testdata.times.gocue));
testdata.times.last_movement = nan(size(testdata.times.gocue));
testdata.events.movements = nan(size(testdata.times.gocue));

% --- outcome time --- %
loadpaths.feedbacktimes          = '_ibl_trials.response_times.npy';
testdata.times.outcome     = readNPY([testdata.path,loadpaths.feedbacktimes]);

% --- choice --- %
loadpaths.choice                 = '_ibl_trials.choice.npy';
testdata.events.choice        = int64(readNPY([testdata.path,loadpaths.choice]));
testdata.events.stay        = int64(testdata.events.choice==circshift(testdata.events.choice,1)); testdata.events.stay(1) = 0;

% --- total/laser reward --- %
loadpaths.feedback               = '_ibl_trials.feedbackType.npy';
A = readNPY([testdata.path,loadpaths.feedback])==1;
loadpaths.block               = '_ibl_trials.opto_block.npy';
B = readNPY([testdata.path,loadpaths.block])==0;
testdata.events.feedback   = int64(readNPY([testdata.path,loadpaths.feedback]));
testdata.events.total      = 0.*int64(A.*B);
testdata.events.laser      = int64(readNPY([testdata.path,loadpaths.feedback])>0);

% --- reward blocks --- %
loadpaths.blocks_reward           = '_ibl_trials.opto_block.npy';
testdata.events.blocks_reward  = 0.*int64(readNPY([testdata.path,loadpaths.blocks_reward]));

% --- side blocks --- %
loadpaths.blocks_side           = '_ibl_trials.probabilityLeft.npy';
testdata.events.blocks_side  = int64(readNPY([testdata.path,loadpaths.blocks_side]));

% --- trial stop --- %
loadpaths.intervals      = '_ibl_trials.intervals.npy';
trialtimes = readNPY([testdata.path,loadpaths.intervals]);
testdata.times.stop = trialtimes(:,2);
testdata.times.ITI_after = trialtimes(2:end,1);
testdata.times.ITI_after = [testdata.times.ITI_after; trialtimes(2,2) + med_ITI_length];

% --- values --- %
loadpaths.choice_pred           = 'forgetting_median_choice_prediction.npy';
testdata.events.choice_pred  = readNPY([testdata.path,loadpaths.choice_pred]);

loadpaths.value_total           = 'forgetting_median_QL.npy';
loadpaths.value_laser           = 'forgetting_median_QLreward.npy';
loadpaths.value_stay           = 'forgetting_median_QLstay.npy';
testdata.events.QL_total  = readNPY([testdata.path,loadpaths.value_total]);
testdata.events.QL_laser  = readNPY([testdata.path,loadpaths.value_laser]);
testdata.events.QL_stay  = readNPY([testdata.path,loadpaths.value_stay]);

loadpaths.value_total           = 'forgetting_median_QR.npy';
loadpaths.value_laser           = 'forgetting_median_QRreward.npy';
loadpaths.value_stay           = 'forgetting_median_QRstay.npy';
testdata.events.QR_total  = readNPY([testdata.path,loadpaths.value_total]);
testdata.events.QR_laser  = readNPY([testdata.path,loadpaths.value_laser]);
testdata.events.QR_stay  = readNPY([testdata.path,loadpaths.value_stay]);

loadpaths.state_value           = 'forgetting_median_V.npy';
testdata.events.state_value  = readNPY([testdata.path,loadpaths.state_value]);

loadpaths.Q_total_weighted           = 'forgetting_median_total_q_weighted.npy';
testdata.events.Q_total_weighted  = readNPY([testdata.path,loadpaths.Q_total_weighted]);

loadpaths.Q_total           = 'forgetting_median_total_q.npy';
testdata.events.Q_total  = readNPY([testdata.path,loadpaths.Q_total]);

loadpaths.CRAC_Vcs              = 'SeqAC_noawin_m_avchoice_median_V_cs.npy';
testdata.events.CRAC_Vcs        = readNPY([testdata.path,loadpaths.CRAC_Vcs]);
loadpaths.CRAC_Vchoice          = 'SeqAC_noawin_m_avchoice_median_V_choice.npy';
testdata.events.CRAC_Vchoice	= readNPY([testdata.path,loadpaths.CRAC_Vchoice]);
loadpaths.CRAC_PIchoice         = 'SeqAC_noawin_m_avchoice_median_pi_choice.npy';
testdata.events.CRAC_PIchoice	= readNPY([testdata.path,loadpaths.CRAC_PIchoice]);

fnames = {'QL_total','QL_laser','QL_stay','QR_total','QR_laser','QR_stay','state_value','Q_total_weighted','Q_total','CRAC_Vcs','CRAC_Vchoice','CRAC_PIchoice'};
for j = 1:length(fnames)
   testdata.events.(fnames{j}) = circshift(testdata.events.(fnames{j}),1); testdata.events.(fnames{j})(1) = 0;
end

keep = find(~isnan(testdata.times.gocue));
fnames = fieldnames(testdata.times);
for j = 1:length(fnames)
   testdata.times.(fnames{j}) = testdata.times.(fnames{j})(keep);
end
fnames = fieldnames(testdata.events);
for j = 1:length(fnames)
   testdata.events.(fnames{j}) = testdata.events.(fnames{j})(keep);
end

% --- licks --- %
loadpaths.licks           = '_ibl_trials.lick_times.npy';
A = readNPY([testdata.path,loadpaths.licks]);
loadpaths.licks           = '_ibl_trials.first_lick_times.npy';
B = readNPY([testdata.path,loadpaths.licks]);
loadpaths.licks           = '_ibl_trials.first_laser_times.npy';
C = readNPY([testdata.path,loadpaths.licks]);
loadpaths.licks           = '_ibl_trials.feedbackTypeConsumed.npy';
D = readNPY([testdata.path,loadpaths.licks]);
D = D(keep);

N_trials = length(testdata.times.gocue);
testdata.wheel.all_licks = cell(1,N_trials);
testdata.times.laser_licks = nan(N_trials,1);
testdata.times.laser_onset = nan(N_trials,1);
counter = 1;
for i = 1:N_trials
    tstart = testdata.times.gocue(i)-2;
    tend   = max([testdata.times.outcome(i),testdata.times.laser_onset(i)])+2;
    testdata.wheel.all_licks{i} = A(A>=tstart & A<=tend);
    if D(i)==1
        testdata.times.laser_licks(i) =  B(counter);
        testdata.times.laser_onset(i) =  C(counter);
        counter = counter + 1;
    end
end
%% load wheel data

loadpaths.wheelPos = '\_ibl_wheel.position.npy';
loadpaths.wheelTime = '\_ibl_wheel.timestamps.npy';
tRaw = readNPY([testdata.path,loadpaths.wheelTime]);
pRaw = readNPY([testdata.path,loadpaths.wheelPos]);
[tRaw,idx] = unique(tRaw,'stable');
pRaw = pRaw(idx);
[pInterp,tInterp,onsets,offsets] = FindMovements(pRaw,tRaw);
%% check exclusion criteria

trials_include = [];
trials_exclude = [];
for i = 1:N_trials
    if testdata.events.choice(i) == 0
        trials_exclude = [trials_exclude i];
    else
        if [i <= 10] || [i >= (N_trials-9)]
            trials_exclude = [trials_exclude i];
        else
            trial_onsets = onsets(onsets>(testdata.times.gocue(i)-0.2) & onsets<(testdata.times.outcome(i)));
            testdata.events.movements(i) = length(trial_onsets);
            if isempty(trial_onsets)
               trials_exclude = [trials_exclude i];
            else
                testdata.times.first_movement(i) = trial_onsets(1);
                testdata.times.last_movement(i) = trial_onsets(end);
                trials_include = [trials_include i];
            end
        end
    end
end
testdata.events.movements = int64(testdata.events.movements);
trials_exclude = unique(trials_exclude);
trials_include = setdiff(trials_include,trials_exclude);
disp(['Excluded ',num2str(length(trials_exclude)),' of ',num2str(length([trials_include,trials_exclude])),' trials (',num2str((length(trials_exclude)./length([trials_include,trials_exclude]))*100,3),'%)'])
%% generate wheel structure
psthbinsize = 0.005;
testdata.wheel.pos = cell(1,N_trials);
testdata.wheel.vel = cell(1,N_trials);
testdata.wheel.acc = cell(1,N_trials);
wheelRadius        = 6.2/2; % wheel radius (cm)

for j = trials_include
    id1 = testdata.times.gocue(j) - 2 - 2*psthbinsize;
    id2 = max([testdata.times.outcome(j) testdata.times.laser_onset(j)]) + 2 + psthbinsize - id1;
    id2 = floor(id2/psthbinsize)*psthbinsize;
    t = tInterp - id1;
    p = pInterp*wheelRadius;
    idx1 = find([t>=0],1,'first');
    idx2 = idx1 + id2*1000 - 1;
    p = mean(reshape(p(idx1:idx2),psthbinsize*1000,[]));
    t = mean(reshape(t(idx1:idx2),psthbinsize*1000,[]));
    idx = find(t<=min([testdata.times.first_movement(j)-id1,1.9+2*psthbinsize]),1,'last');
    p0 = median(p(idx-40:idx)); % 200 msec window before [t_first_movement] or [t_go_cue minus 100 msec] (whichever occurs earliest)
    p = p - p0;
    v = diff(p)./psthbinsize;
    a = diff(v)./psthbinsize;
    testdata.wheel.pos{j} = p(3:end);
    testdata.wheel.vel{j} = v(2:end);
    testdata.wheel.acc{j} = a(1:end);
end
%% organize and save processed data

behavior_data = testdata;
behavior_data.analysis.trials_include = trials_include';
behavior_data.analysis.trials_exclude = trials_exclude';
output_dir = ['Z:\Chris\data\ibl_da_neuropixels\',input_dir(9:end)];
if ~exist(output_dir,'dir')
    mkdir(output_dir)
end
save([output_dir,'\behavior_data.mat'],'behavior_data');
end