function design = makedesign2(x,y,i,predictors,~,n,~,model_parameters,kerneltrials,speed,licks)

kerneltrials = kerneltrials{i};
design = zeros(sum(n.predictors),length(x));

for j = 1:n.kernels
    if kerneltrials{j}
        if j <= 7
            bins = zeros(size(x)); bins(y(n.kernel_event(j))) = 1;
            a = conv(bins,model_parameters.kernels{j}{kerneltrials{j}},'same');
        elseif j == 8
            a = zeros(size(x));
        elseif j == 9
            a = zeros(size(x));
        elseif j == 10
            a = conv(x,model_parameters.kernels{j}{1},'same') + model_parameters.baseline;
        end
        idx = sum(n.predictors(1:j-1))+1:sum(n.predictors(1:j));
        design(idx,:) =  cellfun(@(x) x(i),predictors{j})'.*repmat(a,n.predictors(j),1);
    end
end
design = design(:,rmmissing(unique([y(1):y(1)+100,y(2)-50:y(2)+50,y(4):y(4)+200,y(5):y(5)+200])));

end