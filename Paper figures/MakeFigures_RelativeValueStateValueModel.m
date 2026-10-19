%% Setup
clearvars; close all; clc;
addpath(genpath('utils'));

warning('off','all')
data_dir = uigetdir([],'Select folder with mat files');
load([data_dir,'\RelativeValueStateValueModel.mat'])
atlas_dir = uigetdir([],'Select folder with atlas files');
output_dir   = 'output';
if ~isfolder(output_dir)
    mkdir(output_dir)
end
close_after_save = true;
save_fig = @(name) save_figure(output_dir,name,close_after_save);
panel_pos = [1 4 1:3];

cutoff = 0.01+1E-10;

StatsTbl = table('Size',[0 6],'VariableTypes',{'cell','cell','cell','cell','double','double'}, ...
    'VariableNames',{'Figure panel','Group','Statistical test','Sample size','Test statistic','P-value'});

for f = {'remove_AllValues','remove_RelativeValue','remove_StateValue','remove_StateValue_Q_total','remove_StateValue_Q_total_weighted'}
    EncodingModelOutput.delta_r2.AllKernels.(f{1}) = EncodingModelOutput.delta_r2.AllKernels.(f{1}) ...
                                               - EncodingModelOutput.delta_r2.AllKernels.([f{1},'_null']);
end

% NOTE: "Contra" and "Ipsi" labels are flipped in the .mat file when
%       compared to the figure captions and manuscript text. The figures
%       and manuscript text are correct (see Methods section for details).
%% Statistics for Fig. 3d, 3e, Extended Data Fig. 7e

rk = EncodingModelOutput.region_key;
rid = EncodingModelOutput.region_id;
pairs_striatum = [7 5; 7 6; 7 8; 5 6; 5 8];

StatsTbl = add_chi2_rows(StatsTbl,'3d',rk,rid,EncodingModelOutput.pvalues.AllKernels.remove_RelativeValue,pairs_striatum,cutoff);
StatsTbl = add_chi2_rows(StatsTbl,'3e',rk,rid,EncodingModelOutput.pvalues.AllKernels.remove_StateValue,pairs_striatum,cutoff);

dr2 = EncodingModelOutput.delta_r2.AllKernels.remove_StateValue;
[p,Z] = ranksum_z(dr2(rid==7),dr2(rid==8));
StatsTbl(end+1,:) = stats_row('ED7e',[rk{7},' vs. ',rk{8}],'Mann–Whitney U test (normal approximation)',[sum(rid==7) sum(rid==8)],Z,p);
%% Fig. 3d, 3e, Extended Data Fig. 7a, 7b, 7d, 7e

c = 1:length(EncodingModelOutput.region_key);
cmap = region_cmap();
xvals = [1,2,3,4,6,7,8,9,11,12];
legendvals = region_legend_labels(EncodingModelOutput,c);
bar_panel = @(pos,pvals,ylimits,yticklist,xlimits,ttl) region_bar_panel(pos,pvals,EncodingModelOutput,cutoff,xvals,cmap,ylimits,yticklist,xlimits,ttl);
box_panel = @(pos,dr2,ttl) region_box_panel(pos,dr2,EncodingModelOutput,xvals,cmap,ttl);

disp('Generating Fig. 3d/Extended Data Fig. 7a ...')
new_figure(1000,500)
bar_panel(panel_pos,EncodingModelOutput.pvalues.AllKernels.remove_RelativeValue,[0 20],0:5:50,[0 13],['Fig. 3d/Extended Data Fig. 7a',char(10),'Relative Value'])
region_legend_panel(cmap,legendvals,1:10)
save_fig('Fig_3d_Fig_ED7a')

disp('Generating Extended Data Fig. 7b ...')
new_figure(1000,500)
box_panel(panel_pos,EncodingModelOutput.delta_r2.AllKernels.remove_RelativeValue,['Extended Data Fig. 7b',char(10),'Relative Value'])
region_legend_panel(cmap,legendvals,1:10)
save_fig('Fig_ED7b')

disp('Generating Fig. 3e/Extended Data Fig. 7d ...')
new_figure(1000,500)
bar_panel(panel_pos,EncodingModelOutput.pvalues.AllKernels.remove_StateValue,[0 40],0:10:50,[0 13],['Fig. 3e/Extended Data Fig. 7d',char(10),'State Value'])
region_legend_panel(cmap,legendvals,1:10)
save_fig('Fig_3e_Fig_ED7d')

