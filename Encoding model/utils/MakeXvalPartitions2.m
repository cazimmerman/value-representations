function partition = MakeXvalPartitions2(trials_include,number_folds,events)

rng(length(trials_include),'twister')

categories = [events.blocks_reward events.blocks_side events.choice events.feedback];
categories = categories(trials_include,:);
N_trials = length(trials_include);
N_categories = unique(categories,'rows','first');
for j = 1:N_trials
    for k = 1:length(N_categories)
        if isequal(N_categories(k,:),categories(j,:))
            trial_type(j) = k;
        end
    end
end

warning('off','all')
P = cvpartition(trial_type,'KFold',number_folds);
warning('on','all')

for p = 1:P.NumTestSets
    partition.test{p} = find(P.test(p));
    partition.train{p} = find(P.training(p));
end

end