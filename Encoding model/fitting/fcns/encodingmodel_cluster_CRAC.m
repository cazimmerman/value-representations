function encodingmodel_cluster_CRAC(sessionpath,neuronid,sessionid,var1)
% encodingmodel_cluster_CRAC('dop_47/2022-06-05/001',68,0,'CRAC')

tic
outputdir_suffix = 'SeqAC_noawin_m_avchoice_median_FINAL';

mainpath = '/jukebox/witten/Chris/data/ibl_da_neuropixels/Data/Subjects/';

%%%%%
if sessionid > 0
    load([mainpath,sessionpath,'/alf/encodingmodels/inputs/sessions_SeqAC_noawin_m_avchoice_median/','session_0000.mat'],'X');
    X_real = X; clear X;
end
%%%%%

load([mainpath,sessionpath,'/alf/encodingmodels/inputs/neurons/','neuron_',num2str(neuronid,'%03.0f'),'.mat'],'Y');
load([mainpath,sessionpath,'/alf/encodingmodels/inputs/sessions_SeqAC_noawin_m_avchoice_median/','session_',num2str(sessionid,'%04.0f'),'.mat'],'X');
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
output.AllValues_refit = bilinearmodel_reduced(init,predictors,cvp,'AllValues',output.AllValues(end));

vars = {'remove_Vcs_AllKernels','remove_Vchoice_AllKernels','remove_Vcs_Vchoice_AllKernels','remove_PIchoice_AllKernels','remove_AllValues_AllKernels'};
for i = 1:length(vars)
    output.(vars{i}) = bilinearmodel_reduced(init,predictors,cvp,vars{i},output.AllValues(end));
end
output.remove_Vcs_AllKernels.Fstat.AllValues            = getFstat(output.AllValues_refit.fit2.stats, output.remove_Vcs_AllKernels.fit2.stats);
output.remove_Vchoice_AllKernels.Fstat.AllValues        = getFstat(output.AllValues_refit.fit2.stats, output.remove_Vchoice_AllKernels.fit2.stats);
output.remove_Vcs_Vchoice_AllKernels.Fstat.AllValues	= getFstat(output.AllValues_refit.fit2.stats, output.remove_Vcs_Vchoice_AllKernels.fit2.stats);
output.remove_PIchoice_AllKernels.Fstat.AllValues       = getFstat(output.AllValues_refit.fit2.stats, output.remove_PIchoice_AllKernels.fit2.stats);
output.remove_AllValues_AllKernels.Fstat.AllValues      = getFstat(output.AllValues_refit.fit2.stats, output.remove_AllValues_AllKernels.fit2.stats);

if sessionid > 0
    output.AllValues(end).fit2.stats = rmfield(output.AllValues(end).fit2.stats,'y_real');
    output.AllValues(end).fit2.stats = rmfield(output.AllValues(end).fit2.stats,'y_pred');
    for i = 1:length(vars)
        output.(vars{i}).fit2.stats = rmfield(output.(vars{i}).fit2.stats,'y_real');
        output.(vars{i}).fit2.stats = rmfield(output.(vars{i}).fit2.stats,'y_pred');
        output.(vars{i}).fit2.stats = rmfield(output.(vars{i}).fit2.stats,'y_resd');
        output.(vars{i}).fit2.stats = rmfield(output.(vars{i}).fit2.stats,'bins_include');
    end
end

output.time = toc;

output_dir = [mainpath,sessionpath,'/alf/encodingmodels/outputs/',var1,'_',outputdir_suffix,'/neuron_',num2str(neuronid,'%03.0f'),'/'];
save([output_dir,'neuron_',num2str(neuronid,'%03.0f'),'_session_',num2str(sessionid,'%03.0f'),'.mat'],'output')

end