disp('Generating Extended Data Fig. 7e ...')
new_figure(1000,500)
box_panel(panel_pos,EncodingModelOutput.delta_r2.AllKernels.remove_StateValue,['Extended Data Fig. 7e',char(10),'State Value'])
region_legend_panel(cmap,legendvals,1:10)
save_fig('Fig_ED7e')
%% Extended Data Fig. 7n, 7o

c = 1:length(EncodingModelOutput.region_key);
cmap = region_cmap();
xvals = [1,2,3,4,6,7,8,9,11,12];
legendvals = region_legend_labels(EncodingModelOutput,c);
bar_panel = @(pos,pvals,ylimits,yticklist,xlimits,ttl) region_bar_panel(pos,pvals,EncodingModelOutput,cutoff,xvals,cmap,ylimits,yticklist,xlimits,ttl);

disp('Generating Extended Data Fig. 7n ...')
new_figure(1000,500)
bar_panel(panel_pos,EncodingModelOutput.pvalues.AllKernels.remove_StateValue_Q_total,[0 40],0:10:50,[5 10],['Extended Data Fig. 7n',char(10),'Q^{contra} + Q^{ipsi}'])
region_legend_panel(cmap,legendvals,5:8)
save_fig('Fig_ED7n')

disp('Generating Extended Data Fig. 7o ...')
new_figure(1000,500)
bar_panel(panel_pos,EncodingModelOutput.pvalues.AllKernels.remove_StateValue_Q_total_weighted,[0 40],0:10:50,[5 10],['Extended Data Fig. 7o',char(10),'P(contra)*Q^{contra} + P(ipsi)*Q^{ipsi}'])
region_legend_panel(cmap,legendvals,5:8)
save_fig('Fig_ED7o')
%% Extended Data Fig. 8e, 8f, 8g

c = 1:length(EncodingModelOutput.region_key);
cmap = region_cmap();
legendvals = region_legend_labels(EncodingModelOutput,c);
alphas = EncodingModelOutput.learning_rate.alpha_reward.R2.alphas;
gammas = EncodingModelOutput.learning_rate.gamma_forget.R2.gammas;

disp('Generating Extended Data Fig. 8e (top) ...')
new_figure(1000,500)
pl = curve_stats(EncodingModelOutput,'alpha_reward','remove_StateValue',c,'corrected');
curve_panel(panel_pos,alphas,pl,cmap,'α_{reward}','Corrected ΔR^2 (%)',['Extended Data Fig. 8e, top',char(10),'Relative value'])
region_legend_panel(cmap,legendvals,5:8)
save_fig('Fig_ED8e_top')

disp('Generating Extended Data Fig. 8e (middle) ...')
new_figure(1000,500)
pl = curve_stats(EncodingModelOutput,'alpha_reward','remove_StateValue',c,'real');
curve_panel(panel_pos,alphas,pl,cmap,'α_{reward}','Real ΔR^2 (%)',['Extended Data Fig. 8e, middle',char(10),'Relative value'])
region_legend_panel(cmap,legendvals,5:8)
save_fig('Fig_ED8e_middle')

disp('Generating Extended Data Fig. 8e (bottom) ...')
new_figure(1000,500)
pl = curve_stats(EncodingModelOutput,'alpha_reward','remove_StateValue',c,'null');
curve_panel(panel_pos,alphas,pl,cmap,'α_{reward}','Null ΔR^2 (%)',['Extended Data Fig. 8e, bottom',char(10),'Relative value'])
region_legend_panel(cmap,legendvals,5:8)
save_fig('Fig_ED8e_bottom')

disp('Generating Extended Data Fig. 8f (top) ...')
new_figure(1000,500)
pl = curve_stats(EncodingModelOutput,'alpha_reward','remove_RelativeValue',c,'corrected');
curve_panel(panel_pos,alphas,pl,cmap,'α_{reward}','Corrected ΔR^2 (%)',['Extended Data Fig. 8f, top',char(10),'State value'])
region_legend_panel(cmap,legendvals,5:8)
save_fig('Fig_ED8f_top')

disp('Generating Extended Data Fig. 8f (middle) ...')
new_figure(1000,500)
pl = curve_stats(EncodingModelOutput,'alpha_reward','remove_RelativeValue',c,'real');
curve_panel(panel_pos,alphas,pl,cmap,'α_{reward}','Real ΔR^2 (%)',['Extended Data Fig. 8f, middle',char(10),'State value'])
region_legend_panel(cmap,legendvals,5:8)
save_fig('Fig_ED8f_middle')

