function output = bilinearmodel(init,predictors,cvp,var_reduce)

reg.fit1.alpha  = 1;
reg.fit1.lambda = [];
reg.fit2.alpha  = 0;
reg.fit2.lambda = [];
reg.xval        = 0;

firing      = init.Y;
events      = init.events;
cosBasis    = init.cosBasis;
n           = init.n;
design1     = init.design1;

predictors	= reducepredictors(predictors,var_reduce);
DF.step1    = size([design1{:}],1);
DF.step2    = sum(cellfun(@(x) any(x),[predictors{:}]));
n.predictors = cellfun(@length,predictors);
Y = cellfun(@(x,y) x(rmmissing(unique([y(1):y(1)+100,y(2)-50:y(2)+50,y(4):y(4)+200,y(5):y(5)+200]))),firing,events,'UniformOutput',false);
n.dimX = n.basis.*n.kernel_types;

output = struct; gains  = [];
iterating = 1; currentit = 1; lastit = 0; cvgthresh = 1E-3; cvgit = 3; maxit = 100;
while iterating

    X1 = updatedesign1(design1,predictors,n.dimX,gains);
    
    if currentit == 1
        output(currentit).fit1 = glmnetfit(X1,Y,cvp,reg,false,DF);
        reg.fit1.lambda = output(currentit).fit1.lambda;
    else
        output(currentit).fit1 = glmnetfit(X1,Y,[],reg,false,[]);
    end
    
    for i = 1:n.kernels
        for j = 1:n.kernel_types(i)
            output(currentit).kernels{i}{j} = cosBasis{i}*output(currentit).fit1.betas(sum(n.dimX(1:i-1))+n.basis(i)*(j-1)+1:sum(n.dimX(1:i-1))+n.basis(i)*j)';
        end
        if i < n.kernels
            L2norm = cellfun(@norm,output(currentit).kernels{i});
            if L2norm == 0
                for j = 1:n.kernel_types(i)
                    output(currentit).kernels{i}{j} = zeros(size(output(currentit).kernels{i}{j}));
                end
            else
                for j = 1:n.kernel_types(i)
                    output(currentit).kernels{i}{j} = output(currentit).kernels{i}{j}./L2norm;
                end
            end
        end
    end
    output(currentit).baseline = output(currentit).fit1.intercept;
    
    X2 = cellfun(@(x,y,z,var1,var2) makedesign2(x,y,z,predictors,[],n,[],output(currentit),init.kerneltrials,var1,var2),firing,events,num2cell(1:n.trials),init.speed,init.licks,'UniformOutput',false);

    if currentit == 1
        output(currentit).fit2 = glmnetfit(X2,Y,cvp,reg,true,DF);
        reg.fit2.lambda = output(currentit).fit2.lambda;
    else
        output(currentit).fit2 = glmnetfit(X2,Y,[],reg,true,[]);
    end

    output(currentit).coefficients{1} = output(currentit).fit2.betas(1:n.predictors(1));
    output(currentit).coefficients{2} = output(currentit).fit2.betas(n.predictors(1)+1:sum(n.predictors(1:2)));
    output(currentit).coefficients{3} = output(currentit).fit2.betas(sum(n.predictors(1:2))+1:sum(n.predictors(1:3)));
    output(currentit).coefficients{4} = output(currentit).fit2.betas(sum(n.predictors(1:3))+1:sum(n.predictors(1:4)));
    output(currentit).coefficients{5} = output(currentit).fit2.betas(sum(n.predictors(1:4))+1:sum(n.predictors(1:5)));
    output(currentit).coefficients{6} = output(currentit).fit2.betas(sum(n.predictors(1:5))+1:sum(n.predictors(1:6)));
    output(currentit).coefficients{7} = output(currentit).fit2.betas(sum(n.predictors(1:6))+1:sum(n.predictors(1:7)));
    output(currentit).coefficients{8} = output(currentit).fit2.betas(sum(n.predictors(1:7))+1:sum(n.predictors(1:8)));
    output(currentit).coefficients{9} = output(currentit).fit2.betas(sum(n.predictors(1:8))+1:sum(n.predictors(1:9)));
    output(currentit).coefficients{10} = 1;
    gains = output(currentit).coefficients;
    
    if currentit > 1
        output(currentit).convergence = [max(abs(output(currentit).fit1.betas-output(currentit-1).fit1.betas)) max(abs(output(currentit).fit2.betas-output(currentit-1).fit2.betas))];
        if currentit>=cvgit+1 && max([output(end-cvgit+1:end).convergence])<=cvgthresh
            lastit = 1;
        elseif currentit == maxit
            lastit = 1;
        else
            lastit = 0;
        end
    else
        output(currentit).convergence = [NaN NaN];
    end
    
    if lastit
        reg.xval = 1;
        output(currentit).fit2 = glmnetfit(X2,Y,cvp,reg,true,DF);
        iterating = 0;
        
        Ypred = cellfun(@(x) x*NaN,firing,'UniformOutput',false);
        Yidx = cellfun(@(y) rmmissing(unique([y(1):y(1)+100,y(2)-50:y(2)+50,y(4):y(4)+200,y(5):y(5)+200])),events,'UniformOutput',false);
        for j = 1:length(Ypred)
            Ypred{j}(Yidx{j}) = output(currentit).fit2.stats.y_pred{j};
        end
        output(currentit).fit2.stats.y_real = firing;
        output(currentit).fit2.stats.y_pred = Ypred;
        output(currentit).fit2.stats.y_resd = cellfun(@(x,y) x-y,output(currentit).fit2.stats.y_real,output(currentit).fit2.stats.y_pred,'UniformOutput',false);
    else
        currentit = currentit + 1;
    end
end

end