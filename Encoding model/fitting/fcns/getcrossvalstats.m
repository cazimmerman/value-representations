function stats = getcrossvalstats(y_real,y_pred,n,p)

stats.SST = sumsqr(y_real-mean(y_real)); % total sum of squares
stats.SSR = sumsqr(y_pred-mean(y_real)); % regression/model sum of squares
stats.SSE = sumsqr(y_real-y_pred); % error/residual sum of squares
stats.DFT = n-1; % total degrees of freedom
stats.DFR = p-1; % regression/model degrees of freedom
stats.DFE = n-p; % error/residual degrees of freedom
stats.MST = stats.SST/stats.DFT; % total mean of squares
stats.MSR = stats.SSR/stats.DFR; % regression/model mean of squares
stats.MSE = stats.SSE/stats.DFE; % error/residual mean of squares
stats.R2 = 1-stats.SSE/stats.SST; % Coefficient of determination

end