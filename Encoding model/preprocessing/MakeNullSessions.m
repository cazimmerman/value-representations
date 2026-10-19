function MakeNullSessions(input_paths,n_sessions,n_trials,sfx)

data = cell(size(input_paths));
trials_include = nan(size(input_paths));
for i = 1:length(input_paths)
    load(['Z:\Chris\data\ibl_da_neuropixels\',input_paths{i}(9:end),'\behavior_data.mat'],'behavior_data');
    events = behavior_data.events; fnames.events = fieldnames(events);
    wheel = behavior_data.wheel; fnames.wheel = fieldnames(wheel);
    trials = behavior_data.analysis.trials_include;
    for j = 1:length(fnames.events)
        data{i}.(fnames.events{j}) = events.(fnames.events{j})(trials);
    end
    for j = 1:length(fnames.wheel)
        data{i}.(fnames.wheel{j}) = wheel.(fnames.wheel{j})(trials);
    end
    trials_include(i) = length(trials);
end

output_dir = ['Z:\Chris\data\ibl_da_neuropixels\Data\null_sessions',sfx,'\'];
if exist(output_dir,'dir')
    rmdir(output_dir,'s')
end
mkdir(output_dir)

rng(length(input_paths),'twister');
for i = 1:n_sessions
    behavior_data = []; behavior_data.events = struct; behavior_data.wheel = struct;
    x = data(randperm(numel(data)));
    for k = 2:length(x)
        x{k}.CRAC_Vcs = x{k}.CRAC_Vcs + (x{k-1}.CRAC_Vcs(end)-x{k}.CRAC_Vcs(1));
        x{k}.CRAC_Vchoice = x{k}.CRAC_Vchoice + (x{k-1}.CRAC_Vchoice(end)-x{k}.CRAC_Vchoice(1));
    end
    x = [x{:}];
    s = randi([1 length(extractfield(x,fnames.events{1}))]);
    for j = 1:length(fnames.events)
        y = extractfield(x,fnames.events{j});
        y = circshift(y,s);
        behavior_data.events.(fnames.events{j}) = y(1:n_trials);
    end
    for j = 1:length(fnames.wheel)
        y = extractfield(x,fnames.wheel{j});
        y = circshift([y{:}],s);
        behavior_data.wheel.(fnames.wheel{j}) = y(1:n_trials);
    end
    save([output_dir,num2str(i,'%04.0f'),'.mat'],'behavior_data')
end