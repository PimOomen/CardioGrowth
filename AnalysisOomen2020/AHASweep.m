
% Script to plot results of a pacing growth sweep, first run
% AHASegmentsGrowth to run all growth pacing sweeps. Used for Figs. 6 and 8
% in Oomen 2020

% Last updated Pim Oomen 2020/11/12

clear all; close all

wDir = '';
wkspDir = '';

sweepNames = {''
              '_LADscar'
              '_LADscar_Basal'
              '_LCXscar'
              '_LCXscar_Basal'
              '_RCAscar'
              '_RCAscar_Basal'
             };
         
tPath = 'CRT011_PaceAHA';

addpath(genpath('functionsUtil'))

cLim = [-15 5];
lWidth = 3;
mSize = 10;
fSize = 18;

%%

for iWksp = 1:7

    %%
    sweepName = sweepNames{iWksp};

    load(fullfile(wkspDir, ['AHAGrowthSweep' sweepName]));

    paceCase(iWksp).aha = aha;
    paceCase(iWksp).dEDV = zeros(16,1);
    paceCase(iWksp).dLatMass = zeros(16,1);
    paceCase(iWksp).QRSdPre = zeros(16,1);
    paceCase(iWksp).QRSdPost = zeros(16,1);
    for iAHA = 1:16
        % Growth results
        paceCase(iWksp).dEDV(iAHA) = aha(iAHA).EDVEst(end);
        paceCase(iWksp).dLatMass(iAHA) = aha(iAHA).LatWallMassEst(end);
        
        % Electrical model
        load(['CRT011_PaceAHA' sweepName '/tActivationsegment' num2str(iAHA)])
        QRSdPre(iAHA) = QRSdLBBB;
        QRSdPost(iAHA) = QRSdCRT;
        
    end

    paceCase(iWksp).dQRS = QRSdPost - QRSdPre;
        
end
                            

    
%% Plot results

load('c16segs');
cSweep = c16segs;
t = linspace(8,16,size(aha(iAHA).EDVEst,1));


%%
for iWksp = 1:7
    
    sweepName = sweepNames{iWksp};

    hFig = figure('Position', [100 100 1600 820], 'Visible', 'Off');


    hs(1) = subplot(1,2,1); hold on
    for iAHA = 1:16
        plot(t, paceCase(iWksp).aha(iAHA).EDVEst, 'Color', cSweep(iAHA,:), 'LineWidth', lWidth)
    end
    xlabel('Time (weeks)')
    xticks([8 12 16])
    ylim(cLim)
    xlim([7.5 16.5])
    ylabel('EDV change (%)') 
    axis square

    hs(2) = subplot(1,2,2); hold on
    for iAHA = 1:16
        plot(t, paceCase(iWksp).aha(iAHA).LatWallMassEst, 'Color', cSweep(iAHA,:), 'LineWidth', lWidth)
    end
    xlabel('Time (weeks)')
    xticks([8 12 16])
    ylim([-30 10])
    xlim([7.5 16.5])
    yticks([-30:10:10])
    ylabel('Lat wall mass change (%)') 
    axis square

    set(hs, 'LineWidth', lWidth, 'FontSize', fSize)
    fixPaperSize
    print(hFig, '-dpdf', fullfile(wDir, [sweepName '_EDVMass']))
    close(hFig)
                            
end


%% Plot QRS duration vs. dEDV and dESV

cL = lines;
titles = {'Non-ischemic', 'LCX Basal', 'LCX Midwall', 'LAD Midwall', 'LAD Midwall', 'RCA Midwall', 'RCA Midwall'};
order = [1 2 6 3 7 4 8];    
dQRSLim = [-60 0];

hFig = figure('Position', [100 100 1800 840], 'Visible', 'Off');

for iWksp = 1:7
    hs = subplot(2,4,order(iWksp)); hold on
    title(titles{iWksp})
    % Best long-term result
    [~,iBest] = min(paceCase(iWksp).dEDV);
    [~,iFast] = min(paceCase(iWksp).dQRS);
    iRest = 1:16; iRest([iBest iFast]) = [];
%     plot(paceCase(iWksp).dQRS, paceCase(iWksp).dEDV, '.', 'LineWidth', lWidth, 'MarkerSize', 40, 'Color', 'k')
    plot(paceCase(iWksp).dQRS(iRest), paceCase(iWksp).dEDV(iRest), '.', 'LineWidth', lWidth, 'MarkerSize', 35, 'Color', 'k')
    plot(paceCase(iWksp).dQRS(iBest), paceCase(iWksp).dEDV(iBest), '+', 'LineWidth', lWidth, 'MarkerSize', 20, 'Color', 'k')
    plot(paceCase(iWksp).dQRS(iFast), paceCase(iWksp).dEDV(iFast), 'x', 'LineWidth', lWidth, 'MarkerSize', 20, 'Color', 'k')

%     % Linear regression
%     mdl = fitlm(paceCase(iWksp).dQRS,paceCase(iWksp).dEDV);
%     x1 = mdl.Coefficients{2,1};
%     x0 = mdl.Coefficients{1,1};
%     plot(dQRSLim,x0 + x1*dQRSLim, '--k', 'LineWidth', 2)
%     text(-12,-2,['R^2=' num2str(mdl.Rsquared.ordinary,2)], 'FontSize', 16)
%     
%     if (iWksp== 1)% || (iWksp== 5)
%         xlabel('Acute QRS duration difference (ms)')
%         ylabel('Chronic EDV difference (ms)') 
%     end
    xticks(-60:20:0)
    yticks(-15:5:5)
    xlim(dQRSLim)
    ylim([-15 5])

    set(hs, 'LineWidth', lWidth, 'FontSize', fSize)

end

fixPaperSize
print(hFig, '-dpdf', fullfile(wDir, 'QRS-EDV'))
close(hFig)