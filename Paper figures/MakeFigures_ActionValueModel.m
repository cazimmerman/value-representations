%% Setup
clearvars; close all; clc;
addpath(genpath('utils'));

warning('off','all')
data_dir = uigetdir([],'Select folder with mat files');
load([data_dir,'\ActionValueModel.mat'])
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

for f = {'remove_AllValues','remove_ContraValue','remove_IpsiValue'}
    EncodingModelOutput.delta_r2.AllKernels.(f{1}) = EncodingModelOutput.delta_r2.AllKernels.(f{1}) ...
                                               - EncodingModelOutput.delta_r2.AllKernels.([f{1},'_null']);
end

% NOTE: "Contra" and "Ipsi" labels are flipped in the .mat file when
%       compared to the figure captions and manuscript text. The figures
%       and manuscript text are correct (see Methods section for details).
%% Statistics for Fig. 2g, 2h, Extended Data Fig. 4a

rk = EncodingModelOutput.region_key;
rid = EncodingModelOutput.region_id;
pairs_striatum = [7 5; 7 6; 7 8; 5 6; 5 8];
pairs_cortex = [7 1; 7 2; 7 3; 7 4];
pairs_pallidum = [7 9; 7 10];

StatsTbl = add_chi2_rows(StatsTbl,'2g',rk,rid,EncodingModelOutput.pvalues.AllKernels.remove_AllValues,pairs_striatum,cutoff);
StatsTbl = add_chi2_rows(StatsTbl,'2h',rk,rid,EncodingModelOutput.pvalues.AllKernels.remove_AllValues,pairs_cortex,cutoff);
StatsTbl = add_chi2_rows(StatsTbl,'2h',rk,rid,EncodingModelOutput.pvalues.AllKernels.remove_AllValues,pairs_pallidum,cutoff);
StatsTbl = add_ranksum_rows(StatsTbl,'ED4a',rk,rid,EncodingModelOutput.delta_r2.AllKernels.remove_AllValues,[7 8]);
%% Extended Data Fig. 3f

c = 1:length(EncodingModelOutput.region_key);
cmap = region_cmap();
xvals = [1,2,3,4,6,7,8,9,11,12];
legendvals = region_legend_labels(EncodingModelOutput,c);

disp('Generating Extended Data Fig. 3f ...')
new_figure(1000,500)
region_box_panel(panel_pos,EncodingModelOutput.fit.r2,100,EncodingModelOutput,xvals,cmap,[0 13],[0 30],0:5:30,'R^2 (%)',['Extended Data Fig. 3f',char(10),'Model Performance'])
region_legend_panel(cmap,legendvals,1:10)
save_fig('Fig_ED3f')
%% Fig. 2g, 2h, Extended Data Fig. 4a

c = 1:length(EncodingModelOutput.region_key);
cmap = region_cmap();
xvals = [1,2,3,4,6,7,8,9,11,12];
legendvals = region_legend_labels(EncodingModelOutput,c);

disp('Generating Fig. 2g/h ...')
new_figure(1000,500)
region_bar_panel(panel_pos,EncodingModelOutput.pvalues.AllKernels.remove_AllValues,EncodingModelOutput,cutoff,xvals,cmap,[0 30],0:5:50,[0 13],['Fig. 2g/h',char(10),'Action Value'])
region_legend_panel(cmap,legendvals,1:10)
save_fig('Fig_2g_Fig_2h')

disp('Generating Extended Data Fig. 4a ...')
new_figure(1000,500)
region_box_panel(panel_pos,EncodingModelOutput.delta_r2.AllKernels.remove_AllValues,100,EncodingModelOutput,xvals,cmap,[0 13],[-.05 .25],-.1:.05:.3,'Corrected ΔR^2 (%)',['Extended Data Fig. 4a',char(10),'Action Value'])
region_legend_panel(cmap,legendvals,1:10)
save_fig('Fig_ED4a')
%% Fig. 4c, 4d, 4e, 4f, Extended Data Fig. 8a, 8b, 8c, 8d

c = 1:length(EncodingModelOutput.region_key);
cmap = region_cmap();
legendvals = region_legend_labels(EncodingModelOutput,c);
alphas = EncodingModelOutput.learning_rate.alpha_reward.R2.alphas;
gammas = EncodingModelOutput.learning_rate.gamma_forget.R2.gammas;

disp('Generating Fig. 4c ...')
new_figure(1000,500)
pl = curve_stats(EncodingModelOutput,'alpha_reward','remove_ContraValue',c,'corrected');
curve_panel(panel_pos,alphas,pl,cmap,'α_{reward}','Corrected ΔR^2 (%)',['Fig. 4c',char(10),'Q^{contra}'])
region_legend_panel(cmap,legendvals,5:8)
save_fig('Fig_4c')

disp('Generating Extended Data Fig. 8a (top) ...')
new_figure(1000,500)
pl = curve_stats(EncodingModelOutput,'alpha_reward','remove_ContraValue',c,'real');
curve_panel(panel_pos,alphas,pl,cmap,'α_{reward}','Real ΔR^2 (%)',['Extended Data Fig. 8a, top',char(10),'Q^{contra}'])
region_legend_panel(cmap,legendvals,5:8)
save_fig('Fig_ED8a_top')

