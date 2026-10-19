function encodingmodel_cluster_state_value(sessionpath,neuronid,sessionid,var1)

% encodingmodel_cluster_state_value('dop_47/2022-06-05/001',1,0,'QLEARNING')

tic
outputdir_suffix = 'ActionValueStateValue_Qmedian';

mainpath = '/jukebox/witten/Chris/data/ibl_da_neuropixels/Data/Subjects/';

%%%%%
if sessionid > 0
    load([mainpath,sessionpath,'/alf/encodingmodels/inputs/sessions/','session_0000.mat'],'X');
    X_real = X; clear X;
end
%%%%%

load([mainpath,sessionpath,'/alf/encodingmodels/inputs/neurons/','neuron_',num2str(neuronid,'%03.0f'),'.mat'],'Y');
load([mainpath,sessionpath,'/alf/encodingmodels/inputs/sessions_Revision/','session_',num2str(sessionid,'%04.0f'),'.mat'],'X');
cvp = Y.kfold_partition;

output_dir = [mainpath,sessionpath,'/alf/encodingmodels/outputs/',var1,'_',outputdir_suffix,'/neuron_',num2str(neuronid,'%03.0f'),'/'];
load([output_dir,'neuron_',num2str(neuronid,'%03.0f'),'_session_',num2str(sessionid,'%03.0f'),'.mat'],'output');
OriginalModel = output; clear output; output = struct;

%%%%%
if sessionid > 0
    X.events.choice   = X_real.events.choice';
    X.events.laser    = X_real.events.laser';
    X.events.feedback = X_real.events.feedback';
    X.wheel           = X_real.wheel;
end
%%%%%

X.events.state_value = X.events.state_value;
[predictors,kernel_types,Y.velocity] = getpredictors(X,Y.trials_include,Y.events,Y.hemisphere,var1);
for i = 1:length(kernel_types)
    kernel_types{i}{7} = ~isnan(Y.events{i}(5));
end
init = makedesign1(Y,kernel_types);
output.state_value.AllValues_refit = bilinearmodel_reduced(init,predictors,cvp,'AllValues',OriginalModel.AllValues(end));
vars = {'remove_ActionValue_AllKernels','remove_StateValue_AllKernels','remove_AllValues_AllKernels'};
for i = 1:length(vars)
    output.state_value.(vars{i}) = bilinearmodel_reduced(init,predictors,cvp,vars{i},OriginalModel.AllValues(end));
end
output.state_value.remove_ActionValue_AllKernels.Fstat.AllValues = getFstat(output.state_value.AllValues_refit.fit2.stats,output.state_value.remove_ActionValue_AllKernels.fit2.stats);
output.state_value.remove_StateValue_AllKernels.Fstat.AllValues = getFstat(output.state_value.AllValues_refit.fit2.stats,output.state_value.remove_StateValue_AllKernels.fit2.stats);
output.state_value.remove_AllValues_AllKernels.Fstat.AllValues = getFstat(output.state_value.AllValues_refit.fit2.stats,output.state_value.remove_AllValues_AllKernels.fit2.stats);
output.state_value.remove_ActionValue_AllKernels.Fstat.remove_AllValues_AllKernels = getFstat(output.state_value.remove_ActionValue_AllKernels.fit2.stats,output.state_value.remove_AllValues_AllKernels.fit2.stats);
output.state_value.remove_StateValue_AllKernels.Fstat.remove_AllValues_AllKernels = getFstat(output.state_value.remove_StateValue_AllKernels.fit2.stats,output.state_value.remove_AllValues_AllKernels.fit2.stats);
output.state_value.time = toc;
clear predictors

X.events.state_value = X.events.Q_total;
[predictors,kernel_types,Y.velocity] = getpredictors(X,Y.trials_include,Y.events,Y.hemisphere,var1);
for i = 1:length(kernel_types)
    kernel_types{i}{7} = ~isnan(Y.events{i}(5));
