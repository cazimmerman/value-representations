function lambdas = getlambda(x,y,o,opts,cvp,DF,offset)

y_real = [y{:}]';
nFolds = length(cvp.test);
if offset
    p = DF.step2 - 1;
else
    p = DF.step1 + 1;
end
MSE = nan(nFolds,length(opts.lambda));

w = nan(nFolds,1);
for k = 1:nFolds
    train_idx = cvp.train{k};
    test_idx  = cvp.test{k};
    train_Y = sparse([y{train_idx}]');
    train_X = sparse([x{train_idx}]');
    if offset
        opts.offset = sparse([o{train_idx}]');
    end
    mdl = glmnet(train_X,train_Y,'gaussian',opts);
    y_cv = nan(size(sparse([y{:}]'),1),length(opts.lambda));
    yy   = nan(size(sparse([y{:}]'),1),1);
    for j = 1:length(test_idx)
        idx1 = sum(cellfun(@length, y(1:(test_idx(j)-1))))+1;
        idx2 = sum(cellfun(@length, y(1:(test_idx(j)))));
        if offset
            temp = glmnetPredict(mdl,sparse(x{test_idx(j)}'),[],'response',false,sparse([o{test_idx(j)}]'));
            y_cv(idx1:idx2,1:size(temp,2)) = temp;
        else
            temp = glmnetPredict(mdl,sparse(x{test_idx(j)}'),[],'response',false,[]);
            y_cv(idx1:idx2,1:size(temp,2)) = temp;
        end
        yy(idx1:idx2,1) = y_real(idx1:idx2);
    end
    y_cv = y_cv(~isnan(y_cv(:,1)),:);
    yy = yy(~isnan(yy));
    n = length(yy);
    w(k) = length(yy);
    for i = 1:length(opts.lambda)
        MSE(k,i) = sumsqr(yy-y_cv(:,i))/(n-p);
    end
end
w = w./sum(w)*length(w);
MSE = MSE.*w;
[~,I] = min(mean(MSE));
II = find(mean(MSE)<=(mean(MSE(:,I))+std(MSE(:,I))),1,'first');

lambdas.lambda_min = opts.lambda(I);
lambdas.lambda_1se = opts.lambda(II);

end