disp('Generating Extended Data Fig. 8f (bottom) ...')
new_figure(1000,500)
pl = curve_stats(EncodingModelOutput,'alpha_reward','remove_RelativeValue',c,'null');
curve_panel(panel_pos,alphas,pl,cmap,'α_{reward}','Null ΔR^2 (%)',['Extended Data Fig. 8f, bottom',char(10),'State value'])
region_legend_panel(cmap,legendvals,5:8)
save_fig('Fig_ED8f_bottom')

disp('Generating Extended Data Fig. 8g (top) ...')
new_figure(1000,500)
pl = curve_stats(EncodingModelOutput,'gamma_forget','remove_StateValue',c,'corrected');
curve_panel(panel_pos,gammas,pl,cmap,'γ_{forget}','Corrected ΔR^2 (%)',['Extended Data Fig. 8g, top',char(10),'Relative value'])
region_legend_panel(cmap,legendvals,5:8)
save_fig('Fig_ED8g_top')

disp('Generating Extended Data Fig. 8g (middle) ...')
new_figure(1000,500)
pl = curve_stats(EncodingModelOutput,'gamma_forget','remove_StateValue',c,'real');
curve_panel(panel_pos,gammas,pl,cmap,'γ_{forget}','Real ΔR^2 (%)',['Extended Data Fig. 8g, middle',char(10),'Relative value'])
region_legend_panel(cmap,legendvals,5:8)
save_fig('Fig_ED8g_middle')

disp('Generating Extended Data Fig. 8g (bottom) ...')
new_figure(1000,500)
pl = curve_stats(EncodingModelOutput,'gamma_forget','remove_StateValue',c,'null');
curve_panel(panel_pos,gammas,pl,cmap,'γ_{forget}','Null ΔR^2 (%)',['Extended Data Fig. 8g, bottom',char(10),'Relative value'])
region_legend_panel(cmap,legendvals,5:8)
save_fig('Fig_ED8g_bottom')
%% Atlas visualizations (Fig. 3h, 3i, Extended Data Fig. 7c, 7f, 7k, 7l)
filename = [atlas_dir,'\allen_subdivisions.tif'];
warning('off','all')
tstack  = Tiff(filename);
[I,J] = size(tstack.read());
K = length(imfinfo(filename));
atlas = zeros(K,I,J);
atlas(1,:,:)  = tstack.read();
for n = 2:K
    tstack.nextDirectory()
    atlas(n,:,:) = tstack.read();
end
atlas(:,:,571:end) = 0;
filename = [atlas_dir,'\41467_2019_13057_MOESM4_ESM.csv'];
key = readtable(filename);

Data = struct;
Data.idx = find(cellfun(@(x) isequal(x,'Striatum'),key{:,1})):find(cellfun(@(x) isequal(x,'Lateral accumbens, shell region'),key{:,1}));
Data.viz   = [0 0 0 1 0 1 1 1 0 1 1 0 0 1 1 1 1 0 1 1 1 0 1 1 0 1 1 1 1 0 1 1 1 1 0 1 1 1 1 1 0 0 0 0 1 1 1];
Data.group = [0 0 0 2 0 2 2 2 0 2 2 0 0 3 3 3 3 0 3 3 3 0 3 3 0 3 3 3 3 0 4 4 4 4 0 4 4 4 4 4 0 0 0 0 1 1 1];
Data.name = key{Data.idx,1};
Data.name(find(cellfun(@(x) isequal(x,'Caudoputamen- intermediate, dorsomedial, dorsal tip '),Data.name))) = {'Caudoputamen- intermediate, dorsomedial, dorsal tip'};
Data.abbrev = key{Data.idx,2};
Data.atlas = key{Data.idx,3};
Data.count = [];
Data.pvalues.remove_RelativeValue = cell(size(Data.name));
Data.pvalues.remove_StateValue = cell(size(Data.name));
Data.deltaR2.remove_RelativeValue = cell(size(Data.name));
Data.deltaR2.remove_StateValue = cell(size(Data.name));
for i = 1:length(Data.idx)
    region_idx = find(cellfun(@(x) isequal(x,Data.name{i}),EncodingModelOutput.region_name));
    Data.count(i) = length(region_idx);
    Data.pvalues.remove_RelativeValue{i} = EncodingModelOutput.pvalues.AllKernels.remove_RelativeValue(region_idx);
    Data.pvalues.remove_StateValue{i} = EncodingModelOutput.pvalues.AllKernels.remove_StateValue(region_idx);
    Data.deltaR2.remove_RelativeValue{i} = EncodingModelOutput.delta_r2.AllKernels.remove_RelativeValue(region_idx);
    Data.deltaR2.remove_StateValue{i} = EncodingModelOutput.delta_r2.AllKernels.remove_StateValue(region_idx);
