function encodingmodel_cluster_varyalpha(sessionpath,neuronid,sessionid,var1)
% encodingmodel_cluster_varyalpha('dop_47/2022-06-05/001',68,0,'QLEARNING')

outputdir_suffix = 'ActionValueStateValue_Qmedian';

mainpath = '/jukebox/witten/Chris/data/ibl_da_neuropixels/Data/Subjects/';
load([mainpath,sessionpath,'/alf/encodingmodels/inputs/neurons/','neuron_',num2str(neuronid,'%03.0f'),'.mat'],'Y');
load([mainpath,sessionpath,'/alf/encodingmodels/inputs/sessions/','session_',num2str(sessionid,'%04.0f'),'.mat'],'X');
output_dir = [mainpath,sessionpath,'/alf/encodingmodels/outputs/',var1,'_',outputdir_suffix,'/neuron_',num2str(neuronid,'%03.0f'),'/'];
load([output_dir,'neuron_',num2str(neuronid,'%03.0f'),'_session_000.mat'],'output');
cvp = Y.kfold_partition;
load([mainpath,sessionpath,'/alf/behavior_data.mat'],'behavior_data');
behavior_trials = behavior_data.analysis.trials_include;
Alexpath = '/jukebox/witten/Alex/Data/Subjects/';

T = readtable([Alexpath,sessionpath,'/alf/QFS_median_variable_alpha.csv']);
alphas = unique(T.alpha);
output_alpha = struct;
for a = 1:length(alphas)
    disp(['Fitting alpha #',num2str(a),': ',num2str(alphas(a))])
    tic
    idx = find(T.alpha==alphas(a));
    
%     mdl = fitlm(T.trial(idx),T.QRreward(idx));
%     QR_total = circshift(mdl.Residuals.Raw,1); X.events.QR_total = QR_total(behavior_trials);
%     mdl = fitlm(T.trial(idx),T.QLreward(idx));
%     QL_total = circshift(mdl.Residuals.Raw,1); X.events.QL_total = QL_total(behavior_trials);

    QR_total = circshift(T.QRreward(idx),1); X.events.QR_total = QR_total(behavior_trials);
    QL_total = circshift(T.QLreward(idx),1); X.events.QL_total = QL_total(behavior_trials);
    mdl = fitlm(T.trial(idx),T.V(idx));
    state_value  = circshift(mdl.Residuals.Raw,1); X.events.state_value = state_value(behavior_trials);
    
    [predictors,kernel_types,Y.velocity] = getpredictors(X,Y.trials_include,Y.events,Y.hemisphere,var1);
    for i = 1:length(kernel_types)
        kernel_types{i}{7} = ~isnan(Y.events{i}(5));
    end
    init = makedesign1(Y,kernel_types);
    output_alpha(a).AllValues_refit = bilinearmodel_reduced(init,predictors,cvp,'AllValues',output.AllValues(end));
    vars = {'remove_ActionValue_AllKernels','remove_StateValue_AllKernels','remove_AllValues_AllKernels'};
    for i = 1:length(vars)
        output_alpha(a).(vars{i}) = bilinearmodel_reduced(init,predictors,cvp,vars{i},output.AllValues(end));
    end
    output_alpha(a).remove_ActionValue_AllKernels.Fstat.AllValues = getFstat(output_alpha(a).AllValues_refit.fit2.stats,output_alpha(a).remove_ActionValue_AllKernels.fit2.stats);
    output_alpha(a).remove_StateValue_AllKernels.Fstat.AllValues = getFstat(output_alpha(a).AllValues_refit.fit2.stats,output_alpha(a).remove_StateValue_AllKernels.fit2.stats);
    output_alpha(a).remove_AllValues_AllKernels.Fstat.AllValues = getFstat(output_alpha(a).AllValues_refit.fit2.stats,output_alpha(a).remove_AllValues_AllKernels.fit2.stats);
    output_alpha(a).remove_ActionValue_AllKernels.Fstat.remove_AllValues_AllKernels = getFstat(output_alpha(a).remove_ActionValue_AllKernels.fit2.stats,output_alpha(a).remove_AllValues_AllKernels.fit2.stats);
    output_alpha(a).remove_StateValue_AllKernels.Fstat.remove_AllValues_AllKernels = getFstat(output_alpha(a).remove_StateValue_AllKernels.fit2.stats,output_alpha(a).remove_AllValues_AllKernels.fit2.stats);
    output_alpha(a).time = toc;
