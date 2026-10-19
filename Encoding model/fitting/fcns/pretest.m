function output = pretest(sessionpath,neuronid,null_sessions)

pretest_suffix = 'pretest';

mainpath = '/jukebox/witten/Chris/data/ibl_da_neuropixels/Data/Subjects/';
load([mainpath,sessionpath,'/alf/encodingmodels/inputs/neurons/','neuron_',num2str(neuronid,'%03.0f'),'.mat'],'Y');
load([mainpath,sessionpath,'/alf/encodingmodels/inputs/sessions/','session_0000.mat'],'X');
cvp = Y.kfold_partition;
[~,kernel_types,~] = getpredictors(X,Y.trials_include,Y.events,Y.hemisphere,'Residuals');
Y.velocity = cell(size(Y.licks));
for i = 1:length(kernel_types)
    kernel_types{i}{7} = ~isnan(Y.events{i}(5));
end

[real,R2] = getFstatR2(Y,cvp,0,kernel_types);

if isnan(real.full)
    output.real = NaN;
    output.null = [];
    output.pvalue.full = 1;
    output.pvalue.gocue = 1;
    output.pvalue.movement = 1;
    output.pvalue.outcome = 1;
    output.pvalue.movement_ID = 1;
    output.pvalue.outcome_ID = 1;
    output.pvalue.CSplus = 1;
    output.R2.full = NaN;
    output.R2.none = NaN;
    output.R2.gocue = NaN;
    output.R2.movement = NaN;
    output.R2.outcome = NaN;
    output.R2.movement_ID = NaN;
    output.R2.outcome_ID = NaN;
    output.R2.CSplus = NaN;
else
    null = struct;
    null_full = NaN(1,null_sessions);
    null_gocue = NaN(1,null_sessions);
    null_movement = NaN(1,null_sessions);
    null_outcome = NaN(1,null_sessions);
    null_movement_ID = NaN(1,null_sessions);
    null_outcome_ID = NaN(1,null_sessions);
    null_CSplus = NaN(1,null_sessions);
    randomseedoffset = length(Y.firing{1});
    parfor i = 1:null_sessions
        rng(randomseedoffset+i,'twister');
        trying = 1;
        while trying
            try
                [t,~]= getFstatR2(Y,cvp,1,kernel_types);
                null_full(i) = t.full;
                null_gocue(i) = t.gocue;
                null_movement(i) = t.movement;
                null_outcome(i) = t.outcome;
                null_movement_ID(i) = t.movement_ID;
                null_outcome_ID(i) = t.outcome_ID;
                null_CSplus(i) = t.CSplus;
                trying = 0;
            catch
                disp(['Encountered an error while fitting null session #',num2str(i)])
            end
        end
    end
    null.full = null_full;
    null.gocue = null_gocue;
    null.movement = null_movement;
    null.outcome = null_outcome;
    null.movement_ID = null_movement_ID;
    null.outcome_ID = null_outcome_ID;
    null.CSplus = null_CSplus;
    output.real = real;
    output.null = null;
    output.pvalue.full = null_distribution_pvalue(real.full,null.full);
    output.pvalue.gocue = null_distribution_pvalue(real.gocue,null.gocue);
    output.pvalue.movement = null_distribution_pvalue(real.movement,null.movement);
    output.pvalue.outcome = null_distribution_pvalue(real.outcome,null.outcome);
    output.pvalue.movement_ID = null_distribution_pvalue(real.movement_ID,null.movement_ID);
    output.pvalue.outcome_ID = null_distribution_pvalue(real.outcome_ID,null.outcome_ID);
    output.pvalue.CSplus = null_distribution_pvalue(real.CSplus,null.CSplus);
    output.R2.full = R2.full;
    output.R2.none = R2.none;
    output.R2.gocue = R2.gocue;
    output.R2.movement = R2.movement;
    output.R2.outcome = R2.outcome;
    output.R2.movement_ID = R2.movement_ID;
    output.R2.outcome_ID = R2.outcome_ID;
    output.R2.CSplus = R2.CSplus;
end

save([mainpath,sessionpath,'/alf/encodingmodels/inputs/neurons/','neuron_',num2str(neuronid,'%03.0f'),'_',pretest_suffix,'.mat'],'output')

end

function [Fstat,R2] = getFstatR2(Y,cvp,null,kernel_types)

reg.fit1.alpha  = 1;
reg.fit1.lambda = [];
reg.fit2.alpha  = 0;
reg.fit2.lambda = [];
reg.xval        = 1;

if null
    Y.firing = getShiftedFiring(Y);
