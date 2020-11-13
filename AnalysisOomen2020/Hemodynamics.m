
% Script to analyze hemodynamics, used to generate Fig. 5 in Oomen 2020
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


%% Load data

load(fullfile(expDir, 'VernooyData2007'))
EDV = EDV-100;
LatWallMass = LatWallMass - 100;
SepWallMass = SepWallMass - 100;

load(fullfile(expDir, 'VernooyDataHemodynamics'))


%% Load and process simulation results

load(fullfile(simDir, 'wkspGrowth'), 'dimensions', 'ValuesofInterest', 'tG',...
                             'iForward', 'iReversal', 'HRg', 'solverSettings', 'Volumesg', 'Pressuresg')
iForward = iForward; iReversal = iReversal;
                         
EDVEst = dimensions(2:end,1);

% From measures to change
EDVEst = EDVEst./EDVEst(1)*100 - 100;

%
EDPEst = ValuesofInterest(:,1);
ESPEst = ValuesofInterest(:,4);
dpdtMaxEst = ValuesofInterest(:,3);

% PV Loops
VBL = Volumesg(:,1);
PBL = Pressuresg(:,1);

VLBBBAcute = Volumesg(:,2);
PLBBBAcute = Pressuresg(:,2);

VLBBBChronic = Volumesg(:,iForward(end));
PLBBBChronic = Pressuresg(:,iForward(end));

VCRTAcute = Volumesg(:,iReversal(1));
PCRTAcute = Pressuresg(:,iReversal(1));

VCRTChronic = Volumesg(:,iReversal(end));
PCRTChronic = Pressuresg(:,iReversal(end));


%% Plot

lWidth = 3;
mSize = 10;
fSize = 18;
VLim = [40 140];
PLim = [0 150];
c = lines;
ct1 = c(1,:);
ct2 = c(2,:);
ct3 = c(5,:);
cFit = [229 113 0]/255;

hFig = figure('Position', [100 100 1200 420], 'Visible', 'Off');


hs(1) = subplot(1,3,1); hold on
plot(VBL, PBL, 'LineWidth', lWidth, 'Color', ct1)
plot(VLBBBAcute, PLBBBAcute, '--', 'LineWidth', lWidth, 'Color', ct1)

plot(VLBBBChronic, PLBBBChronic, '-', 'LineWidth', lWidth, 'Color', ct2)
plot(VCRTAcute, PCRTAcute, '--', 'LineWidth', lWidth, 'Color', ct2)

plot(VCRTChronic, PCRTChronic, '-', 'LineWidth', lWidth, 'Color', ct3)

xlim(VLim)
ylim(PLim)
xlabel('Volume (mL)')
ylabel('Pressure (mmHg)')
axis square

legend('Baseline', 'Acute LBBB', 'Chronic LBBB', 'Acute CRT', 'Chronic CRT',...
        'Location', 'North', 'NumColumns',3, 'FontSize', 12, 'Color', 'w')
legend('boxoff')
% axis square


hs(2) = subplot(1,3,2); hold on
EDVStd(end) = 16.4;
errorbar(time/7, EDV, EDVStd,'ok', 'MarkerSize', mSize,...
'LineWidth', lWidth, 'MarkerFaceColor', [1 1 1])
plot(tG(2:end)/7, EDVEst, 'Color', cFit, 'LineWidth', lWidth)
xlabel('Time (weeks)')
xticks([0 8 16])
ylim([-10 50])
xlim([-1 16.5])
ylabel('EDV change (%)')
axis square

hs(3) = subplot(1,3,3); hold on
tHemo(1) = -2/7;
tG(1) = -2/7;
errorbar(tHemo/7, dpdtMax, dpdtMaxStd,'ok', 'MarkerSize', mSize,...
'LineWidth', lWidth, 'MarkerFaceColor', [1 1 1])
plot(tG/7, dpdtMaxEst, 'Color', cFit, 'LineWidth', lWidth)
xlabel('Time (weeks)')
xticks([0 8 16])
xlim([-1 16.5])
yticks([1000 2000 3000])
ylabel('dp/dt_{max} (mmHg/s)')
axis square

set(hs, 'LineWidth', lWidth, 'FontSize', fSize)

fixPaperSize
print(hFig, '-dpdf', fullfile(figDir, 'hemodynamics'))
close(hFig)



%% Plot pressures

hFig = figure('Position', [100 100 1200 420], 'Visible', 'Off');


hsh(1) = subplot(1,2,1); hold on
EDVStd(end) = 16.4;
errorbar(tHemo/7, EDP, EDPStd,'ok', 'MarkerSize', 10,...
'LineWidth', 3, 'MarkerFaceColor', [1 1 1])
plot(tG/7, EDPEst, 'Color', cFit, 'LineWidth', 3)
xlabel('Time (weeks)')
xticks([0 8 16])
ylim([0 20])
xlim([-1 16.5])
ylabel('EDP (mmHg)')

hsh(2) = subplot(1,2,2); hold on
tHemo(1) = -2/7;
tG(1) = -2/7;
errorbar(tHemo/7, ESP, ESPStd,'ok', 'MarkerSize', mSize,...
'LineWidth', lWidth, 'MarkerFaceColor', [1 1 1])
plot(tG/7, ESPEst, 'Color', cFit, 'LineWidth', lWidth)
xlabel('Time (weeks)')
xticks([0 8 16])
xlim([-1 16.5])
% yticks([1000 2000 3000])
ylabel('ESP (mmHg)')

set(hsh, 'LineWidth', lWidth, 'FontSize', fSize)

fixPaperSize
print(hFig, '-dpdf', fullfile(figDir, 'hemodynamics_pressures'))
close(hFig)

                   