function encodingmodel_cluster_varyalpha_pseudosessions(sessionpath,neuronid,sessionid,var1)
% encodingmodel_cluster_varyalpha_pseudosessions('dop_47/2022-06-05/001',68,2,'QLEARNING')

outputdir_suffix = 'ActionValueStateValue_Qmedian';

mainpath = '/jukebox/witten/Chris/data/ibl_da_neuropixels/Data/Subjects/';
output_dir = [mainpath,sessionpath,'/alf/encodingmodels/outputs/',var1,'_',outputdir_suffix,'/neuron_',num2str(neuronid,'%03.0f'),'/'];
load([output_dir,'neuron_',num2str(neuronid,'%03.0f'),'_session_',num2str(sessionid,'%03.0f'),'.mat'],'output');
load([mainpath,sessionpath,'/alf/behavior_data.mat'],'behavior_data');
behavior_trials = 1:length(behavior_data.analysis.trials_include);

load(['/jukebox/witten/Chris/data/ibl_da_neuropixels/Data/null_sessions_LearningRates/',num2str(sessionid,'%04.f'),'.mat'],'LearningRates_data');

%%%%%
if sessionid > 0
    load([mainpath,sessionpath,'/alf/encodingmodels/inputs/sessions/','session_0000.mat'],'X');
    X_real = X; clear X;
end
%%%%%

load([mainpath,sessionpath,'/alf/encodingmodels/inputs/neurons/','neuron_',num2str(neuronid,'%03.0f'),'.mat'],'Y');
load([mainpath,sessionpath,'/alf/encodingmodels/inputs/sessions/','session_',num2str(sessionid,'%04.0f'),'.mat'],'X');
cvp = Y.kfold_partition;

%%%%%
if sessionid > 0
    X.events.choice   = X_real.events.choice';
    X.events.laser    = X_real.events.laser';
    X.events.feedback = X_real.events.feedback';
    X.wheel           = X_real.wheel;
end
%%%%%

alphas = LearningRates_data.VaryAlpha.alphas;
output_alpha = struct;
for a = 1:length(alphas)
    
%     mdl = fitlm(behavior_trials,LearningRates_data.VaryAlpha.QR_laser(a,behavior_trials)); X.events.QR_total = mdl.Residuals.Raw;
%     mdl = fitlm(behavior_trials,LearningRates_data.VaryAlpha.QL_laser(a,behavior_trials)); X.events.QL_total = mdl.Residuals.Raw;
    X.events.QR_total = LearningRates_data.VaryAlpha.QR_laser(a,behavior_trials);
    X.events.QL_total = LearningRates_data.VaryAlpha.QL_laser(a,behavior_trials);
    mdl = fitlm(behavior_trials,LearningRates_data.VaryAlpha.state_value(a,behavior_trials)); X.events.state_value = mdl.Residuals.Raw';

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
end

gammas = LearningRates_data.VaryGamma.gammas;
output_gamma = struct;
for a = 1:length(gammas)
    
%     mdl = fitlm(behavior_trials,LearningRates_data.VaryGamma.QR_laser(a,behavior_trials)); X.events.QR_total = mdl.Residuals.Raw;
%     mdl = fitlm(behavior_trials,LearningRates_data.VaryGamma.QL_laser(a,behavior_trials)); X.events.QL_total = mdl.Residuals.Raw;
    X.events.QR_total = LearningRates_data.VaryGamma.QR_laser(a,behavior_trials);
    X.events.QL_total = LearningRates_data.VaryGamma.QL_laser(a,behavior_trials);
    mdl = fitlm(behavior_trials,LearningRates_data.VaryGamma.state_value(a,behavior_trials)); X.events.state_value = mdl.Residuals.Raw;

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
end

save([output_dir,'neuron_',num2str(neuronid,'%03.0f'),'_session_',num2str(sessionid,'%03.0f'),'_alpha_gamma_Qlaser.mat'],'output_alpha','alphas','output_gamma','gammas')

end