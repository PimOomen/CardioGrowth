
% Script to analyze strain, used to generate Fig. 3 in Oomen 2020
% Requires a workspace from a growth simulation, in the paper the input
% file Vernooy2007 was used.
%
% last updated: Pim Oomen, 11/12/2020

clear all; close all

simDir = 'Output/Vernooy2007Growth';
expDir = 'data';  
figDir = '';

addpath(genpath('../Output'));
if ~isdir(figDir); mkdir(figDir); end

%% Load growth results

load(fullfile(simDir, 'wkspGrowth'), 'labfg', 'Volumesg',...
                             'iForward', 'iReversal', 'HRg', 'solverSettings', 'valveEventsg')
iForward=  iForward; iReversal = iReversal;
% Stretch                       
labfBL = labfg(:,1:16,1);
labfLBBB = labfg(:,1:16,2);
labfLBBBChronic = labfg(:,1:16,iForward(end));
labfCRT = labfg(:,1:16,iReversal(1));
labfCRTChronic = labfg(:,1:16,iReversal(end));

% Green-Lagrange strain
EfBL = 0.5*(labfBL.^2 - 1);
EfLBBB = 0.5*(labfLBBB.^2 - 1);
EfLBBBChronic = 0.5*(labfLBBBChronic.^2 - 1);
EfCRT = 0.5*(labfCRT.^2 - 1);
EfCRTChronic = 0.5*(labfCRTChronic.^2 - 1);

% Shortening
[~,iED] = max(Volumesg(:,1));
labf0BL = labfBL./labfBL(iED,:) - 1;
[~,iED] = max(Volumesg(:,2));
labf0LBBB = labfLBBB./labfLBBB(iED,:) - 1;
[~,iED] = max(Volumesg(:,iReversal(1)));
labf0CRT = labfCRT./labfCRT(iED,:) - 1;


%% Plot parameters

lWidth = 3;
fSize = 16;
tLim = [0 0.7];
labLim = [0.8 1.2];
ELim = [-0.2 0.2];
lab0Lim = [-0.2 0.2];
c = lines;

% Wall sectors
iLat = [5 6 11 12 16];
iSep = [2 3 8 9 14];
cLat = c(2,:);
cSep = c(1,:);


%% Stretch 

hFig = figure('Visible', 'Off', 'Position', [680 558 1200 420]); hold on

% Baseline
hs(1) = subplot(1,3,1); hold on
title('Baseline')
t = linspace(0,60/HRg(1), solverSettings.nSteps);
plotValves(t, valveEventsg(1,1), valveEventsg(1,2), valveEventsg(1,3), valveEventsg(1,4), labLim)
pSep = plot(t, mean(labfBL(:,iSep),2), 'LineWidth', 5, 'Color', cSep);
pLat = plot(t, mean(labfBL(:,iLat),2), 'LineWidth', 5, 'Color', cLat);
plot(t, labfBL(:,iSep), 'LineWidth', 1, 'Color', cSep)
plot(t, labfBL(:,iLat), 'LineWidth', 1, 'Color', cLat)
xlabel('Time (s)')
ylabel('Fiber stretch (-)')
legend([pSep pLat], {'Septal', 'Lateral'}, 'Location', 'NorthEast', 'Orientation', 'Vertical')
legend('boxoff')
axis square
xlim(tLim)
ylim(labLim)

hs(2) = subplot(1,3,2); hold on
title('Acute LBBB')
t = linspace(0,60/HRg(2), solverSettings.nSteps);
plotValves(t, valveEventsg(1,1), valveEventsg(1,2), valveEventsg(1,3), valveEventsg(1,4), labLim)
plot(t, mean(labfLBBB(:,iSep),2), 'LineWidth', 5, 'Color', cSep)
plot(t, mean(labfLBBB(:,iLat),2), 'LineWidth', 5, 'Color', cLat)
plot(t, labfLBBB(:,iSep), 'LineWidth', 1, 'Color', cSep)
plot(t, labfLBBB(:,iLat), 'LineWidth', 1, 'Color', cLat)
xlabel('Time (s)')
ylabel('Fiber stretch (-)')
xlim(tLim)
ylim(labLim)
axis square

hs(3) = subplot(1,3,3); hold on
title('Acute CRT')
t = linspace(0,60/HRg(iReversal(1)), solverSettings.nSteps);
plotValves(t, valveEventsg(1,1), valveEventsg(1,2), valveEventsg(1,3), valveEventsg(1,4), labLim)
plot(t, mean(labfCRT(:,iSep),2), 'LineWidth', 5, 'Color', cSep)
plot(t, mean(labfCRT(:,iLat),2), 'LineWidth', 5, 'Color', cLat)
plot(t, labfCRT(:,iSep), 'LineWidth', 1, 'Color', cSep)
plot(t, labfCRT(:,iLat), 'LineWidth', 1, 'Color', cLat)
xlabel('Time (s)')
ylabel('Fiber stretch (-)')
xlim(tLim)
ylim(labLim)
axis square

set(hs, 'LineWidth', lWidth, 'FontSize', fSize)

fixPaperSize
print(hFig, '-dpdf', fullfile(figDir, 'stretch'))
close(hFig)


%% Shortening

hFig = figure('Visible', 'Off', 'Position', [680 558 2.5*560 420]); hold on