disp('Generating Extended Data Fig. 8a (bottom) ...')
new_figure(1000,500)
pl = curve_stats(EncodingModelOutput,'alpha_reward','remove_ContraValue',c,'null');
curve_panel(panel_pos,alphas,pl,cmap,'α_{reward}','Null ΔR^2 (%)',['Extended Data Fig. 8a, bottom',char(10),'Q^{contra}'])
region_legend_panel(cmap,legendvals,5:8)
save_fig('Fig_ED8a_bottom')

disp('Generating Fig. 4d ...')
new_figure(1000,500)
pl = curve_stats(EncodingModelOutput,'alpha_reward','remove_IpsiValue',c,'corrected');
curve_panel(panel_pos,alphas,pl,cmap,'α_{reward}','Corrected ΔR^2 (%)',['Fig. 4d',char(10),'Q^{ipsi}'])
region_legend_panel(cmap,legendvals,5:8)
save_fig('Fig_4d')

disp('Generating Extended Data Fig. 8b (top) ...')
new_figure(1000,500)
pl = curve_stats(EncodingModelOutput,'alpha_reward','remove_IpsiValue',c,'real');
curve_panel(panel_pos,alphas,pl,cmap,'α_{reward}','Real ΔR^2 (%)',['Extended Data Fig. 8b, top',char(10),'Q^{ipsi}'])
region_legend_panel(cmap,legendvals,5:8)
save_fig('Fig_ED8b_top')

disp('Generating Extended Data Fig. 8b (bottom) ...')
new_figure(1000,500)
pl = curve_stats(EncodingModelOutput,'alpha_reward','remove_IpsiValue',c,'null');
curve_panel(panel_pos,alphas,pl,cmap,'α_{reward}','Null ΔR^2 (%)',['Extended Data Fig. 8b, bottom',char(10),'Q^{ipsi}'])
region_legend_panel(cmap,legendvals,5:8)
save_fig('Fig_ED8b_bottom')

disp('Generating Fig. 4e ...')
new_figure(1000,500)
pl = curve_stats(EncodingModelOutput,'gamma_forget','remove_ContraValue',c,'corrected');
curve_panel(panel_pos,gammas,pl,cmap,'γ_{forget}','Corrected ΔR^2 (%)',['Fig. 4e',char(10),'Q^{contra}'])
region_legend_panel(cmap,legendvals,5:8)
save_fig('Fig_4e')

disp('Generating Extended Data Fig. 8c (top) ...')
new_figure(1000,500)
pl = curve_stats(EncodingModelOutput,'gamma_forget','remove_ContraValue',c,'real');
curve_panel(panel_pos,gammas,pl,cmap,'γ_{forget}','Real ΔR^2 (%)',['Extended Data Fig. 8c, top',char(10),'Q^{contra}'])
region_legend_panel(cmap,legendvals,5:8)
save_fig('Fig_ED8c_top')

disp('Generating Extended Data Fig. 8c (bottom) ...')
new_figure(1000,500)
pl = curve_stats(EncodingModelOutput,'gamma_forget','remove_ContraValue',c,'null');
curve_panel(panel_pos,gammas,pl,cmap,'γ_{forget}','Null ΔR^2 (%)',['Extended Data Fig. 8c, bottom',char(10),'Q^{contra}'])
region_legend_panel(cmap,legendvals,5:8)
save_fig('Fig_ED8c_bottom')

disp('Generating Fig. 4f ...')
new_figure(1000,500)
pl = curve_stats(EncodingModelOutput,'gamma_forget','remove_IpsiValue',c,'corrected');
curve_panel(panel_pos,gammas,pl,cmap,'γ_{forget}','Corrected ΔR^2 (%)',['Fig. 4f',char(10),'Q^{ipsi}'])
region_legend_panel(cmap,legendvals,5:8)
save_fig('Fig_4f')

disp('Generating Extended Data Fig. 8d (top) ...')
new_figure(1000,500)
pl = curve_stats(EncodingModelOutput,'gamma_forget','remove_IpsiValue',c,'real');
curve_panel(panel_pos,gammas,pl,cmap,'γ_{forget}','Real ΔR^2 (%)',['Extended Data Fig. 8d, top',char(10),'Q^{ipsi}'])
region_legend_panel(cmap,legendvals,5:8)
save_fig('Fig_ED8d_top')

