function init = makedesign1(Y,kerneltrials)

tdata = cellfun(@(x,y) x(rmmissing(unique([y(1):y(1)+100,y(2)-50:y(2)+50,y(4):y(4)+200,y(5):y(5)+200]))),Y.firing,Y.events,'UniformOutput',false);
mu = mean([tdata{:}]);
sigma = std([tdata{:}]);
x = cellfun(@(x) (x-mu)./sigma,Y.firing,'UniformOutput',false);
y = Y.events;
licks = Y.licks;
speed = cell(size(licks));

if nargin == 1
    for i = 1:length(x)
        kerneltrials{i}{1} = 1;
        kerneltrials{i}{2} = 1;
        kerneltrials{i}{3} = 0;
        kerneltrials{i}{4} = 1;
        kerneltrials{i}{5} = 0;
        kerneltrials{i}{6} = 0;
        kerneltrials{i}{7} = 0;
        kerneltrials{i}{8} = 0;
        kerneltrials{i}{9} = 0;
        kerneltrials{i}{10} = 1;
    end
end

cosBasis{1} = czgetbasis(40,[0 1000],10,0);     % cue
cosBasis{2} = czgetbasis(40,[-500 500],10,0);	% CCW movement
cosBasis{3} = czgetbasis(40,[-500 500],10,0);	% CW movement
cosBasis{4} = czgetbasis(80,[0 2000],10,0);     % water CS+
cosBasis{5} = czgetbasis(80,[0 2000],10,0);     % laser CS+
cosBasis{6} = czgetbasis(80,[0 2000],10,0);     % none CS-
cosBasis{7} = czgetbasis(80,[0 2000],10,0);     % laser delivery
cosBasis{8} = czgetbasis(10,[-250 250],10,0);	% wheel vel
cosBasis{9} = czgetbasis(10,[-250 250],10,0);	% licking
cosBasis{10} = czgetbasis(10,[0.01 1000],10,1); % autoregressive
cosBasis =  cellfun(@(x) x./sum(x),cosBasis,'UniformOutput',false);

cosBasis{1} = [zeros(100,size(cosBasis{1},2));cosBasis{1}];
cosBasis{2} = [zeros(50,size(cosBasis{2},2));cosBasis{2};zeros(50,size(cosBasis{2},2))];
cosBasis{3} = [zeros(50,size(cosBasis{3},2));cosBasis{3};zeros(50,size(cosBasis{3},2))];
cosBasis{4} = [zeros(200,size(cosBasis{4},2));cosBasis{4}];
cosBasis{5} = [zeros(200,size(cosBasis{5},2));cosBasis{5}];
cosBasis{6} = [zeros(200,size(cosBasis{6},2));cosBasis{6}];
cosBasis{7} = [zeros(200,size(cosBasis{7},2));cosBasis{7}];
cosBasis{8} = [zeros(75,size(cosBasis{8},2));cosBasis{8};zeros(75,size(cosBasis{8},2))];
cosBasis{9} = [zeros(75,size(cosBasis{9},2));cosBasis{9};zeros(75,size(cosBasis{9},2))];
cosBasis{10} = [zeros(101,size(cosBasis{10},2));cosBasis{10}];

n.kernels = length(cosBasis);
n.kernel_types = cellfun(@(x) size(x,2), kerneltrials{1});
n.kernel_event = [1 2 2 4 4 4 5 NaN NaN NaN];
n.basis = cellfun(@(x) size(x,2), cosBasis);
n.trials = length(x);

X = cellfun(@(x,y,z,var1,var2) makedesign1_trials(x,y,cosBasis,n,z,var1,var2),x,y,kerneltrials,speed,licks,'UniformOutput',false);

init.Y        = x;
init.events   = y;
init.cosBasis = cosBasis;
init.n        = n;
init.design1  = X;
init.kerneltrials = kerneltrials;

%%%%%%
init.speed    = Y.velocity;
init.licks    = Y.licks;

end

function design = makedesign1_trials(x,y,cosBasis,n,kerneltrials,speed,licks)

dimX = n.basis.*n.kernel_types;
design = zeros(sum(n.basis.*n.kernel_types),length(x));
for j = 1:n.kernels
    if kerneltrials{j}
        if j <= 7
            for k = 1:n.basis(j)
                bins = zeros(size(x));
                bins(y(n.kernel_event(j))) = 1;
                idx1 = k + sum(dimX(1:j-1))+size(cosBasis{j},2)*(find(kerneltrials{j})-1);
                a = conv(bins,cosBasis{j}(:,k),'same');
                design(idx1,:) = a;
            end
        elseif j == 8
            for k = 1:n.basis(j)
                idx1 = k + sum(dimX(1:j-1))+size(cosBasis{j},2)*(find(kerneltrials{j})-1);
                bins = zeros(size(x));
                bins(licks(licks<length(bins))) = 1;
                a = conv(bins,cosBasis{j}(:,k),'same');
                design(idx1,:) = a*0;
            end            
        elseif j == 9
            for k = 1:n.basis(j)
                bins = zeros(size(x));
                bins(licks(licks<length(bins))) = 1;
                idx1 = k + sum(dimX(1:j-1))+size(cosBasis{j},2)*(find(kerneltrials{j})-1);
                a = conv(bins,cosBasis{j}(:,k),'same');
                design(idx1,:) = a*0;
            end            
        elseif j ==10
            for k = 1:n.basis(j)
                idx1 = k + sum(dimX(1:j-1))+size(cosBasis{j},2)*(find(kerneltrials{j})-1);
                a = conv(x,cosBasis{j}(:,k),'same');
                design(idx1,:) = a;
            end
        end
    end
end
design = design(:,rmmissing(unique([y(1):y(1)+100,y(2)-50:y(2)+50,y(4):y(4)+200,y(5):y(5)+200])));

end

function cosBasis = czgetbasis(nBasis,kerneldur,binsize,log)

warning ('off','all');
BasisPrs.nBasis = nBasis;
BasisPrs.dt = binsize;
BasisPrs.peakRange = kerneldur;
if log
    BasisPrs.logScaling = 'log';
else
    BasisPrs.logScaling = 'linear';
end
BasisPrs.timeRange = kerneldur;
[cosBasis,~,~] = makeRaisedCosBasis(BasisPrs);
warning ('on','all');

end