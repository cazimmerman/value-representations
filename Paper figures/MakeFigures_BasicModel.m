%% Setup
clearvars; close all; clc;
addpath(genpath('utils'));

warning('off','all')
data_dir = uigetdir([],'Select folder with mat files');
load([data_dir,'\BasicModel.mat'])
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

% NOTE: "Contra" and "Ipsi" labels are flipped in the .mat file when
%       compared to the figure captions and manuscript text. The figures
%       and manuscript text are correct (see Methods section for details).
%% Statistics for Fig. 2i, Extended Data Fig. 3e

rk = EncodingModelOutput.region_key;
rid = EncodingModelOutput.region_id;
pairs_action_identity = [7 3; 3 1; 3 2; 3 4; 7 9; 7 10];

StatsTbl = add_chi2_rows(StatsTbl,'2i',rk,rid,EncodingModelOutput.pvalues.movement_ID,pairs_action_identity,cutoff);
StatsTbl = add_ranksum_rows(StatsTbl,'ED3e',rk,rid,EncodingModelOutput.firing_rate,[7 5]);
%% Extended Data Fig. 3d, 3e

c = 1:length(EncodingModelOutput.region_key);
cmap = region_cmap();
xvals = [1,2,3,4,6,7,8,9,11,12];
legendvals = region_legend_labels(EncodingModelOutput,c);

disp('Generating Extended Data Fig. 3d ...')
new_figure(1000,500)
yield_panel(panel_pos,EncodingModelOutput,xvals,cmap,['Extended Data Fig. 3d',char(10),'Yield'])
region_legend_panel(cmap,legendvals,1:10)
save_fig('Fig_ED3d')

disp('Generating Extended Data Fig. 3e ...')
new_figure(1000,500)
region_box_panel(panel_pos,EncodingModelOutput.firing_rate,1,EncodingModelOutput,xvals,cmap,[0 13],[0 70],0:10:70,'Firing rate (sp/s)',['Extended Data Fig. 3e',char(10),'Firing Rates'])
region_legend_panel(cmap,legendvals,1:10)
save_fig('Fig_ED3e')
%% Fig. 2i, Extended Data Fig. 3g, 3h, 3i, 3j, 3k

c = 1:length(EncodingModelOutput.region_key);
cmap = region_cmap();
xvals = [1,2,3,4,6,7,8,9,11,12];
legendvals = region_legend_labels(EncodingModelOutput,c);
bar_panel = @(pos,pvals,ylimits,yticklist,xlimits,ttl) region_bar_panel(pos,pvals,EncodingModelOutput,cutoff,xvals,cmap,ylimits,yticklist,xlimits,ttl);

disp('Generating Extended Data Fig. 3g ...')
new_figure(1000,500)
bar_panel(panel_pos,EncodingModelOutput.pvalues.cue,[0 100],0:25:100,[0 13],['Extended Data Fig. 3g',char(10),'Go Cue'])
region_legend_panel(cmap,legendvals,1:10)
save_fig('Fig_ED3g')

disp('Generating Extended Data Fig. 3h ...')
new_figure(1000,500)
bar_panel(panel_pos,EncodingModelOutput.pvalues.movement,[0 100],0:25:100,[0 13],['Extended Data Fig. 3h',char(10),'Movement'])
region_legend_panel(cmap,legendvals,1:10)
save_fig('Fig_ED3h')

disp('Generating Extended Data Fig. 3i ...')
new_figure(1000,500)
bar_panel(panel_pos,EncodingModelOutput.pvalues.outcome,[0 100],0:25:100,[0 13],['Extended Data Fig. 3i',char(10),'Outcome'])
region_legend_panel(cmap,legendvals,1:10)
save_fig('Fig_ED3i')

disp('Generating Fig. 2i/Extended Data Fig. 3j ...')
new_figure(1000,500)
bar_panel(panel_pos,EncodingModelOutput.pvalues.movement_ID,[0 100],0:25:100,[0 13],['Fig. 2i/Extended Data Fig. 3j',char(10),'Action-Selective'])
region_legend_panel(cmap,legendvals,1:10)
save_fig('Fig_2i_Fig_ED3j')

disp('Generating Extended Data Fig. 3k ...')
new_figure(1000,500)
bar_panel(panel_pos,EncodingModelOutput.pvalues.outcome_ID,[0 100],0:25:100,[0 13],['Extended Data Fig. 3k',char(10),'Outcome-Selective'])
region_legend_panel(cmap,legendvals,1:10)
save_fig('Fig_ED3k')
%% Atlas visualizations (Fig. 2e, Extended Data Fig. 3c)
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
Data.atlas = key{Data.idx,3};
Data.count = [];
for i = 1:length(Data.idx)
    Data.count(i) = sum(cellfun(@(x) isequal(x,Data.name{i}),EncodingModelOutput.region_name));
end

planes = [28 33 38 43 48 53]+1;
brainoutline = atlas>0;
ACA = atlas==900;

