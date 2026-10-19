function pvalue = null_distribution_pvalue(real,null)

if any(null-mean(null))
    %if size(null,1) == 1
    %    null = null';
    %end
    %pd = fitdist(null,'Normal');
    %pvalue = 1-normcdf(real,pd.mu,pd.sigma);
    pvalue = 1 - sum(null <= real)./numel(null);
elseif real > mean(null)
    pvalue = 0;
else
    pvalue = 1;
end

end