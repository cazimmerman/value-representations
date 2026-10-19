%% Setup
clearvars; close all; clc;
addpath(genpath('utils'));

warning('off','all')
data_dir = uigetdir([],'Select folder with mat files');
load([data_dir,'\ConditionedReinforcerModel.mat'])
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

for f = {'remove_AllValues','remove_Vcs','remove_Vchoice','remove_PIchoice'}
    EncodingModelOutput.delta_r2.AllKernels.(f{1}) = EncodingModelOutput.delta_r2.AllKernels.(f{1}) ...
                                               - EncodingModelOutput.delta_r2.AllKernels.([f{1},'_null']);
end

% NOTE: "Contra" and "Ipsi" labels are flipped in the .mat file when
%       compared to the figure captions and manuscript text. The figures
%       and manuscript text are correct (see Methods section for details).
%% Statistics for Fig. 6i, 6j, 6n, 6o, Extended Data Fig. 12b, 12c

rk = EncodingModelOutput.region_key;
rid = EncodingModelOutput.region_id;
pairs_striatum = [7 5; 7 6; 7 8; 5 6; 5 8];

StatsTbl = add_chi2_rows(StatsTbl,'6i',rk,rid,EncodingModelOutput.pvalues.AllKernels.remove_Vcs,pairs_striatum,cutoff);
StatsTbl = add_ranksum_rows(StatsTbl,'6j',rk,rid,EncodingModelOutput.delta_r2.AllKernels.remove_Vcs,pairs_striatum);
StatsTbl = add_chi2_rows(StatsTbl,'6n',rk,rid,EncodingModelOutput.pvalues.AllKernels.remove_Vchoice,pairs_striatum,cutoff);
StatsTbl = add_ranksum_rows(StatsTbl,'6o',rk,rid,EncodingModelOutput.delta_r2.AllKernels.remove_Vchoice,pairs_striatum);
StatsTbl = add_chi2_rows(StatsTbl,'ED12b',rk,rid,EncodingModelOutput.pvalues.AllKernels.remove_PIchoice,pairs_striatum,cutoff);
StatsTbl = add_ranksum_rows(StatsTbl,'ED12c',rk,rid,EncodingModelOutput.delta_r2.AllKernels.remove_PIchoice,pairs_striatum);

regions_striatum = 5:8;
region_row = rid(:)';
sig_cs = EncodingModelOutput.pvalues.AllKernels.remove_Vcs(:)'<=cutoff;
sig_ch = EncodingModelOutput.pvalues.AllKernels.remove_Vchoice(:)'<=cutoff;
N     = arrayfun(@(r) sum(region_row==r),regions_striatum);
SigCS = arrayfun(@(r) sum(region_row==r & sig_cs),regions_striatum);
SigCh = arrayfun(@(r) sum(region_row==r & sig_ch),regions_striatum);
Both  = arrayfun(@(r) sum(region_row==r & sig_cs & sig_ch),regions_striatum);

StatsTbl = add_binomial_rows(StatsTbl,'6n',rk,regions_striatum,N,SigCh,0.01);
StatsTbl = add_mh_row(StatsTbl,'6i vs. 6n','V(S_{CS+}) vs. V(S_{choice})',N,SigCS,SigCh,Both);
%% Fig. 6i, 6j, 6n, 6o, Extended Data Fig. 12b, 12c

c = 1:length(EncodingModelOutput.region_key);
cmap = region_cmap();
xvals = [1,2,3,4,6,7,8,9,11,12];
legendvals = region_legend_labels(EncodingModelOutput,c);
bar_panel = @(pos,pvals,ylimits,yticklist,xlimits,ttl) region_bar_panel(pos,pvals,EncodingModelOutput,cutoff,xvals,cmap,ylimits,yticklist,xlimits,ttl);
box_panel = @(pos,dr2,ttl) region_box_panel(pos,dr2,EncodingModelOutput,xvals,cmap,[5 10],[-.1 .25],-.1:.05:.3,ttl);

disp('Generating Fig. 6i ...')
new_figure(1000,500)
bar_panel(panel_pos,EncodingModelOutput.pvalues.AllKernels.remove_Vcs,[0 5],0:1:50,[5 10],['Fig. 6i',char(10),'V(S_{CS+})'])
region_legend_panel(cmap,legendvals,5:8)
save_fig('Fig_6i')

disp('Generating Fig. 6j ...')
new_figure(1000,500)
box_panel(panel_pos,EncodingModelOutput.delta_r2.AllKernels.remove_Vcs,['Fig. 6j',char(10),'V(S_{CS+})'])
region_legend_panel(cmap,legendvals,5:8)
save_fig('Fig_6j')

disp('Generating Fig. 6n ...')
new_figure(1000,500)
bar_panel(panel_pos,EncodingModelOutput.pvalues.AllKernels.remove_Vchoice,[0 5],0:1:50,[5 10],['Fig. 6n',char(10),'V(S_{choice})'])
region_legend_panel(cmap,legendvals,5:8)
save_fig('Fig_6n')

disp('Generating Fig. 6o ...')
new_figure(1000,500)
box_panel(panel_pos,EncodingModelOutput.delta_r2.AllKernels.remove_Vchoice,['Fig. 6o',char(10),'V(S_{choice})'])
region_legend_panel(cmap,legendvals,5:8)
save_fig('Fig_6o')

disp('Generating Extended Data Fig. 12b ...')
new_figure(1000,500)
bar_panel(panel_pos,EncodingModelOutput.pvalues.AllKernels.remove_PIchoice,[0 25],0:5:50,[5 10],['Extended Data Fig. 12b',char(10),'\pi^{choice}'])
region_legend_panel(cmap,legendvals,5:8)
save_fig('Fig_ED12b')