cmap = cbrewer('seq','Purples',1000,'spline'); cmap(cmap<0) = 0;
cmap2 = [[86 138 66]/255;...
    [255 120 0]/255;...
    [242 166 29]/255;...
    [211 215 38]/255];

disp('Generating Fig. 2e ...')
new_figure(2000,500)
colors = repmat([.5 .5 .5],numel(Data.count),1);
for i = find(Data.viz)
    colors(i,:) = cmap2(Data.group(i),:);
end
cb = struct('Ticks',.125:.25:.875,'TickLabels',{{'DS-Cau','DS-Int','DS-Ros','NAc'}},'Label','');
draw_atlas_row(planes,atlas,brainoutline,ACA,Data,colors,flipud(cmap2),cb,['Fig. 2e',char(10),'Striatal Subregions and Domains']);
save_fig('Fig_2e')

disp('Generating Extended Data Fig. 3c ...')
new_figure(2000,500)
colors = metric_to_colors(log10(Data.count)-1,Data.count,2,cmap);
cb = struct('Ticks',[0 .5 1],'TickLabels',{{'10','100','1000'}},'Label','Neurons');
draw_atlas_row(planes,atlas,brainoutline,ACA,Data,colors,cmap,cb,['Extended Data Fig. 3c',char(10),'Striatal Coverage from Recordings']);
save_fig('Fig_ED3c')
%% Heatmaps (Fig. 5a, 5b, Extended Data Fig. 3b)

heatmap_fig = 'Heatmaps';

vals = region_full_names();
cmap = flipud(cbrewer('div','RdBu',1000,'spline'));
cmap(cmap<0) = 0;

fields6 = {'cue','movement_contra','movement_ipsi','CS_plus','VTA_stim','CS_minus'};
fields5 = {'cue','movement_contra','movement_ipsi','CS_plus','CS_minus'};
labels6 = {'Go Cue','Choice/Ipsi','Choice/Contra','CS+','Laser','CS–'};
labels5 = {'Go Cue','Choice/Ipsi','Choice/Contra','CS+','CS–'};
ticks6  = [51 152+60 253+120 404+180 605+240 806+300];
lines6  = [1 152+60 253+120 304+180 505+240 706+300];
ticks5  = [51 152+45 253+90 404+135 605+180];
lines5  = [1 152+45 253+90 304+135 505+180];
bounds6 = [201*2+101*3+60*4, 201+101*3+60*3, 101*3+60*2, 101*2+60, 101];
bounds5 = [201+101*3+60*3, 101*3+60*2, 101*2+60, 101];