end

T = readtable([Alexpath,sessionpath,'/alf/QFS_median_variable_forget.csv']);
gammas = unique(T.forget);
output_gamma = struct;
for a = 1:length(gammas)
    disp(['Fitting gamma #',num2str(a),': ',num2str(gammas(a))])
    tic
    idx = find(T.forget==gammas(a));
    
%     mdl = fitlm(T.trial(idx),T.QRreward(idx));
%     QR_total = circshift(mdl.Residuals.Raw,1); X.events.QR_total = QR_total(behavior_trials);
%     mdl = fitlm(T.trial(idx),T.QLreward(idx));
%     QL_total = circshift(mdl.Residuals.Raw,1); X.events.QL_total = QL_total(behavior_trials);

    QR_total = circshift(T.QRreward(idx),1); X.events.QR_total = QR_total(behavior_trials);
    QL_total = circshift(T.QLreward(idx),1); X.events.QL_total = QL_total(behavior_trials);
    mdl = fitlm(T.trial(idx),T.V(idx));
    state_value  = circshift(mdl.Residuals.Raw,1); X.events.state_value = state_value(behavior_trials);
    
    [predictors,kernel_types,Y.velocity] = getpredictors(X,Y.trials_include,Y.events,Y.hemisphere,var1);
    for i = 1:length(kernel_types)
        kernel_types{i}{7} = ~isnan(Y.events{i}(5));
    end
    init = makedesign1(Y,kernel_types);
    output_gamma(a).AllValues_refit = bilinearmodel_reduced(init,predictors,cvp,'AllValues',output.AllValues(end));
    vars = {'remove_ActionValue_AllKernels','remove_StateValue_AllKernels','remove_AllValues_AllKernels'};
    for i = 1:length(vars)
        output_gamma(a).(vars{i}) = bilinearmodel_reduced(init,predictors,cvp,vars{i},output.AllValues(end));
    end
    output_gamma(a).remove_ActionValue_AllKernels.Fstat.AllValues = getFstat(output_gamma(a).AllValues_refit.fit2.stats,output_gamma(a).remove_ActionValue_AllKernels.fit2.stats);
    output_gamma(a).remove_StateValue_AllKernels.Fstat.AllValues = getFstat(output_gamma(a).AllValues_refit.fit2.stats,output_gamma(a).remove_StateValue_AllKernels.fit2.stats);
    output_gamma(a).remove_AllValues_AllKernels.Fstat.AllValues = getFstat(output_gamma(a).AllValues_refit.fit2.stats,output_gamma(a).remove_AllValues_AllKernels.fit2.stats);
    output_gamma(a).remove_ActionValue_AllKernels.Fstat.remove_AllValues_AllKernels = getFstat(output_gamma(a).remove_ActionValue_AllKernels.fit2.stats,output_gamma(a).remove_AllValues_AllKernels.fit2.stats);
    output_gamma(a).remove_StateValue_AllKernels.Fstat.remove_AllValues_AllKernels = getFstat(output_gamma(a).remove_StateValue_AllKernels.fit2.stats,output_gamma(a).remove_AllValues_AllKernels.fit2.stats);
    output_gamma(a).time = toc;
end

save([output_dir,'neuron_',num2str(neuronid,'%03.0f'),'_session_',num2str(sessionid,'%03.0f'),'_alpha_gamma_Qlaser.mat'],'output_alpha','alphas','output_gamma','gammas')

end