disp('Generating Extended Data Fig. 8d (bottom) ...')
new_figure(1000,500)
pl = curve_stats(EncodingModelOutput,'gamma_forget','remove_IpsiValue',c,'null');
curve_panel(panel_pos,gammas,pl,cmap,'γ_{forget}','Null ΔR^2 (%)',['Extended Data Fig. 8d, bottom',char(10),'Q^{ipsi}'])
region_legend_panel(cmap,legendvals,5:8)
save_fig('Fig_ED8d_bottom')
%% Atlas visualizations (Fig. 2f, Extended Data Fig. 4d, 4e)
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
Data.pvalues.remove_AllValues = cell(size(Data.name));
Data.pvalues.remove_ContraValue = cell(size(Data.name));
Data.pvalues.remove_IpsiValue = cell(size(Data.name));
for i = 1:length(Data.idx)
    region_idx = find(cellfun(@(x) isequal(x,Data.name{i}),EncodingModelOutput.region_name));
    Data.count(i) = length(region_idx);
    Data.pvalues.remove_AllValues{i} = EncodingModelOutput.pvalues.AllKernels.remove_AllValues(region_idx);
    Data.pvalues.remove_ContraValue{i} = EncodingModelOutput.pvalues.AllKernels.remove_ContraValue(region_idx);
    Data.pvalues.remove_IpsiValue{i} = EncodingModelOutput.pvalues.AllKernels.remove_IpsiValue(region_idx);
end

planes = [28 33 38 43 48 53]+1;
brainoutline = atlas>0;
ACA = atlas==900;

pct_sig = @(pv) cellfun(@(x) sum(x<=0.01001)./numel(x)*100,pv);
cb_pct = struct('Ticks',[0 .5 1],'TickLabels',{{'0','25','50'}},'Label','Significant (%)');

% Fig. 2f (Action Value)
cmap = cbrewer('seq','Purples',1000,'spline');
disp('Generating Fig. 2f ...')
new_figure(2000,500)
colors = metric_to_colors(pct_sig(Data.pvalues.remove_AllValues),Data.count,50,cmap);
draw_atlas_row(planes,atlas,brainoutline,ACA,Data,colors,cmap,cb_pct,['Fig. 2f',char(10),'Action Value']);
save_fig('Fig_2f')

% Extended Data Fig. 4e (Q^{contra})
cmap = cbrewer('seq','Blues',1000,'spline');
disp('Generating Extended Data Fig. 4d ...')
new_figure(2000,500)
colors = metric_to_colors(pct_sig(Data.pvalues.remove_IpsiValue),Data.count,50,cmap);
draw_atlas_row(planes,atlas,brainoutline,ACA,Data,colors,cmap,cb_pct,['Extended Data Fig. 4d',char(10),'Q^{contra}']);
save_fig('Fig_ED4d')

% Extended Data Fig. 4d (Q^{ipsi})
cmap = cbrewer('seq','Reds',1000,'spline');
disp('Generating Extended Data Fig. 4e ...')
new_figure(2000,500)
colors = metric_to_colors(pct_sig(Data.pvalues.remove_ContraValue),Data.count,50,cmap);
draw_atlas_row(planes,atlas,brainoutline,ACA,Data,colors,cmap,cb_pct,['Extended Data Fig. 4e',char(10),'Q^{ipsi}']);
save_fig('Fig_ED4e')
%% Extended Data Fig. 4b

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

disp('Generating Extended Data Fig. 4b (top) ...')
new_figure(1000,500)
subcompartment_box_panel(panel_pos,EncodingModelOutput.delta_r2.AllKernels.remove_IpsiValue,in_region,c,Data,xvals,cmap,abbrevs,[-.1 .3],-.1:.1:.3,['Extended Data Fig. 4b, top',char(10),'Q^{contra}'])
subcompartment_legend(cmap,Data,c,ddd,legendvals)
save_fig('Fig_ED4b_top')

disp('Generating Extended Data Fig. 4b (bottom) ...')
new_figure(1000,500)
subcompartment_box_panel(panel_pos,EncodingModelOutput.delta_r2.AllKernels.remove_ContraValue,in_region,c,Data,xvals,cmap,abbrevs,[-.1 .3],-.1:.1:.3,['Extended Data Fig. 4b, bottom',char(10),'Q^{ipsi}'])
subcompartment_legend(cmap,Data,c,ddd,legendvals)
save_fig('Fig_ED4b_bottom')
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

function region_box_panel(pos,vals_all,scale,ES,xvals,cmap,xlimits,ylimits,yticklist,ylab,ttl)
    subplot(pos(1),pos(2),pos(3:end))
    hold on
    axis square
    for i = 1:length(ES.region_key)
        vals = vals_all(find(ES.region_id==i))*scale;
        simpleboxplot(xvals(i),vals,cmap(i,:));
    end
    xlim(xlimits); xticks(xvals)
    ylabel(ylab); ylim(ylimits); yticks(yticklist);
    xticklabels(ES.region_key)
    xtickangle(90)
    title(ttl)
    style_axes(true)
    hold off
end

function subcompartment_box_panel(pos,dr2,in_region,c,Data,xvals,cmap,abbrevs,ylimits,yticklist,ttl)
    subplot(pos(1),pos(2),pos(3:end));
    hold on
    axis square
    for i = 1:length(c)
        vals = dr2(in_region(i))*100;
        if length(vals)>=5
            simpleboxplot(xvals(i),vals,cmap(Data.group(c(i)),:));
        end
    end
    xlim([0 xvals(end)+1]); xticks(xvals)
    ylabel('Corrected ΔR^2 (%)'); ylim(ylimits); yticks(yticklist);
    xticklabels(abbrevs)
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