end

planes = [28 33 38 43 48 53]+1;
brainoutline = atlas>0;
ACA = atlas==900;

pct_sig = @(pv) cellfun(@(x) sum(x<=0.01001)./numel(x)*100,pv);

% Fig. 3h + Extended Data Fig. 7c, 7k (Relative Value)
cmap = cbrewer('seq','Reds',1000,'spline');

disp('Generating Fig. 3h/Extended Data Fig. 7c ...')
new_figure(2000,500)
colors = metric_to_colors(pct_sig(Data.pvalues.remove_RelativeValue),Data.count,30,cmap);
cb = struct('Ticks',[0 .5 1],'TickLabels',{{'0','15','30'}},'Label','Significant (%)');
draw_atlas_row(planes,atlas,brainoutline,ACA,Data,colors,cmap,cb,['Fig. 3h/Extended Data Fig. 7c',char(10),'Relative Value']);
save_fig('Fig_3h_Fig_ED7c')

disp('Generating Extended Data Fig. 7k ...')
new_figure(2000,500)
colors = metric_to_colors(cellfun(@mean,Data.deltaR2.remove_RelativeValue)*100,Data.count,0.1,cmap);
cb = struct('Ticks',[0 .5 1],'TickLabels',{{'0','0.05','0.1'}},'Label','Corrected ΔR^2 (%)');
draw_atlas_row(planes,atlas,brainoutline,ACA,Data,colors,cmap,cb,['Extended Data Fig. 7k',char(10),'Relative Value']);
save_fig('Fig_ED7k')

% Fig. 3i + Extended Data Fig. 7f, 7l (State Value)
cmap = cbrewer('seq','Blues',1000,'spline');

disp('Generating Fig. 3i/Extended Data Fig. 7f ...')
new_figure(2000,500)
colors = metric_to_colors(pct_sig(Data.pvalues.remove_StateValue),Data.count,50,cmap);
cb = struct('Ticks',[0 .5 1],'TickLabels',{{'0','25','50'}},'Label','Significant (%)');
draw_atlas_row(planes,atlas,brainoutline,ACA,Data,colors,cmap,cb,['Fig. 3i/Extended Data Fig. 7f',char(10),'State Value']);
save_fig('Fig_3i_Fig_ED7f')

disp('Generating Extended Data Fig. 7l ...')
new_figure(2000,500)
colors = metric_to_colors(cellfun(@mean,Data.deltaR2.remove_StateValue)*100,Data.count,0.1,cmap);
cb = struct('Ticks',[0 .5 1],'TickLabels',{{'0','0.05','0.1'}},'Label','Corrected ΔR^2 (%)');
draw_atlas_row(planes,atlas,brainoutline,ACA,Data,colors,cmap,cb,['Extended Data Fig. 7l',char(10),'State Value']);
save_fig('Fig_ED7l')
%% Extended Data Fig. 7g, 7h

cmap = [[86 138 66]/255; ...
        [255 120 0]/255;...
        [242 166 29]/255;...
        [211 215 38]/255];

xvals = 1:sum(Data.viz);
xvals(end-8:end) = xvals(end-8:end)+1;
xvals(end-8-13:end) = xvals(end-8-13:end)+1;
xvals(end-8-13-6:end) = xvals(end-8-13-6:end)+1;
c = find(Data.viz);
c = circshift(c,3);
in_region = @(i) cellfun(@(x) isequal(x,Data.name{c(i)}),EncodingModelOutput.region_name);

abbrevs = cellfun(@(x) x(~isspace(x)),Data.abbrev(c),'UniformOutput',false);
legendvals = abbrevs;
ddd = Data.count(c);
for i = 1:length(c)
    idx = find(in_region(i));
    A = length(unique(EncodingModelOutput.recording_id(idx)));
    B = length(EncodingModelOutput.recording_id(idx));
    C = length(unique(EncodingModelOutput.animal_id(idx)));
    legendvals{i} = [abbrevs{i},' (',num2str(C),'/',num2str(A),'/',num2str(B),')'];
