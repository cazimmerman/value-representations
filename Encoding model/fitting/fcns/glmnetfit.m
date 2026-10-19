function output = glmnetfit(x,y,cvp,reg,offset,DF)

opts = struct;
opts.nlambda = [];
opts.lambda = fliplr(logspace(-5,5,251));
if offset
    o = cellfun(@(x) x(end,:),x,'UniformOutput',false);
    x = cellfun(@(x) x(1:end-1,:),x,'UniformOutput',false);
    opts.alpha = reg.fit2.alpha;
    opts.offset = sparse([o{:}]');
    opts.intr = false;
    lambda_eval = reg.fit2.lambda;
else
    o = [];
    opts.alpha = reg.fit1.alpha;
    opts.intr = true;
    lambda_eval = reg.fit1.lambda;
end
opts            = glmnetSet(opts);
full_X          = sparse([x{:}]');
full_Y          = sparse([y{:}]');
mdl1            = glmnet(full_X,full_Y,'gaussian',opts);

if isempty(lambda_eval)
    opts.nlambda = [];
    opts.lambda = mdl1.lambda;
    lambdas = getlambda(x,y,o,opts,cvp,DF,offset);
    lambda_eval = lambdas.lambda_min;
end

output.method   = @glmnet;
coef            = glmnetCoef(mdl1,lambda_eval,false);
output.intercept= coef(1)';
output.betas    = coef(2:end)';
output.lambda   = lambda_eval;
output.alpha    = opts.alpha;

if reg.xval
    opts.nlambda    = [];
    opts.lambda     = mdl1.lambda;
    nFolds = length(cvp.test);
    y_cv = nan(size(full_Y,1),1);
    y_pred = cell(size(y));
    for k = 1:nFolds
        train_idx = cvp.train{k};
        test_idx  = cvp.test{k};
        train_Y = sparse([y{train_idx}]');
        train_X = sparse([x{train_idx}]');
        if offset
            opts.offset = sparse([o{train_idx}]');
        end
        mdl = glmnet(train_X,train_Y,'gaussian',opts);
        for j = 1:length(test_idx)
            idx1 = sum(cellfun(@length, y(1:(test_idx(j)-1))))+1;
            idx2 = sum(cellfun(@length, y(1:(test_idx(j)))));
            if offset
                y_cv(idx1:idx2) = glmnetPredict(mdl,sparse(x{test_idx(j)}'),lambda_eval,'response',false,sparse([o{test_idx(j)}]'));
                y_pred{test_idx(j)} = glmnetPredict(mdl,sparse(x{test_idx(j)}'),lambda_eval,'response',false,sparse([o{test_idx(j)}]'))';
            else
                y_cv(idx1:idx2) = glmnetPredict(mdl,sparse(x{test_idx(j)}'),lambda_eval,'response',false,[]);
                y_pred{test_idx(j)} = glmnetPredict(mdl,sparse(x{test_idx(j)}'),lambda_eval,'response',false,[])';
            end
        end
    end
    y_real = [y{:}]';
    n = size([x{:}]',1);
    if offset
        p = DF.step2 - 1;
    else
        p = DF.step1 + 1;
    end
    stats = getcrossvalstats(y_real,y_cv,n,p);
    stats.y_real = y;
    stats.y_pred = y_pred;
    output.stats = stats;
end

end