disp('Generating Extended Data Fig. 12c ...')
new_figure(1000,500)
box_panel(panel_pos,EncodingModelOutput.delta_r2.AllKernels.remove_PIchoice,['Extended Data Fig. 12c',char(10),'\pi^{choice}'])
region_legend_panel(cmap,legendvals,5:8)
save_fig('Fig_ED12c')
%% Atlas visualizations (Fig. 6h, 6m, Extended Data Fig. 12a)
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
Data.name = key{Data.idx,1};
Data.name(find(cellfun(@(x) isequal(x,'Caudoputamen- intermediate, dorsomedial, dorsal tip '),Data.name))) = {'Caudoputamen- intermediate, dorsomedial, dorsal tip'};
Data.atlas = key{Data.idx,3};
Data.count = [];
Data.pvalues.remove_Vcs = cell(size(Data.name));
Data.pvalues.remove_Vchoice = cell(size(Data.name));
Data.pvalues.remove_PIchoice = cell(size(Data.name));
for i = 1:length(Data.idx)
    region_idx = find(cellfun(@(x) isequal(x,Data.name{i}),EncodingModelOutput.region_name));
    Data.count(i) = length(region_idx);
    Data.pvalues.remove_Vcs{i} = EncodingModelOutput.pvalues.AllKernels.remove_Vcs(region_idx);
    Data.pvalues.remove_Vchoice{i} = EncodingModelOutput.pvalues.AllKernels.remove_Vchoice(region_idx);
    Data.pvalues.remove_PIchoice{i} = EncodingModelOutput.pvalues.AllKernels.remove_PIchoice(region_idx);
end

planes = [28 33 38 43 48 53]+1;
brainoutline = atlas>0;
ACA = atlas==900;

pct_sig = @(pv) cellfun(@(x) sum(x<=0.01001)./numel(x)*100,pv);

% Fig. 6h (V(S_{CS+}))
cmap = cbrewer('seq','Blues',1000,'spline');

disp('Generating Fig. 6h ...')
new_figure(2000,500)
colors = metric_to_colors(pct_sig(Data.pvalues.remove_Vcs),Data.count,10,cmap);
cb = struct('Ticks',[0 .5 1],'TickLabels',{{'0','5','10'}},'Label','Significant (%)');
draw_atlas_row(planes,atlas,brainoutline,ACA,Data,colors,cmap,cb,['Fig. 6h',char(10),'V(S_{CS+})']);
save_fig('Fig_6h')

% Fig. 6m (V(S_{choice}))
cmap = cbrewer('seq','Purples',1000,'spline');

disp('Generating Fig. 6m ...')
new_figure(2000,500)
colors = metric_to_colors(pct_sig(Data.pvalues.remove_Vchoice),Data.count,10,cmap);
cb = struct('Ticks',[0 .5 1],'TickLabels',{{'0','5','10'}},'Label','Significant (%)');
draw_atlas_row(planes,atlas,brainoutline,ACA,Data,colors,cmap,cb,['Fig. 6m',char(10),'V(S_{choice})']);
save_fig('Fig_6m')

% Extended Data Fig. 12a (\pi^{choice})
cmap = cbrewer('seq','Reds',1000,'spline');

disp('Generating Extended Data Fig. 12a ...')
new_figure(2000,500)
colors = metric_to_colors(pct_sig(Data.pvalues.remove_PIchoice),Data.count,50,cmap);
cb = struct('Ticks',[0 .5 1],'TickLabels',{{'0','25','50'}},'Label','Significant (%)');
draw_atlas_row(planes,atlas,brainoutline,ACA,Data,colors,cmap,cb,['Extended Data Fig. 12a',char(10),'\pi^{choice}']);
save_fig('Fig_ED12a')
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
    plot([0 10],[1 1],'k--')
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

function region_box_panel(pos,dr2,ES,xvals,cmap,xlimits,ylimits,yticklist,ttl)
    subplot(pos(1),pos(2),pos(3:end))
    hold on
    axis square
    for i = 1:length(ES.region_key)
        vals = dr2(find(ES.region_id==i))*100;
        simpleboxplot(xvals(i),vals,cmap(i,:));
    end
    xlim(xlimits); xticks(xvals)
    ylabel('Corrected ΔR^2 (%)'); ylim(ylimits); yticks(yticklist);
    xticklabels(ES.region_key)
    xtickangle(90)
    title(ttl)
    style_axes(true)
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

function StatsTbl = add_ranksum_rows(StatsTbl,panel,rk,rid,dr2,pairs)
    for k = 1:size(pairs,1)
        a = pairs(k,1);
        b = pairs(k,2);
        [p,Z] = ranksum_z(dr2(rid==a),dr2(rid==b));
        StatsTbl(end+1,:) = stats_row(panel,[rk{a},' vs. ',rk{b}],'Mann–Whitney U test (normal approximation)',[sum(rid==a) sum(rid==b)],Z,p);
    end
end

function StatsTbl = add_binomial_rows(StatsTbl,panel,rk,regions,N,k,p0)
    for r = 1:numel(regions)
        p_one = 1 - binocdf(k(r)-1,N(r),p0);
        StatsTbl(end+1,:) = stats_row(panel,[rk{regions(r)},': V(S_{choice}) vs. 1% chance'],'Exact binomial test (one-sided)',N(r),k(r),p_one);
    end
end

function StatsTbl = add_mh_row(StatsTbl,panel,group,N,SigCS,SigCh,Both)
    b = SigCS - Both;
    c = SigCh - Both;
    chi2_MH = (sum(b - c))^2 / sum(b + c);
    p_MH = chi2cdf(chi2_MH,1,'upper');
    StatsTbl(end+1,:) = stats_row(panel,group,'Mantel–Haenszel χ2 test',N,chi2_MH,p_MH);
end