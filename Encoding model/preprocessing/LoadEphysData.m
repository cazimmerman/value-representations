function LoadEphysData(input_dir,probe,psthbinsize)

testdata.psthbinsize = psthbinsize;
testdata.path = input_dir;
for r = 1:length(probe)
    testdata.probe = probe{r};
    %% convert clusters.locations.npy to clusters.locations.csv
    
    funpath = 'Z:\Chris\matlab\cz\ibl_da_neuropixels_2022\preprocessing\clusters_npy2csv.py';
    filepath = [testdata.path,testdata.probe,'\'];
    systemCommand = ['python ',funpath,' ',filepath];
    [status, result] = system(systemCommand);
    %% load ephys data
    
    % --- spikes --- %
    loadpaths.spiketimes             = '\spikes.times.npy';
    loadpaths.spikeclusters          = '\spikes.clusters.npy';
    loadpaths.clustermetrics         = '\clusters.metrics.csv';
    loadpaths.location               = '\channels.locations.csv';
    loadpaths.hemispheres            = '\channels.hemisphere.npy';
    
    location_file = ['Z:\Chris\data\ibl_da_neuropixels\',testdata.path(9:end),testdata.probe,loadpaths.location];
    if isfile(location_file)
        testdata.channels.locations = readmatrix(location_file,'Range','A:A','OutputType','char','Delimiter','\t');
        delete(location_file)
        rmdir(['Z:\Chris\data\ibl_da_neuropixels\',testdata.path(9:end),testdata.probe])
        testdata.channels.hemispheres = readNPY([testdata.path,testdata.probe,loadpaths.hemispheres]);
    else
        disp('channels.locations.csv file is missing!')
        testdata.channels.locations = cellstr(repmat('Empty',[385,1]));
        testdata.channels.hemispheres = ones(385,1);
    end
    
    testdata.spikes.times            = readNPY([testdata.path,testdata.probe,loadpaths.spiketimes]);
    testdata.spikes.clusters         = readNPY([testdata.path,testdata.probe,loadpaths.spikeclusters]);
    
    warning('off'); clustermetrics = readtable([testdata.path,testdata.probe,loadpaths.clustermetrics]); warning('on');
    
    testdata.clusters.ks2_ids        = clustermetrics.cluster_id;
    testdata.clusters.channels       = clustermetrics.ch;
    
    testdata.clusters.ks2_labels     = zeros(length(testdata.clusters.ks2_ids),1);
    loadpaths.goodclusters          = '\clusters_selection.npy';
    GOOD = int64(readNPY([testdata.path,testdata.probe,loadpaths.goodclusters]));
    loadpaths.muaclusters          = '\clusters_goodmua_selection.npy';
    MUA = setdiff(int64(readNPY([testdata.path,testdata.probe,loadpaths.muaclusters])),GOOD);
    testdata.clusters.ks2_labels(ismember(clustermetrics.cluster_id,MUA)) = 2;    
    testdata.clusters.ks2_labels(ismember(clustermetrics.cluster_id,GOOD)) = 1;
    
    testdata.clusters.location       = cell(length(testdata.clusters.ks2_ids),1);
    testdata.clusters.hemisphere     = zeros(length(testdata.clusters.ks2_ids),1);
    for i = 1:length(testdata.clusters.ks2_ids)
        if testdata.clusters.channels(i)+1 <= length(testdata.channels.locations)
            testdata.clusters.location{i} = testdata.channels.locations{testdata.clusters.channels(i)+1};
            testdata.clusters.hemisphere(i) = testdata.channels.hemispheres(testdata.clusters.channels(i)+1);
        else
            testdata.clusters.location{i} = 'OffProbe';
            testdata.clusters.hemisphere(i) = NaN;
        end
    end
    
    output_dir = ['Z:\Chris\data\ibl_da_neuropixels\',testdata.path(9:end)];
    load([output_dir,'\behavior_data.mat'],'behavior_data');
    %% calculate firing rates

    N_trials = length(behavior_data.analysis.trials_include)+length(behavior_data.analysis.trials_exclude);
    trials_include = behavior_data.analysis.trials_include';
    timestamps = [behavior_data.times.gocue,behavior_data.times.first_movement,behavior_data.times.last_movement,behavior_data.times.outcome,behavior_data.times.laser_onset];
    for i = 1:length(testdata.clusters.ks2_ids)
        %%%%% SAVE METADATA %%%%%
        testdata.units(i).probe = testdata.probe;
        testdata.units(i).clusterid = testdata.clusters.ks2_ids(i);
        testdata.units(i).location = testdata.clusters.location{i};
        testdata.units(i).hemisphere = testdata.clusters.hemisphere(i);
        testdata.units(i).label = testdata.clusters.ks2_labels(i);
        spiketimes = testdata.spikes.times(find(testdata.spikes.clusters==testdata.units(i).clusterid));
        testdata.units(i).firing_rate_estimate = NaN;
        testdata.units(i).presence = NaN;
        %%%%% GENERATE PSTHS %%%%%
        testdata.units(i).trials.raw = cell(1,N_trials);
        testdata.units(i).trials.idx = cell(1,N_trials);
        for j = trials_include
            id1 = timestamps(j,1)-2;
            id2 = max(timestamps(j,4:5))+3+testdata.psthbinsize;
            stmps = floor([timestamps(j,:)-id1]/testdata.psthbinsize)+1;
            spks = spiketimes-id1;
            spks(find([spks<0]+[spks>(id2-id1)])) = [];
            bin_edges = 0:testdata.psthbinsize:floor((id2-id1)/testdata.psthbinsize)*testdata.psthbinsize;
            if ~isempty(spks)
                data = histcounts(spks,bin_edges)./testdata.psthbinsize;
            else
                data = zeros(1,length(bin_edges)-1);
            end
            testdata.units(i).trials.raw{j} = data;
            testdata.units(i).trials.idx{j} = stmps;
            testdata.units(i).trials.licks{j} = floor([behavior_data.wheel.all_licks{j}-id1]/testdata.psthbinsize)+1;
        end
        idx1 = find(cellfun(@(x,y) sum(x(rmmissing(unique([y(1):y(1)+100,y(2)-50:y(2)+50,y(4):y(4)+200,y(5):y(5)+200])))), testdata.units(i).trials.raw(trials_include), testdata.units(i).trials.idx(trials_include))>0,1,'first'); %%%
        idx2 = find(cellfun(@(x,y) sum(x(rmmissing(unique([y(1):y(1)+100,y(2)-50:y(2)+50,y(4):y(4)+200,y(5):y(5)+200])))), testdata.units(i).trials.raw(trials_include), testdata.units(i).trials.idx(trials_include))>0,1,'last'); %%%
        trials = trials_include(idx1:idx2);
        testdata.units(i).trials.trials_include = trials_include;
        %%%%% CALCULATE INCLUSION CRITERIA %%%%%
        if length(trials) < 100
            FR(i) = NaN;
        else
            s1 = nan(N_trials,1);
            s2 = nan(N_trials,1);
            for j = testdata.units(i).trials.trials_include
                y = testdata.units(i).trials.idx{j};
                idx = rmmissing(unique([y(1):y(1)+100,y(2)-50:y(2)+50,y(4):y(4)+200,y(5):y(5)+200]));
                s1(j) = sum(testdata.units(i).trials.raw{j}(idx))*testdata.psthbinsize;
                s2(j) = length(testdata.units(i).trials.raw{j}(idx))*testdata.psthbinsize;
            end
            FR(i) = nansum(s1)/nansum(s2);        
        end
        testdata.units(i).firing_rate_estimate = FR(i);
        testdata.units(i).presence = length(trials)/length(trials_include);
    end
    testdata.units = testdata.units(find(testdata.clusters.ks2_labels>0));
    FR             = FR(find(testdata.clusters.ks2_labels>0));
    %% check inclusion criteria and generate CV paritions
    
    neurons_include = [];
    neurons_exclude = [];
    for i = 1:length(testdata.units)
        if isnan(FR(i))
            neurons_exclude = [neurons_exclude i];
        elseif FR(i) < 0.01
           neurons_exclude = [neurons_exclude i];
        else
            neurons_include = [neurons_include i];
        end
    end
    testdata.units = testdata.units(neurons_include);
    disp(['Excluded ',num2str(length(neurons_exclude)),' of ',num2str(length(neurons_include)+length(neurons_exclude)),' units (',num2str(length(neurons_exclude)/(length(neurons_include)+length(neurons_exclude))*100,3),'%) on ',testdata.probe])
    out(r) = testdata;
end
%% organize and save processed data

ephys_data = struct;
ephys_data.path = testdata.path;
counter = 0;
for r = 1:length(probe)
    for i = 1:length(out(r).units)
        ephys_data.units(counter+i) = out(r).units(i);
    end
    counter = counter + length(out(r).units);
end
if ~exist(output_dir,'dir')
    mkdir(output_dir)
end
save([output_dir,'\ephys_data.mat'],'ephys_data','-v7.3')
end