end
init = makedesign1(Y,kernel_types);
output.Q_total.AllValues_refit = bilinearmodel_reduced(init,predictors,cvp,'AllValues',OriginalModel.AllValues(end));
vars = {'remove_ActionValue_AllKernels','remove_StateValue_AllKernels','remove_AllValues_AllKernels'};
for i = 1:length(vars)
    output.Q_total.(vars{i}) = bilinearmodel_reduced(init,predictors,cvp,vars{i},OriginalModel.AllValues(end));
end
output.Q_total.remove_ActionValue_AllKernels.Fstat.AllValues = getFstat(output.Q_total.AllValues_refit.fit2.stats,output.Q_total.remove_ActionValue_AllKernels.fit2.stats);
output.Q_total.remove_StateValue_AllKernels.Fstat.AllValues = getFstat(output.Q_total.AllValues_refit.fit2.stats,output.Q_total.remove_StateValue_AllKernels.fit2.stats);
output.Q_total.remove_AllValues_AllKernels.Fstat.AllValues = getFstat(output.Q_total.AllValues_refit.fit2.stats,output.Q_total.remove_AllValues_AllKernels.fit2.stats);
output.Q_total.remove_ActionValue_AllKernels.Fstat.remove_AllValues_AllKernels = getFstat(output.Q_total.remove_ActionValue_AllKernels.fit2.stats,output.Q_total.remove_AllValues_AllKernels.fit2.stats);
output.Q_total.remove_StateValue_AllKernels.Fstat.remove_AllValues_AllKernels = getFstat(output.Q_total.remove_StateValue_AllKernels.fit2.stats,output.Q_total.remove_AllValues_AllKernels.fit2.stats);
output.Q_total.time = toc;
clear predictors

X.events.state_value = X.events.Q_total_weighted;
[predictors,kernel_types,Y.velocity] = getpredictors(X,Y.trials_include,Y.events,Y.hemisphere,var1);
for i = 1:length(kernel_types)
    kernel_types{i}{7} = ~isnan(Y.events{i}(5));
end
init = makedesign1(Y,kernel_types);
output.Q_total_weighted.AllValues_refit = bilinearmodel_reduced(init,predictors,cvp,'AllValues',OriginalModel.AllValues(end));
vars = {'remove_ActionValue_AllKernels','remove_StateValue_AllKernels','remove_AllValues_AllKernels'};
for i = 1:length(vars)
    output.Q_total_weighted.(vars{i}) = bilinearmodel_reduced(init,predictors,cvp,vars{i},OriginalModel.AllValues(end));
end
output.Q_total_weighted.remove_ActionValue_AllKernels.Fstat.AllValues = getFstat(output.Q_total_weighted.AllValues_refit.fit2.stats,output.Q_total_weighted.remove_ActionValue_AllKernels.fit2.stats);
output.Q_total_weighted.remove_StateValue_AllKernels.Fstat.AllValues = getFstat(output.Q_total_weighted.AllValues_refit.fit2.stats,output.Q_total_weighted.remove_StateValue_AllKernels.fit2.stats);
output.Q_total_weighted.remove_AllValues_AllKernels.Fstat.AllValues = getFstat(output.Q_total_weighted.AllValues_refit.fit2.stats,output.Q_total_weighted.remove_AllValues_AllKernels.fit2.stats);
output.Q_total_weighted.remove_ActionValue_AllKernels.Fstat.remove_AllValues_AllKernels = getFstat(output.Q_total_weighted.remove_ActionValue_AllKernels.fit2.stats,output.Q_total_weighted.remove_AllValues_AllKernels.fit2.stats);
output.Q_total_weighted.remove_StateValue_AllKernels.Fstat.remove_AllValues_AllKernels = getFstat(output.Q_total_weighted.remove_StateValue_AllKernels.fit2.stats,output.Q_total_weighted.remove_AllValues_AllKernels.fit2.stats);
output.Q_total_weighted.time = toc;

output_dir = [mainpath,sessionpath,'/alf/encodingmodels/outputs/',var1,'_',outputdir_suffix,'/neuron_',num2str(neuronid,'%03.0f'),'/'];
save([output_dir,'neuron_',num2str(neuronid,'%03.0f'),'_session_',num2str(sessionid,'%03.0f'),'_REVISIONS_state_value.mat'],'output')

end