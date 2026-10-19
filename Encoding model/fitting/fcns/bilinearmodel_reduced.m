function output = bilinearmodel_reduced(init,predictors,cvp,var_reduce,fullfit)

reg.fit2.alpha  = 0;
reg.fit2.lambda = [];
reg.xval        = 1;

firing      = init.Y;
events      = init.events;
n           = init.n;

predictors	= reducepredictors(predictors,var_reduce);
DF.step2    = sum(cellfun(@(x) any(x),[predictors{:}]));
n.predictors = cellfun(@length,predictors);
Y = cellfun(@(x,y) x(rmmissing(unique([y(1):y(1)+100,y(2)-50:y(2)+50,y(4):y(4)+200,y(5):y(5)+200]))),firing,events,'UniformOutput',false);

output = struct;
X2 = cellfun(@(x,y,z,var1,var2) makedesign2(x,y,z,predictors,[],n,[],fullfit,init.kerneltrials,var1,var2),firing,events,num2cell(1:n.trials),init.speed,init.licks,'UniformOutput',false);
output.fit2 = glmnetfit(X2,Y,cvp,reg,true,DF);

output.fit2.stats.y_resd = cellfun(@(x,y) x-y,output.fit2.stats.y_real,output.fit2.stats.y_pred,'UniformOutput',false);
output.fit2.stats.bins_include = cellfun(@(x,y) x(rmmissing(unique([y(1):y(1)+100,y(2)-50:y(2)+50,y(4):y(4)+200,y(5):y(5)+200]))),cellfun(@(x) 1:length(x),firing,'UniformOutput',false),events,'UniformOutput',false);

output.coefficients{1} = output.fit2.betas(1:n.predictors(1));
output.coefficients{2} = output.fit2.betas(n.predictors(1)+1:sum(n.predictors(1:2)));
output.coefficients{3} = output.fit2.betas(sum(n.predictors(1:2))+1:sum(n.predictors(1:3)));
output.coefficients{4} = output.fit2.betas(sum(n.predictors(1:3))+1:sum(n.predictors(1:4)));
output.coefficients{5} = output.fit2.betas(sum(n.predictors(1:4))+1:sum(n.predictors(1:5)));
output.coefficients{6} = output.fit2.betas(sum(n.predictors(1:5))+1:sum(n.predictors(1:6)));
output.coefficients{7} = output.fit2.betas(sum(n.predictors(1:6))+1:sum(n.predictors(1:7)));
output.coefficients{8} = output.fit2.betas(sum(n.predictors(1:7))+1:sum(n.predictors(1:8)));
output.coefficients{9} = output.fit2.betas(sum(n.predictors(1:8))+1:sum(n.predictors(1:9)));
output.coefficients{10} = 1;

end