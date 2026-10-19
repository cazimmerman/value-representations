function predictors = reducepredictors(predictors,var_reduce)

if isequal(var_reduce,'AllValues')
    predictors = predictors;
    
    
    
elseif isequal(var_reduce,'remove_ActionValue_AllKernels')
    for i = 1:9
        predictors{i}(2:4) = cellfun(@(x) 0*x,predictors{i}(2:4),'UniformOutput',false);
    end
elseif isequal(var_reduce,'remove_StateValue_AllKernels')
    for i = 1:9
        predictors{i}(5:7) = cellfun(@(x) 0*x,predictors{i}(5:7),'UniformOutput',false);
    end
elseif isequal(var_reduce,'remove_AllValues_AllKernels')
    for i = 1:9
        predictors{i}(2:7) = cellfun(@(x) 0*x,predictors{i}(2:7),'UniformOutput',false);
    end
    
    
    
elseif isequal(var_reduce,'remove_Vcs_AllKernels')
    for i = 1:9
        predictors{i}(2) = cellfun(@(x) 0*x,predictors{i}(2),'UniformOutput',false);
    end
elseif isequal(var_reduce,'remove_Vchoice_AllKernels')
    for i = 1:9
        predictors{i}(3) = cellfun(@(x) 0*x,predictors{i}(3),'UniformOutput',false);
    end
elseif isequal(var_reduce,'remove_Vcs_Vchoice_AllKernels')
    for i = 1:9
        predictors{i}(2:3) = cellfun(@(x) 0*x,predictors{i}(2:3),'UniformOutput',false);
    end
elseif isequal(var_reduce,'remove_PIchoice_AllKernels')
    for i = 1:9
        predictors{i}(4) = cellfun(@(x) 0*x,predictors{i}(4),'UniformOutput',false);
    end

    
    
end