% Baseline
hs(1) = subplot(1,3,1); hold on
title('Baseline')
t = linspace(0,60/HRg(1), solverSettings.nSteps);
plotValves(t, valveEventsg(1,1), valveEventsg(1,2), valveEventsg(1,3), valveEventsg(1,4), lab0Lim)
pSep = plot(t, mean(labf0BL(:,iSep),2), 'LineWidth', 5, 'Color', cSep);
pLat = plot(t, mean(labf0BL(:,iLat),2), 'LineWidth', 5, 'Color', cLat);
plot(t, labf0BL(:,iSep), 'LineWidth', 1, 'Color', cSep)
plot(t, labf0BL(:,iLat), 'LineWidth', 1, 'Color', cLat)
xlabel('Time (s)')
ylabel('Myofiber shortening (-)')
axis square
xlim(tLim)
yticks(-0.2:0.1:0.2)
legend([pSep pLat], {'Septal', 'Lateral'}, 'Location', 'NorthEast', 'Orientation', 'Vertical')
legend('boxoff')
ylim(lab0Lim)

hs(2) = subplot(1,3,2); hold on
title('Acute LBBB')
t = linspace(0,60/HRg(2), solverSettings.nSteps);
plotValves(t, valveEventsg(1,1), valveEventsg(1,2), valveEventsg(1,3), valveEventsg(1,4), lab0Lim)
pSep = plot(t, mean(labf0LBBB(:,iSep),2), 'LineWidth', 5, 'Color', cSep);
pLat = plot(t, mean(labf0LBBB(:,iLat),2), 'LineWidth', 5, 'Color', cLat);
plot(t, labf0LBBB(:,iSep), 'LineWidth', 1, 'Color', cSep)
plot(t, labf0LBBB(:,iLat), 'LineWidth', 1, 'Color', cLat)
xlabel('Time (s)')
ylabel('Myofiber shortening (-)')
xlim(tLim)
yticks(-0.2:0.1:0.2)
ylim(lab0Lim)
axis square

hs(3) = subplot(1,3,3); hold on
title('Acute CRT')
t = linspace(0,60/HRg(iReversal(1)), solverSettings.nSteps);
plotValves(t, valveEventsg(1,1), valveEventsg(1,2), valveEventsg(1,3), valveEventsg(1,4), lab0Lim)
plot(t, mean(labf0CRT(:,iSep),2), 'LineWidth', 5, 'Color', cSep)
plot(t, mean(labf0CRT(:,iLat),2), 'LineWidth', 5, 'Color', cLat)
plot(t, labf0CRT(:,iSep), 'LineWidth', 1, 'Color', cSep)
plot(t, labf0CRT(:,iLat), 'LineWidth', 1, 'Color', cLat)
xlabel('Time (s)')
ylabel('Myofiber shortening (-)')
xlim(tLim)
yticks(-0.2:0.1:0.2)
ylim(lab0Lim)
axis square

set(hs, 'LineWidth', lWidth, 'FontSize', fSize)

fixPaperSize
print(hFig, '-dpdf', fullfile(figDir, 'shortening'))
close(hFig)


%% Green-Lagrange Strain

hFig = figure('Visible', 'Off', 'Position', [680 558 1200 420]); hold on

% Baseline
hs(1) = subplot(1,3,1); hold on
title('Baseline')
t = linspace(0,60/HRg(1), solverSettings.nSteps);
plotValves(t, valveEventsg(1,1), valveEventsg(1,2), valveEventsg(1,3), valveEventsg(1,4), ELim)
pSep = plot(t, mean(EfBL(:,iSep),2), 'LineWidth', 5, 'Color', cSep);
pLat = plot(t, mean(EfBL(:,iLat),2), 'LineWidth', 5, 'Color', cLat);
plot(t, EfBL(:,iSep), 'LineWidth', 1, 'Color', cSep)
plot(t, EfBL(:,iLat), 'LineWidth', 1, 'Color', cLat)
xlabel('Time (s)')
ylabel('Fiber strain (-)')
legend([pSep pLat], {'Septal', 'Lateral'}, 'Location', 'NorthEast', 'Orientation', 'Vertical')
legend('boxoff')
axis square
xlim(tLim)
ylim(ELim)

hs(2) = subplot(1,3,2); hold on
title('Acute LBBB')
t = linspace(0,60/HRg(2), solverSettings.nSteps);
plotValves(t, valveEventsg(1,1), valveEventsg(1,2), valveEventsg(1,3), valveEventsg(1,4), ELim)
plot(t, mean(EfLBBB(:,iSep),2), 'LineWidth', 5, 'Color', cSep)
plot(t, mean(EfLBBB(:,iLat),2), 'LineWidth', 5, 'Color', cLat)
plot(t, EfLBBB(:,iSep), 'LineWidth', 1, 'Color', cSep)
plot(t, EfLBBB(:,iLat), 'LineWidth', 1, 'Color', cLat)
xlabel('Time (s)')
ylabel('Fiber strain (-)')
xlim(tLim)
ylim(ELim)
axis square

hs(3) = subplot(1,3,3); hold on
title('Acute CRT')
t = linspace(0,60/HRg(iReversal(1)), solverSettings.nSteps);
plotValves(t, valveEventsg(1,1), valveEventsg(1,2), valveEventsg(1,3), valveEventsg(1,4), ELim)
plot(t, mean(EfCRT(:,iSep),2), 'LineWidth', 5, 'Color', cSep)
plot(t, mean(EfCRT(:,iLat),2), 'LineWidth', 5, 'Color', cLat)
plot(t, EfCRT(:,iSep), 'LineWidth', 1, 'Color', cSep)
plot(t, EfCRT(:,iLat), 'LineWidth', 1, 'Color', cLat)
xlabel('Time (s)')
ylabel('Fiber strain (-)')
xlim(tLim)
ylim(ELim)
axis square

set(hs, 'LineWidth', lWidth, 'FontSize', fSize)

fixPaperSize
print(hFig, '-dpdf', fullfile(figDir, 'strain'))
close(hFig)