end

disp('Generating Extended Data Fig. 7g ...')
new_figure(1000,500)
subplot(panel_pos(1),panel_pos(2),panel_pos(3:end));
hold on
axis square
for i = 1:length(c)
    vals = EncodingModelOutput.delta_r2.AllKernels.remove_RelativeValue(in_region(i))*100;
    if length(vals)>=5
        simpleboxplot(xvals(i),vals,cmap(Data.group(c(i)),:));
    end
end
xlim([0 xvals(end)+1]); xticks(xvals)
ylabel('Corrected ΔR^2 (%)'); ylim([-.1 .3]); yticks(-.1:.1:.3);
xticklabels(abbrevs)
xtickangle(90)
title(['Extended Data Fig. 7g',char(10),'Relative Value'])
style_axes(true)
hold off
subcompartment_legend(cmap,Data,c,ddd,legendvals)
save_fig('Fig_ED7g')

disp('Generating Extended Data Fig. 7h ...')
new_figure(1000,500)
subplot(panel_pos(1),panel_pos(2),panel_pos(3:end));
hold on
axis square
for i = 1:length(c)
    vals = EncodingModelOutput.delta_r2.AllKernels.remove_StateValue(in_region(i))*100;
    if length(vals)>=5
        simpleboxplot(xvals(i),vals,cmap(Data.group(c(i)),:));
    end
end
xlim([0 xvals(end)+1]); xticks(xvals)
ylabel('Corrected ΔR^2 (%)'); ylim([-.1 .3]); yticks(-.1:.1:.3);
xticklabels(abbrevs)
xtickangle(90)
title(['Extended Data Fig. 7h',char(10),'State Value'])
style_axes(true)
hold off
subcompartment_legend(cmap,Data,c,ddd,legendvals)
save_fig('Fig_ED7h')
%% Fig. 3j, Extended Data Fig. 7m

idx = find(EncodingModelOutput.region_id==7);
ML = EncodingModelOutput.cluster_locations.ML(idx);
DV = EncodingModelOutput.cluster_locations.DV(idx);
cmap = [0.4157 0.3176 0.6392; 0.7961 0.0941 0.1137; 0.1294 0.4431 0.7098];
setLabel = {'AllValues','RelativeValue','StateValue'};
sem = @(x) std(x)./sqrt(length(x));
binom_err = @(x) sqrt((sum(x>0)./length(x)) * (1-(sum(x>0)./length(x))) / (length(x)))*100;

ActionValue = EncodingModelOutput.pvalues.AllKernels.remove_RelativeValue(idx)<=cutoff;
StateValue = EncodingModelOutput.pvalues.AllKernels.remove_StateValue(idx)<=cutoff;

bins = 1:.25:3;
B = bin_values(ML,bins,ActionValue);
C = bin_values(ML,bins,StateValue);
[p,x2] = cellfun(@pct_sig_p,B,C);
StatsTbl = add_bin_rows(StatsTbl,'3j, left','χ2 test',bins,cellfun(@numel,B),x2,p);
disp('Generating Fig. 3j (left) ...')
new_figure(500,500)
binned_panel([1 1 1],bins(1:end-1)+.125,B,C,cmap,binom_err,setLabel,[1 3],1:.5:3,[0 60],0:20:60,'Coordinate (mm)','Significant (%)',['Fig. 3j, left',char(10),'Medial-Lateral'])
save_fig('Fig_3j_left')

bins = 2.25:.5:5.75;
B = bin_values(DV,bins,ActionValue);
C = bin_values(DV,bins,StateValue);
[p,x2] = cellfun(@pct_sig_p,B,C);
StatsTbl = add_bin_rows(StatsTbl,'3j, right','χ2 test',bins,cellfun(@numel,B),x2,p);
disp('Generating Fig. 3j (right) ...')
new_figure(500,500)
binned_panel([1 1 1],bins(1:end-1)+.25,B,C,cmap,binom_err,setLabel,[2 6],2:1:6,[0 60],0:20:60,'Coordinate (mm)','Significant (%)',['Fig. 3j, right',char(10),'Dorsal-Ventral'])
save_fig('Fig_3j_right')

ActionValue = EncodingModelOutput.delta_r2.AllKernels.remove_RelativeValue(idx);
StateValue = EncodingModelOutput.delta_r2.AllKernels.remove_StateValue(idx);

