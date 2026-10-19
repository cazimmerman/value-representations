function [pInterp,tInterp,onsets,offsets] = FindMovements(pRaw,tRaw,testdata)

%% set movement detection parameters
tThreshCoarse       = 0.200;	% time window for calculating average wheel speed (sec) [coarse detection]      default: 0.200 (200 msec)
sThreshCoarse       = 1.000;	% average wheel speed threshold (cm/sec) [coarse detection]                     default: 1.000 (10 mm/sec)
tMinMove            = 0.050;	% minimum duration of movements (sec)                                           default: 0.050 (50 msec)
tMinGap             = 0.100;	% minimum time between movements (sec)                                          default: 0.100 (100 msec)
tThreshFine         = 0.005;	% time window for calculating instantaneous wheel speed (sec) [fine detection]	default: 0.005 (5 msec)
sThreshFine         = 0.200;	% instantaneous wheel speed threshold (cm/sec) [fine detection]                 default: 0.200 (2 mm/sec)
%% resample position and time arrays
Fs                  = 1000; % sampling rate (Hz)
tInterp             = tRaw(1):1/Fs:tRaw(end);
pInterp             = interp1(tRaw,pRaw,tInterp);
%% coarse movement detection
wheelRadius         = 6.2/2; % wheel radius (cm)
sThreshCoarse       = sThreshCoarse/wheelRadius; % convert threshold to rad/sec
speedCoarse         = movmean(abs(diff(pInterp))./(1/Fs),[tThreshCoarse*Fs 0]);
speedCoarse(1:Fs)   = zeros; speedCoarse(end-Fs+1:end) = zeros;
onsets              = tInterp(find(diff(speedCoarse>=sThreshCoarse)==1)+1);
offsets             = tInterp(find(diff(speedCoarse>=sThreshCoarse)==-1)+1);
%% refine movement onset times
sThreshFine         = sThreshFine/wheelRadius; % convert threshold to rad/sec
speedFine           = movmean(abs(diff(pInterp))./(1/Fs),tThreshFine*Fs);
for i = 1:length(onsets)
    if i == 1
        try
            idx1    = find(tInterp==onsets(i)-tThreshCoarse)-1;
        catch
            idx1    = 1;
        end
    else
        idx1        = find(tInterp==max([offsets(i-1),onsets(i)-tThreshCoarse]))-1;
    end
    idx2            = find(tInterp==onsets(i))-1;
    onsetsFine      = tInterp(find(diff(speedFine>=max([sThreshFine,min(speedFine(idx1:idx2))]))==1)+1);
    onsets(i)       = onsetsFine(find(onsetsFine<=onsets(i),1,'last'));
end
%% merge too-close movements
merge               = (onsets(2:end)-offsets(1:end-1))<tMinGap;
onsets              = onsets([true ~merge]);
offsets             = offsets([~merge true]);
%% remove too-short movements
remove              = (offsets-onsets)<tMinMove;
onsets              = onsets(~remove);
offsets             = offsets(~remove);
%% diagnostic plots
if nargin == 3
    figure
    hold on
    a = plot([tInterp(2) tInterp(end)],[sThreshCoarse sThreshCoarse],'r','linewidth',2);
    plot([tInterp(2) tInterp(end)],[sThreshFine sThreshFine],'r--','linewidth',2);
    for i = 1:length(onsets)
        b = fill([onsets(i) offsets(i) offsets(i) onsets(i)],[-2 -2 2 2],'r','FaceAlpha',0.25,'LineStyle','none');
    end
    c = plot(tInterp(2:end),speedCoarse,'k-','linewidth',2);
    plot(tInterp(2:end),speedFine,'k--','linewidth',2)
    for i = 1:length(testdata.times.gocue)
        d = plot([testdata.times.gocue(i) testdata.times.outcome(i)],[0.5 0.5],'k','LineWidth',16);
    end
    legend([a,b,c,d],{'Movement threshold','Movements','Wheel speed','Trials'},'location','NorthWest')
    xlabel('Time (sec)')
    ylabel('Wheel speed (rad/sec)')
    xlim([300 320])
    ylim([0 0.75])
    set(gca,'FontSize',20)
    hold off
end