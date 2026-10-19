function [predictors,kernel_types,vel] = getpredictors(data,trials,idx,hemisphere,var1)

if isequal(var1,'QLEARNING')
    out{1} = data.events.QL_total-data.events.QR_total; % Q-learning, action value
%     out{1} = data.events.QL_total; % Q-learning, QL value
    out{2} = zeros(size(data.events.QL_total));
    out{3} = zeros(size(data.events.QL_total));
    out{4} = data.events.state_value; % Q-learning, state value
%     out{4} = data.events.QR_total; % Q-learning, QR value
    out{5} = zeros(size(data.events.QL_total));
    out{6} = zeros(size(data.events.QL_total));
elseif isequal(var1,'CRAC')
    out{1} = data.events.CRAC_Vcs;
    out{2} = data.events.CRAC_Vchoice;
    out{3} = data.events.CRAC_PIchoice;
    out{4} = zeros(size(out{1}));
    out{5} = zeros(size(out{1}));
    out{6} = zeros(size(out{1}));
    if hemisphere
        out{3} = -out{3};
    end
elseif isequal(var1,'Residuals')
    out{1} = zeros(size(data.events.choice));
    out{2} = zeros(size(data.events.choice));
    out{3} = zeros(size(data.events.choice));
    out{4} = zeros(size(data.events.choice));
    out{5} = zeros(size(data.events.choice));
    out{6} = zeros(size(data.events.choice));
end
out{7} = ones(size(out{1})); % constant
out{8} = cellfun(@(x) abs(x), data.wheel.vel(trials), 'UniformOutput', false);
tdata   = cellfun(@(x,y) x(rmmissing(unique([y(1):y(1)+100,y(2)-50:y(2)+50,y(4):y(4)+200,y(5):y(5)+200]))), out{8}, idx, 'UniformOutput', false);
mu      = mean([tdata{:}]); sigma = std([tdata{:}]);
out{8} = cellfun(@(x) (x-mu)./sigma, out{8}, 'UniformOutput', false);

% if hemisphere % Relative/State
%     out{1} = -out{1};
% end
% if hemisphere % Contra/Ipsi
%     out([1 4]) = out([4 1]);
% end

for i = 1:length(out)
    if size(out{i},1) > 1
        out{i} = out{i}';
    end
end

Qvalues_idx = 1:6;
Constant_idx = 7;

out([Qvalues_idx,Constant_idx]) = cellfun(@(x) x(trials),out([Qvalues_idx,Constant_idx]),'UniformOutput',false);
out(Qvalues_idx) = cellfun(@(x) zscore(double(x)), out(Qvalues_idx), 'UniformOutput', false);

predictors{1} = out([Constant_idx,Qvalues_idx]); % cue
predictors{2} = out([Constant_idx,Qvalues_idx]); % CCW choice
predictors{3} = out([Constant_idx,Qvalues_idx]); % CW choice
predictors{4} = out([Constant_idx,Qvalues_idx]); % water CS+
predictors{5} = out([Constant_idx,Qvalues_idx]); % laser CS+
predictors{6} = out([Constant_idx,Qvalues_idx]); % none CS-
predictors{7} = out([Constant_idx,Qvalues_idx]); % laser delivery
predictors{8} = out([Constant_idx,Qvalues_idx]); % wheel vel
predictors{9} = out([Constant_idx,Qvalues_idx]); % licking
predictors{10} = out(Constant_idx);      % autoregressive

for i = 1:length(trials)
    kernel_types{i}{1} = [1];
    if hemisphere
        kernel_types{i}{2} = [data.events.choice(trials(i)) ~= 1];
        kernel_types{i}{3} = [data.events.choice(trials(i)) == 1];
    else
        kernel_types{i}{2} = [data.events.choice(trials(i)) == 1];
        kernel_types{i}{3} = [data.events.choice(trials(i)) ~= 1];
    end
    kernel_types{i}{4} = [data.events.total(trials(i)) == 1];
    kernel_types{i}{5} = [data.events.laser(trials(i)) == 1];
    kernel_types{i}{6} = [data.events.feedback(trials(i)) ~= 1];
    kernel_types{i}{7} = [NaN];
    kernel_types{i}{8} = [1];
    kernel_types{i}{9} = [1];
    kernel_types{i}{10} = [1];
end

vel = out{8};