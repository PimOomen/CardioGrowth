
clear all; close all

wkDir = '';
wkspDir = 'SimulationResults';
expDir = 'Data';      
  

%% Load data

load(fullfile(expDir, 'VernooyData2007'))
EDV = EDV-100;
LatWallMass = LatWallMass - 100;
SepWallMass = SepWallMass - 100;

load(fullfile(expDir, 'VernooyData2007dpdtMax'))


%% Load and process simulation results

load(fullfile(wkDir, wkspDir, 'Vernooy2007Growth'), '',...
                             'iForward', 'iReversal', 'HRg', 'solverSettings')

iLV = 1:16;
iSep = [2 3 8 9 14];
iLat = [5 6 12 13 16];

EDVEst = dimensions(2:end,1);

LVWallMassEst = zeros(Ng-1,1);
LatWallMassEst = zeros(Ng-1,1);
SepWallMassEst = zeros(Ng-1,1);

for iG = 2:Ng

    Fgi = squeeze(Fg(:,:,iG,:));
    
    % 3D
    LVWallMassEst(iG-1)  = mean(Fgi(1,1,iLV).*Fgi(3,3,iLV).*Fgi(2,2,iLV));
    LatWallMassEst(iG-1) = mean(Fgi(1,1,iLat).*Fgi(3,3,iLat).*Fgi(2,2,iLat));
    SepWallMassEst(iG-1) = mean(Fgi(1,1,iSep).*Fgi(3,3,iSep).*Fgi(2,2,iSep));

end

% From measures to change
EDVEst = EDVEst./EDVEst(1)*100 - 100;
LVWallMassEst = LVWallMassEst./LVWallMassEst(1)*100 - 100;
LatWallMassEst = LatWallMassEst./LatWallMassEst(1)*100 - 100;
SepWallMassEst = SepWallMassEst./SepWallMassEst(1)*100 - 100;

% Interpolate to data time points
EDVEstInt = interp1(tG(2:end), EDVEst, time);
LVWallMassEstInt = interp1(tG(2:end), LVWallMassEst, time);
LatWallMassEstInt = interp1(tG(2:end), LatWallMassEst, time);
SepWallMassEstInt = interp1(tG(2:end), SepWallMassEst, time);

%
EDPEst = ValuesofInterest(:,1);
ESPEst = ValuesofInterest(:,4);
dpdtMaxEst = ValuesofInterest(:,3);

%% Plot mass change

massLims = [-10 50];
fSize = 18;
mSize = 10;
lWidth = 3;
cFit = [229 113 0]/255;

TriSeg.patches = [1 3 3 1 1 1 1 3 3 1 1 1 1 3 1 1 2 2 2 2 2 ];  

hFig = figure('Position', [100 100 1200 420], 'Visible', 'Off');

hs(1) = subplot(1,3,1); hold on
errorbar(time/7, LVWallMass, LVWallMassStd,'ok', 'MarkerSize', mSize,...
'LineWidth', lWidth, 'MarkerFaceColor', [1 1 1])
plot(tG(2:end)/7, LVWallMassEst, 'Color', cFit, 'LineWidth', lWidth)
xlabel('Time (weeks)')
xticks([0 8 16])
yticks([ 0 25 50])
ylim([-10 50])
xlim([-1 16.5])
ylabel('LV wall mass change (%)')
axis square

hs(2) = subplot(1,3,2); hold on
errorbar(time/7, LatWallMass, LatWallMassStd,'ok', 'MarkerSize', mSize,...
'LineWidth', 3, 'MarkerFaceColor', [1 1 1])
plot(tG(2:end)/7, LatWallMassEst, 'Color', cFit, 'LineWidth', lWidth)
xlabel('Time (weeks)')
xticks([0 8 16])
yticks([ 0 25 50])
ylim([-10 50])
xlim([-1 16.5])
ylabel('Lat wall mass change (%)')
axis square

hs(3) = subplot(1,3,3); hold on
errorbar(time/7, SepWallMass, SepWallMassStd,'ok', 'MarkerSize', mSize,...
'LineWidth', lWidth, 'MarkerFaceColor', [1 1 1])
plot(tG(2:end)/7, SepWallMassEst, 'Color', cFit, 'LineWidth', lWidth)
xlabel('Time (weeks)')
xticks([0 8 16])
yticks([ 0 25 50])
ylim([-10 50])
xlim([-1 16.5])
ylabel('Sep wall mass change (%)')
axis square

set(hs, 'LineWidth', lWidth, 'FontSize', fSize)

fixPaperSize
print(hFig, '-dpdf', fullfile(wkDir, 'mass'))
close(hFig)