function design_out = updatedesign1(design_in,predictors,dimX,gains)

if ~isempty(gains)
    kernel_sizes = dimX;
    coefficients = cellfun(@(x,y) getcoeff(x,y),predictors,gains,'UniformOutput',false);
    coefficients = cellfun(@(x,y) repmat(x,[y 1])',coefficients,num2cell(kernel_sizes),'UniformOutput',false);
    coefficients = mat2cell([coefficients{:}],ones(1,size([coefficients{:}],1)),sum(kernel_sizes))';
    design_out   = cellfun(@(x,y) x.*y',design_in,coefficients,'UniformOutput',false);
else
    design_out = design_in;
end

end

function coefficients = getcoeff(predictors,gains)

A=cellfun(@(x) x',predictors,'UniformOutput',false);
coefficients=gains*[A{:}]';

end