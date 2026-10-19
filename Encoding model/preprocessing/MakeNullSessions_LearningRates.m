function MakeNullSessions_LearningRates(input_paths,n_sessions,n_trials,sfx)

data = cell(size(input_paths));
for i = 1:length(input_paths)
    load(['Z:\Chris\data\ibl_da_neuropixels\',input_paths{i}(9:end),'\behavior_data.mat'],'behavior_data');
    trials = behavior_data.analysis.trials_include;
    Q_alpha = readtable([input_paths{i},'QFS_median_variable_alpha.csv']);
    alphas = unique(Q_alpha.alpha);
    alphas = alphas(34:end);
    for j = 1:length(alphas)
        idx = find(Q_alpha.alpha==alphas(j));
        y = Q_alpha.QL(idx); y = circshift(y,1);
        data{i}.VaryAlpha_QL_total(j,:) = y(trials);
        y = Q_alpha.QLreward(idx); y = circshift(y,1);
        data{i}.VaryAlpha_QL_laser(j,:) = y(trials);
        y = Q_alpha.QLstay(idx); y = circshift(y,1);
        data{i}.VaryAlpha_QL_stay(j,:) = y(trials);
        y = Q_alpha.QR(idx); y = circshift(y,1);
        data{i}.VaryAlpha_QR_total(j,:) = y(trials);
        y = Q_alpha.QRreward(idx); y = circshift(y,1);
        data{i}.VaryAlpha_QR_laser(j,:) = y(trials);
        y = Q_alpha.QRstay(idx); y = circshift(y,1);
        data{i}.VaryAlpha_QR_stay(j,:) = y(trials);
        y = Q_alpha.V(idx); y = circshift(y,1);
        data{i}.VaryAlpha_state_value(j,:) = y(trials);
    end
    data{i}.VaryAlpha_alphas = alphas;
    Q_gamma = readtable([input_paths{i},'QFS_median_variable_forget.csv']);
    gammas = unique(Q_gamma.forget);
    gammas = gammas(34:end);
    for j = 1:length(gammas)
        idx = find(Q_gamma.forget==gammas(j));
        y = Q_gamma.QL(idx); y = circshift(y,1);
        data{i}.VaryGamma_QL_total(j,:) = y(trials);
        y = Q_gamma.QLreward(idx); y = circshift(y,1);
        data{i}.VaryGamma_QL_laser(j,:) = y(trials);
        y = Q_gamma.QLstay(idx); y = circshift(y,1);
        data{i}.VaryGamma_QL_stay(j,:) = y(trials);
        y = Q_gamma.QR(idx); y = circshift(y,1);
        data{i}.VaryGamma_QR_total(j,:) = y(trials);
        y = Q_gamma.QRreward(idx); y = circshift(y,1);
        data{i}.VaryGamma_QR_laser(j,:) = y(trials);
        y = Q_gamma.QRstay(idx); y = circshift(y,1);
        data{i}.VaryGamma_QR_stay(j,:) = y(trials);
        y = Q_gamma.V(idx); y = circshift(y,1);
        data{i}.VaryGamma_state_value(j,:) = y(trials);
    end
    data{i}.VaryGamma_gammas = gammas;
end

output_dir = ['Z:\Chris\data\ibl_da_neuropixels\Data\null_sessions',sfx,'\'];
if exist(output_dir,'dir')
    rmdir(output_dir,'s')
end
mkdir(output_dir)

fnames = fieldnames(data{1});
rng(length(input_paths),'twister');
for i = 1:n_sessions
    LearningRates_data = []; LearningRates_data.VaryAlpha = struct; LearningRates_data.VaryGamma = struct;
    x = data(randperm(numel(data)));
    x = [x{:}];
    y = extractfield(x,fnames{1});
    y = reshape(y,[40 length(y)/40]);
    s = randi([1 size(y,2)]);
    for j = 1:7
        y = extractfield(x,fnames{j});
        y = reshape(y,[40 length(y)/40]);
        for k = 1:40
            y1 = circshift(y(k,:),s);
            LearningRates_data.VaryAlpha.(fnames{j}(11:end))(k,:) = y1(1:n_trials);
        end
    end
    LearningRates_data.VaryAlpha.alphas = data{1}.VaryAlpha_alphas;
    for j = 9:15
        y = extractfield(x,fnames{j});
        y = reshape(y,[40 length(y)/40]);
        for k = 1:40
            y1 = circshift(y(k,:),s);
            LearningRates_data.VaryGamma.(fnames{j}(11:end))(k,:) = y1(1:n_trials);
        end
    end
    LearningRates_data.VaryGamma.gammas = data{1}.VaryGamma_gammas;
    save([output_dir,num2str(i,'%04.0f'),'.mat'],'LearningRates_data')
end