bins = 1:.25:3;
B = bin_values(ML,bins,ActionValue);
C = bin_values(ML,bins,StateValue);
[p,Z] = cellfun(@(b,c) ranksum_z(c,b),B,C);
StatsTbl = add_bin_rows(StatsTbl,'ED7m, left','Mann–Whitney U test (normal approximation)',bins,cellfun(@numel,B),Z,p);
disp('Generating Extended Data Fig. 7m (left) ...')
new_figure(500,500)
binned_panel([1 1 1],bins(1:end-1)+.125,B,C,cmap,sem,setLabel,[1 3],1:.5:3,[-.05 .15],-.05:.05:.15,'Coordinate (mm)','Corrected ΔR^2 (%)',['Extended Data Fig. 7m, left',char(10),'Medial-Lateral'])
save_fig('Fig_ED7m_left')

bins = 2.25:.5:5.75;
B = bin_values(DV,bins,ActionValue);
C = bin_values(DV,bins,StateValue);
[p,Z] = cellfun(@(b,c) ranksum_z(c,b),B,C);
StatsTbl = add_bin_rows(StatsTbl,'ED7m, right','Mann–Whitney U test (normal approximation)',bins,cellfun(@numel,B),Z,p);
disp('Generating Extended Data Fig. 7m (right) ...')
new_figure(500,500)
binned_panel([1 1 1],bins(1:end-1)+.25,B,C,cmap,sem,setLabel,[2 6],2:1:6,[-.05 .15],-.05:.05:.15,'DV coordinate (mm)','Corrected ΔR^2 (%)',['Extended Data Fig. 7m, right',char(10),'Dorsal-Ventral'])
save_fig('Fig_ED7m_right')
%% Stats table

StatsTbl{:,5} = round(StatsTbl{:,5},2);
StatsTbl{:,6} = round(StatsTbl{:,6},2,'significant');
StatsTbl{StatsTbl{:,6}>0.05,7} = {'NS'};
StatsTbl{StatsTbl{:,6}<=0.05,7} = {'*'};
StatsTbl{StatsTbl{:,6}<=0.01,7} = {'**'};
StatsTbl{StatsTbl{:,6}<=0.001,7} = {'***'};
StatsTbl{StatsTbl{:,6}<=0.0001,7} = {'****'};
StatsTbl = renamevars(StatsTbl,'Var7','Significant');
StatsTbl = sortrows(StatsTbl,1);
disp(StatsTbl)
%% Local functions

function new_figure(w,h)
    figure('Position',[100 100 w h])
end

function save_figure(folder,name,close_after)
    saveas(gcf,[folder,'/',name],'png')
    if close_after
        close(gcf)
    end
end

function style_axes(zero_xticklength)
    set(gca,'FontSize',10,'LineWidth',1,'TickLength',[0.025, 0],'TickDir','out')
    if zero_xticklength
        h = gca; h.XAxis.TickLength = [0 0];
    end
end

function cmap = region_cmap()
    c1 = [.25 .25 .25];
    c2 = [.25 .25 .25];
    cmap = [c1;...
        c1+1*[1-c1]/4;...
        c1+2*[1-c1]/4;...
        c1+3*[1-c1]/4;...
        [86 138 66]/255;...
        [255 120 0]/255;...
        [242 166 29]/255;...
        [211 215 38]/255;...
        c2; ...
        c2+1*[1-c2]/2];
end

function vals = region_full_names()
    vals = {'OFC', ...
        'PFC', ...
        'MO', ...
        'SS', ...
        'NAc', ...
        'CP-Ros', ...
        'CP-Int', ...
        'CP-Cau', ...
        'VP', ...
        'GPe'};
end

function legendvals = region_legend_labels(ES,c)
    legendvals = region_full_names();
    for i = 1:length(c)
        idx = find(ES.region_id==c(i));
        A = length(unique(ES.recording_id(idx)));
        B = length(ES.recording_id(idx));
        C = length(unique(ES.animal_id(idx)));
        legendvals{i} = [legendvals{i},' (',num2str(C),'/',num2str(A),'/',num2str(B),')'];
    end
end

function region_legend_panel(cmap,legendvals,regions)
    subplot(1,4,4)
    hold on
    for i = regions
        bar(-100,1,'FaceColor',cmap(i,:),'LineStyle','none')
    end
    xlim([0 1]); xticks(0:.25:1);
    legend(legendvals(regions),'Location','East','FontSize',10,'Box','off')
    set(gca,'Visible','off')
    hold off