for k = [5:8,12]
    
    if k == 12
        NEURONS_INCLUDE_REGION = find(ismember(EncodingModelOutput.region_id,6:8));
    else
        NEURONS_INCLUDE_REGION = find(EncodingModelOutput.region_id == k);
    end
    gap_rows = round(length(NEURONS_INCLUDE_REGION)*.02);
    
    bigmap = concat_blocks({ ...
        EncodingModelOutput.PSTHs.kernels.cue(NEURONS_INCLUDE_REGION,:).*EncodingModelOutput.PSTHs.gains.cue(NEURONS_INCLUDE_REGION,1), ...
        EncodingModelOutput.PSTHs.kernels.movement_contra(NEURONS_INCLUDE_REGION,:).*EncodingModelOutput.PSTHs.gains.movement_contra(NEURONS_INCLUDE_REGION,1), ...
        EncodingModelOutput.PSTHs.kernels.movement_ipsi(NEURONS_INCLUDE_REGION,:).*EncodingModelOutput.PSTHs.gains.movement_ipsi(NEURONS_INCLUDE_REGION,1), ...
        EncodingModelOutput.PSTHs.kernels.CS_plus(NEURONS_INCLUDE_REGION,:).*EncodingModelOutput.PSTHs.gains.CS_plus(NEURONS_INCLUDE_REGION,1), ...
        EncodingModelOutput.PSTHs.kernels.VTA_stim(NEURONS_INCLUDE_REGION,:).*EncodingModelOutput.PSTHs.gains.VTA_stim(NEURONS_INCLUDE_REGION,1), ...
        EncodingModelOutput.PSTHs.kernels.CS_minus(NEURONS_INCLUDE_REGION,:).*EncodingModelOutput.PSTHs.gains.CS_minus(NEURONS_INCLUDE_REGION,1)},60);
    
    [~,i] = max(bigmap');
    [ii,i] = sort(i);
    
    bigmap  = flipud(sort_with_gaps(bigmap,i,ii,gap_rows,bounds6));
    bigmap3 = flipud(sort_with_gaps(psth_map(EncodingModelOutput.PSTHs.all_trials,NEURONS_INCLUDE_REGION,fields6,60),i,ii,gap_rows,bounds6));
    bigmap4 = flipud(sort_with_gaps(psth_map(EncodingModelOutput.PSTHs.all_trials_predictions,NEURONS_INCLUDE_REGION,fields6,60),i,ii,gap_rows,bounds6));
    
    bigmap5 = psth_map(EncodingModelOutput.PSTHs.even_trials,NEURONS_INCLUDE_REGION,fields5,45);
    bigmap6 = psth_map(EncodingModelOutput.PSTHs.odd_trials,NEURONS_INCLUDE_REGION,fields5,45);
    bigmap7 = psth_map(EncodingModelOutput.PSTHs.even_trials_predictions,NEURONS_INCLUDE_REGION,fields5,45);
    [~,i] = max(bigmap6');
    [ii6,i6] = sort(i);
    bigmap5 = flipud(sort_with_gaps(bigmap5,i6,ii6,gap_rows,bounds5));
    bigmap7 = flipud(sort_with_gaps(bigmap7,i6,ii6,gap_rows,bounds5));
    
    if k == 12
        region_label = 'CP';
    else
        region_label = EncodingModelOutput.region_key{k};
    end
    disp(['Generating ',region_label,' Heatmaps ...'])
    figure('Position', get(0, 'Screensize'))
    nneurons = length(NEURONS_INCLUDE_REGION);
    
    ax3 = subplot(2,3,3);
    heatmap_panel(bigmap,cmap,0.25,ticks6,labels6,lines6,nneurons,'Encoding Model Kernels');
    
    ax1 = subplot(2,3,1);
    heatmap_panel(bigmap3,cmap,.5,ticks6,labels6,lines6,nneurons,'Real Firing (Sorted by Kernels) - All Trials');
    
    ax2 = subplot(2,3,2);
    heatmap_panel(bigmap4,cmap,.5,ticks6,labels6,lines6,nneurons,'Model Predictions (Sorted by Kernels) - All Trials');
    
    ax4 = subplot(2,3,4);
    heatmap_panel(bigmap5,cmap,.5,ticks5,labels5,lines5,nneurons,'Real Firing (Sorted by Odd Trials) - Even Trials');
    
    ax5 = subplot(2,3,5);
    heatmap_panel(bigmap7,cmap,.5,ticks5,labels5,lines5,nneurons,'Model Predictions (Sorted by Odd Trials) - Even Trials');
    
    if k == 12
        sgtitle('CP')
    else
        sgtitle(vals{k})
    end
    linkaxes([ax1 ax2 ax3],'xy')
    linkaxes([ax4 ax5],'xy')
    save_fig([heatmap_fig,'_',region_label])
end
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

function yield_panel(pos,ES,xvals,cmap,ttl)
    edges = 0.5:1:(length(ES.region_key)-.5);
    x = hist(ES.region_id,edges);
    y = hist(ES.pvalues.not_task_modulated.region_id,edges);
    subplot(pos(1),pos(2),pos(3:end))
    hold on
    axis square
    b = bar(xvals,[x;y],'stacked','FaceColor','flat','LineStyle','none');
    b(1).CData = cmap;
    b(2).CData = cmap; b(2).FaceAlpha = 0.25;
    ylim([0 2000]); yticks(0:500:2000)
    ylabel('Neurons')
    xlim([0 13])
    xticks(xvals)
    xticklabels(ES.region_key)
    xtickangle(90)
    style_axes(true)
    legend({'Task-modulated','Not task-modulated'},'box','off','location','northwest')
    title(ttl)
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

function M = concat_blocks(blocks,gap)
    M = blocks{1};
    for b = 2:numel(blocks)
        M = [M, nan(size(M,1),gap), blocks{b}]; %#ok<AGROW>
    end
end

function M = psth_map(P,idx,fields,gap)
    blocks = cellfun(@(f) P.(f)(idx,:),fields,'UniformOutput',false);
    M = concat_blocks(blocks,gap);
end

function M = sort_with_gaps(M,order,ii,gap_rows,bounds)
    M = M(order',:);
    for b = bounds
        n = find(ii>b,1,'first');
        M = [M(1:n-1,:);nan(gap_rows,size(M,2));M(n:end,:)];
    end
end

function heatmap_panel(M,cmap,climit,xtick_pos,xtick_labels,line_pos,nneurons,ttl)
    hold on
    axis square
    heatmap(M,[],[],[],'Colormap',cmap,'ColorLevels',1000,'MaxColorValue',climit,'MinColorValue',-climit,'NaNColor',[1 1 1]);
    xticks(xtick_pos)
    xticklabels(xtick_labels)
    xtickangle(45)
    ylabel([num2str(nneurons),' neurons'])
    for x = line_pos
        plot([x x],[0 size(M,1)]+0.5,'k','LineWidth',1)
    end
    title(ttl)
    h = colorbar('Ticks',[-climit 0 climit],'Box',1);
    set(h,'FontSize',10,'LineWidth',1,'TickLength',0.025,'TickDir','out')
    set(gca,'FontSize',10)
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