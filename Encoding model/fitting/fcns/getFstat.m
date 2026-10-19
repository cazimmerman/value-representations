function F = getFstat(full,reduced)

F = (reduced.SSE-full.SSE)/(full.DFR-reduced.DFR)/full.MSE;

end