end

function subcompartment_legend(cmap,Data,c,ddd,legendvals)
    subplot(1,4,4)
    hold on
    for i = 1:length(c)
        if ddd(i)>=5
            bar(-100,1,'FaceColor',cmap(Data.group(c(i)),:),'LineStyle','none')
        else
            bar(-100,1,'FaceColor',[.5 .5 .5],'LineStyle','none')
        end
    end
    xlim([0 1]); xticks(0:.25:1);
    legend(legendvals,'Location','East','FontSize',6,'Box','off')
    set(gca,'Visible','off')
    hold off
end

function region_bar_panel(pos,pvals,ES,cutoff,xvals,cmap,ylimits,yticklist,xlimits,ttl)
    a = pvals;
    b = ES.region_id;
    c = 1:length(ES.region_key);
    ccc = nan(size(c));
    ddd = nan(size(c));
    for i = 1:length(c)
        ccc(i) = sum(a(b==c(i))<=cutoff)/length(a(b==c(i)));
        ddd(i) = length(a(b==c(i)));
    end
    subplot(pos(1),pos(2),pos(3:end))
    hold on
    axis square
    plot([0 13],[1 1],'k--')
    h = bar(xvals,ccc*100,'FaceColor','flat','LineStyle','none');
    h.CData = cmap;
    for i = 1:length(c)
        S = sqrt(ccc(i)*(1-ccc(i))/ddd(i))*100;
        plot([xvals(i) xvals(i)],[-S S]+ccc(i)*100,'Color',cmap(i,:),'LineWidth',2)
        plot(xvals(i)+[-.25 .25],[S S]+ccc(i)*100,'Color',cmap(i,:),'LineWidth',2)
    end
    ylim(ylimits); yticks(yticklist)
    xlim(xlimits); xticks(xvals)
    ylabel('Significant (%)')
    xticklabels(ES.region_key)
    xtickangle(90)
    title(ttl)
    style_axes(true)
    hold off
end

function region_box_panel(pos,dr2,ES,xvals,cmap,ttl)
    subplot(pos(1),pos(2),pos(3:end))
    hold on
    axis square
    for i = 1:length(ES.region_key)
        vals = dr2(find(ES.region_id==i))*100;
        simpleboxplot(xvals(i),vals,cmap(i,:));
    end
    xlim([0 13]); xticks(xvals)
    ylabel('Corrected ΔR^2 (%)'); ylim([-.05 .15]); yticks(-.1:.05:.3);
    xticklabels(ES.region_key)
    xtickangle(90)
    title(ttl)
    style_axes(true)
    hold off
end

function pl = curve_stats(ES,family,remove_field,c,mode)
    R2 = ES.learning_rate.(family).R2;
    pl.means = [];
    pl.sems = [];
    for i = 1:length(c)
        idx = find(ES.region_id==c(i));
        real = R2.(remove_field)(idx,:)-R2.remove_AllValues(idx,:);
        null = R2.([remove_field,'_null'])(idx,:)-R2.remove_AllValues_null(idx,:);
        switch mode
            case 'corrected'
                y = real-null;
            case 'real'
                y = real;
            case 'null'
                y = null;
        end
        pl.means(i,:) = nanmean(y);
        pl.sems(i,:) = nanstd(y)./sqrt(length(idx));
    end
end

function curve_panel(pos,xs,pl,cmap,xlab,ylab,ttl)
    subplot(pos(1),pos(2),pos(3:end))
    hold on
    axis square
    for i = 5:8
        fill([xs;flipud(xs)],[pl.means(i,:)+pl.sems(i,:) fliplr(pl.means(i,:)-pl.sems(i,:))]*100,cmap(i,:)+(1-cmap(i,:))*.8,'LineStyle','none')
        plot(xs,pl.means(i,:)*100,'Color',cmap(i,:),'LineWidth',1)
    end
    ylim([-.025 0.1]); yticks(-.025:.025:.1);
    xlim([0 1]); xticks(0:.25:1);
    xlabel(xlab)
    ylabel(ylab)
    title(ttl)
    style_axes(false)
    hold off
end

function colors = metric_to_colors(metric,count,Cmax,cmap)
    colors = repmat([.5 .5 .5],numel(count),1);
    for i = find(count>=5)
        c = min([round(metric(i)/Cmax*1000),1000]); c = max([1,c]);
        colors(i,:) = cmap(c,:);
    end
