function encodingmodel_cluster(sessionpath,neuronid,sessionid,var1)
% encodingmodel_cluster('dop_47/2022-06-05/001',86,0,'QLEARNING')

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

[predictors,kernel_types,Y.velocity] = getpredictors(X,Y.trials_include,Y.events,Y.hemisphere,var1);
for i = 1:length(kernel_types)
    kernel_types{i}{7} = ~isnan(Y.events{i}(5));
end
init = makedesign1(Y,kernel_types);

output.AllValues = bilinearmodel(init,predictors,cvp,'AllValues');
if sessionid > 0
    output.AllValues(end).fit2.stats = rmfield(output.AllValues(end).fit2.stats,'y_real');
    output.AllValues(end).fit2.stats = rmfield(output.AllValues(end).fit2.stats,'y_pred');
end

output.AllValues_refit = bilinearmodel_reduced(init,predictors,cvp,'AllValues',output.AllValues(end));

vars = {'remove_ActionValue_AllKernels','remove_StateValue_AllKernels','remove_AllValues_AllKernels'};
for i = 1:length(vars)
    output.(vars{i}) = bilinearmodel_reduced(init,predictors,cvp,vars{i},output.AllValues(end));
end
output.remove_ActionValue_AllKernels.Fstat.AllValues = getFstat(output.AllValues_refit.fit2.stats,output.remove_ActionValue_AllKernels.fit2.stats);
output.remove_StateValue_AllKernels.Fstat.AllValues = getFstat(output.AllValues_refit.fit2.stats,output.remove_StateValue_AllKernels.fit2.stats);
output.remove_AllValues_AllKernels.Fstat.AllValues = getFstat(output.AllValues_refit.fit2.stats,output.remove_AllValues_AllKernels.fit2.stats);
output.remove_ActionValue_AllKernels.Fstat.remove_AllValues_AllKernels = getFstat(output.remove_ActionValue_AllKernels.fit2.stats,output.remove_AllValues_AllKernels.fit2.stats);
output.remove_StateValue_AllKernels.Fstat.remove_AllValues_AllKernels = getFstat(output.remove_StateValue_AllKernels.fit2.stats,output.remove_AllValues_AllKernels.fit2.stats);

vars = {'remove_ActionValue_CueKernel','remove_StateValue_CueKernel','remove_AllValues_CueKernel'};
for i = 1:length(vars)
    output.(vars{i}) = bilinearmodel_reduced(init,predictors,cvp,vars{i},output.AllValues(end));
end
output.remove_ActionValue_CueKernel.Fstat.AllValues = getFstat(output.AllValues_refit.fit2.stats,output.remove_ActionValue_CueKernel.fit2.stats);
output.remove_StateValue_CueKernel.Fstat.AllValues = getFstat(output.AllValues_refit.fit2.stats,output.remove_StateValue_CueKernel.fit2.stats);
output.remove_AllValues_CueKernel.Fstat.AllValues = getFstat(output.AllValues_refit.fit2.stats,output.remove_AllValues_CueKernel.fit2.stats);

vars = {'remove_ActionValue_MovementKernels','remove_StateValue_MovementKernels','remove_AllValues_MovementKernels'};
for i = 1:length(vars)
    output.(vars{i}) = bilinearmodel_reduced(init,predictors,cvp,vars{i},output.AllValues(end));
end
output.remove_ActionValue_MovementKernels.Fstat.AllValues = getFstat(output.AllValues_refit.fit2.stats,output.remove_ActionValue_MovementKernels.fit2.stats);
output.remove_StateValue_MovementKernels.Fstat.AllValues = getFstat(output.AllValues_refit.fit2.stats,output.remove_StateValue_MovementKernels.fit2.stats);
output.remove_AllValues_MovementKernels.Fstat.AllValues = getFstat(output.AllValues_refit.fit2.stats,output.remove_AllValues_MovementKernels.fit2.stats);

vars = {'remove_ActionValue_OutcomeKernels','remove_StateValue_OutcomeKernels','remove_AllValues_OutcomeKernels'};
for i = 1:length(vars)
    output.(vars{i}) = bilinearmodel_reduced(init,predictors,cvp,vars{i},output.AllValues(end));
end
output.remove_ActionValue_OutcomeKernels.Fstat.AllValues = getFstat(output.AllValues_refit.fit2.stats,output.remove_ActionValue_OutcomeKernels.fit2.stats);
output.remove_StateValue_OutcomeKernels.Fstat.AllValues = getFstat(output.AllValues_refit.fit2.stats,output.remove_StateValue_OutcomeKernels.fit2.stats);
output.remove_AllValues_OutcomeKernels.Fstat.AllValues = getFstat(output.AllValues_refit.fit2.stats,output.remove_AllValues_OutcomeKernels.fit2.stats);

output.time = toc;

output_dir = [mainpath,sessionpath,'/alf/encodingmodels/outputs/',var1,'_',outputdir_suffix,'/neuron_',num2str(neuronid,'%03.0f'),'/'];
save([output_dir,'neuron_',num2str(neuronid,'%03.0f'),'_session_',num2str(sessionid,'%03.0f'),'.mat'],'output')

end