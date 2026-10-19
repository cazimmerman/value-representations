function makeresiduals(sessionpath,neuronid)

% makeresiduals('dop_47/2022-06-05/001',1)

addpath(genpath('/jukebox/witten/Chris/matlab/raisedCosineBasis/'));
addpath(genpath('/jukebox/witten/Chris/matlab/glmnet-stanford-old/'))
addpath(genpath('/jukebox/witten/Chris/matlab/cz/ibl_da_neuropixels_2022/utils/'))

mainpath = '/jukebox/witten/Chris/data/ibl_da_neuropixels/Data/Subjects/';
load([mainpath,sessionpath,'/alf/encodingmodels/inputs/neurons/','neuron_',num2str(neuronid,'%03.0f'),'.mat'],'Y');
load([mainpath,sessionpath,'/alf/encodingmodels/inputs/sessions/','session_0000.mat'],'X');
load([mainpath,sessionpath,'/alf/behavior_data.mat'],'behavior_data');

[~,kernel_types,~] = getpredictors(X,Y.trials_include,Y.events,Y.hemisphere,'Residuals');
for i = 1:length(kernel_types)
    kernel_types{i}{7} = ~isnan(Y.events{i}(5));
end
Y.metadata.hem = Y.hemisphere;

init = makedesign1_residuals(Y,kernel_types,1);

y               = cellfun(@(x,y) x(rmmissing(unique([y(1):y(1)+100,y(2)-50:y(2)+50,y(4):y(4)+200,y(5):y(5)+200]))),init.Y,init.events,'UniformOutput',false);
x               = init.design1;
opts            = struct;
opts.alpha      = 1;
opts.nlambda    = [];
opts.lambda     = fliplr(logspace(-5,5,251));
opts.intr       = true;
opts            = glmnetSet(opts);
full_X          = sparse([x{:}]');
full_Y          = sparse([y{:}]');
mdl             = glmnet(full_X,full_Y,'gaussian',opts);

opts.lambda     = mdl.lambda;
cvp             = Y.kfold_partition;
DF.step1        = size([x{:}],1);
lambdas         = getlambda(x,y,[],opts,cvp,DF,0);
lambda_eval     = lambdas.lambda_min;

Y_real          = init.Y;
init            = makedesign1_residuals(Y,kernel_types,0);
X_pred          = init.design1;
Y_pred          = cell(size(Y_real));
Y_resd          = cell(size(Y_real));
for i = 1:length(Y_pred)
    Y_pred{i} = glmnetPredict(mdl,sparse(X_pred{i}'),lambda_eval,'response',false,[])';
    Y_resd{i} = Y_real{i} - Y_pred{i};
end

data            = struct;
data.cluster    = Y.metadata;
data.Y_real     = Y_real;
data.Y_pred     = Y_pred;
data.Y_resd     = Y_resd;
data.trials     = behavior_data.analysis.trials_include(Y.trials_include)';
data.times      = cellfun(@(x) x([1,2,4,5]),Y.events,'UniformOutput',false);
data.model      = mdl;
data.lambda     = lambda_eval;

save([mainpath,sessionpath,'/alf/encodingmodels/inputs/neurons/','neuron_',num2str(neuronid,'%03.0f'),'_residuals.mat'],'data','-v7.3')

end