end

function draw_atlas_row(planes,atlas,brainoutline,ACA,Data,colors,cmap,cb,ttl)
    n = length(planes);
    for k = 1:n
        plane = planes(k);
        subplot(1,n,k)
        B  = bwboundaries(rot90(squeeze(brainoutline(plane,:,:)),3));
        B2 = bwboundaries(rot90(squeeze(ACA(plane,:,:)),3));
        hold on
        axis square
        axis equal
        for i = 1:length(B)
            fill(B{i}(:,1),B{i}(:,2),'k','LineStyle','none')
        end
        for i = find(Data.viz)
            mask = rot90(squeeze(atlas(plane,:,:)),3) == Data.atlas(i);
            B3 = bwboundaries(mask);
            for j = 1:numel(B3)
                fill(B3{j}(:,1),B3{j}(:,2),colors(i,:),'LineWidth',0.5)
            end
        end
        for i = 1:length(B2)
            fill(B2{i}(:,1),B2{i}(:,2),'k','LineStyle','none')
        end
        colormap(gca,cmap)
        if k == 1
            c1 = colorbar;
            c1.Position = c1.Position+[-.1 .05 0 -.1];
            c1.Ticks = cb.Ticks;
            c1.TickLabels = cb.TickLabels;
            if ~isempty(cb.Label)
                c1.Label.String = cb.Label;
            end
            c1.FontSize = 12;
        end
        if k == 3
            title(ttl)
        end
        axis equal
        ylim([-100 900])
        axis off
        hold off
    end
end

function out = bin_values(coord,bins,vals)
    out = cell(1,length(bins)-1);
    for i = 1:length(bins)-1
        out{i} = vals(find(coord>=bins(i) & coord<bins(i+1)))*100;
    end
end

function [p,x2] = pct_sig_p(b,c)
    z = [sum(b>0) sum(c>0); ...
         sum(b==0) sum(c==0)];
    [~,p,x2] = chi2cont(z);
end

function T = stats_row(panel,group,test,n,stat,p)
    T = table({panel},{group},{test},{n},stat,p, ...
        'VariableNames',{'Figure panel','Group','Statistical test','Sample size','Test statistic','P-value'});
end

function [p,Z] = ranksum_z(a,b)
    [p,~,stats] = ranksum(a,b,'method','approximate');
    Z = stats.zval;
end

function StatsTbl = add_chi2_rows(StatsTbl,panel,rk,rid,pvals,pairs,cutoff)
    for k = 1:size(pairs,1)
        a = pairs(k,1);
        b = pairs(k,2);
        z = [sum(pvals(rid==a)<=cutoff) sum(pvals(rid==b)<=cutoff); ...
             sum(pvals(rid==a)>cutoff)  sum(pvals(rid==b)>cutoff)];
        [~,p,x2] = chi2cont(z);
        StatsTbl(end+1,:) = stats_row(panel,[rk{a},' vs. ',rk{b}],'χ2 test',[sum(rid==a) sum(rid==b)],x2,p);
    end
end

function StatsTbl = add_bin_rows(StatsTbl,panel,test,bins,n,stat,p)
    for k = 1:length(p)
        StatsTbl(end+1,:) = stats_row(panel,sprintf('%.2f–%.2f mm',bins(k),bins(k+1)),test,n(k),stat(k),p(k));
    end
end

function binned_panel(pos,xs,B,C,cmap,errfun,setLabel,xlimits,xtickvals,ylimits,ytickvals,xlab,ylab,ttl)
    subplot(pos(1),pos(2),pos(3:end))
    hold on
    axis square
    series = {B,C};
    for s = 1:2
        m = cellfun(@(x) mean(x),series{s});
        errorbar(xs,m,cellfun(errfun,series{s}),'color',cmap(s+1,:),'linewidth',1,'linestyle','none','capsize',0)
        plot(xs,m,'color',cmap(s+1,:),'linewidth',1)
    end
    ylim(ylimits); yticks(ytickvals);
    xlim(xlimits); xticks(xtickvals);
    for i = 2:length(setLabel)
        text(0.045,0.95-(i-2)*.05,setLabel(i),'Units','Normalized','Color',cmap(i,:),'FontSize',10);
    end
    xlabel(xlab)
    ylabel(ylab)
    title(ttl)
    style_axes(false)
end