end
init        = makedesign1(Y,kernel_types);
firing      = cellfun(@(x,y) x(rmmissing(unique([y(1):y(1)+100,y(2)-50:y(2)+50,y(4):y(4)+200,y(5):y(5)+200]))),init.Y,init.events,'UniformOutput',false);

% full model
design1 = init.design1;
DF1.step1 = sum(any([design1{:}],2));
full = glmnetfit(design1,firing,cvp,reg,false,DF1);
if ~any(full.betas(1:end-9)) && ~null
    Fstat.full = NaN;
    R2.full = NaN;
    return
end
clear design1 DF1.step1

% remove all kernels
design2 = cellfun(@(x) x.*[zeros(1,460),ones(1,10)]',init.design1,'UniformOutput',false);
DF2.step1 = sum(any([design2{:}],2));
reduced = glmnetfit(design2,firing,cvp,reg,false,DF2);
Fstat.full = (reduced.stats.SSE-full.stats.SSE)/(full.stats.DFR-reduced.stats.DFR)/full.stats.MSE;
R2.full = full.stats.R2;
R2.none = reduced.stats.R2;

% remove go kernel
design2 = cellfun(@(x) x.*[zeros(1,40),ones(1,430)]',init.design1,'UniformOutput',false);
DF2.step1 = sum(any([design2{:}],2));
reduced = glmnetfit(design2,firing,cvp,reg,false,DF2);
Fstat.gocue = (reduced.stats.SSE-full.stats.SSE)/(full.stats.DFR-reduced.stats.DFR)/full.stats.MSE;
R2.gocue = reduced.stats.R2;

% remove movement kernels (both)
design2 = cellfun(@(x) x.*[ones(1,40),zeros(1,80),ones(1,350)]',init.design1,'UniformOutput',false);
DF2.step1 = sum(any([design2{:}],2));
reduced = glmnetfit(design2,firing,cvp,reg,false,DF2);
Fstat.movement = (reduced.stats.SSE-full.stats.SSE)/(full.stats.DFR-reduced.stats.DFR)/full.stats.MSE;
R2.movement = reduced.stats.R2;

% remove outcome kernels (all)
design2    = cellfun(@(x) x.*[ones(1,120),zeros(1,320),ones(1,30)]',init.design1,'UniformOutput',false);
DF2.step1 = sum(any([design2{:}],2));
reduced = glmnetfit(design2,firing,cvp,reg,false,DF2);
Fstat.outcome = (reduced.stats.SSE-full.stats.SSE)/(full.stats.DFR-reduced.stats.DFR)/full.stats.MSE;
R2.outcome = reduced.stats.R2;

% only one movement kernel
design2 = init.design1;
for i = 1:length(design2)
    design2{i}(41:80,:) = design2{i}(41:80,:)+design2{i}(81:120,:);
    design2{i}(81:120,:) = 0*design2{i}(81:120,:);
end
DF2.step1 = sum(any([design2{:}],2));
reduced = glmnetfit(design2,firing,cvp,reg,false,DF2);
Fstat.movement_ID = (reduced.stats.SSE-full.stats.SSE)/(full.stats.DFR-reduced.stats.DFR)/full.stats.MSE;
R2.movement_ID = reduced.stats.R2;

% only one outcome (CS) kernel
design2 = init.design1;
for i = 1:length(design2)
    design2{i}(121:200,:) = design2{i}(121:200,:)+design2{i}(201:280,:)+design2{i}(281:360,:);
    design2{i}(201:440,:) = 0*design2{i}(201:440,:);
end
DF2.step1 = sum(any([design2{:}],2));
reduced = glmnetfit(design2,firing,cvp,reg,false,DF2);
Fstat.outcome_ID = (reduced.stats.SSE-full.stats.SSE)/(full.stats.DFR-reduced.stats.DFR)/full.stats.MSE;
R2.outcome_ID = reduced.stats.R2;

% remove outcome kernels (CS+ only)
design2    = cellfun(@(x) x.*[ones(1,120),zeros(1,160),ones(1,190)]',init.design1,'UniformOutput',false);
DF2.step1 = sum(any([design2{:}],2));
reduced = glmnetfit(design2,firing,cvp,reg,false,DF2);
Fstat.CSplus = (reduced.stats.SSE-full.stats.SSE)/(full.stats.DFR-reduced.stats.DFR)/full.stats.MSE;
R2.CSplus = reduced.stats.R2;

end

function B = getShiftedFiring(Y)

A = [Y.firing{:}];
A = circshift(A,ceil(rand*(numel(A)-1)));
B = cell(size(Y.firing));
for i = 1:length(Y.firing)
    B{i} = A(1:length(Y.firing{i}));
    A(1:length(Y.firing{i})) = [];
end

end