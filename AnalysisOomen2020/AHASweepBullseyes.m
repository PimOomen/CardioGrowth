
% Script to create bullseye plots of chronic growth simulations, used to
% generate Figs. 6 and 7 in Oomen 2020
%
% Last updated: Pim Oomen, 2020/11/12

clear all; close all

wDir = '';
wkspDir = '';


sweepNames = {'AHAGrowthSweep'
              'AHAGrowthSweep_LADscar'
              'AHAGrowthSweep_LADscar_Basal'
              'AHAGrowthSweep_LCXscar'
              'AHAGrowthSweep_LCXscar_Basal'
              'AHAGrowthSweep_RCAscar'
              'AHAGrowthSweep_RCAscar_Basal'
             };
         
addpath(genpath('functionsUtil'))

cLim = [-15 5];
lWidth = 3;
mSize = 10;                                                           
fSize = 18;

%%

for iWksp = 1:7

    %%
    sweepName = sweepNames{iWksp};

    load(fullfile(wkspDir, sweepName));

    dEDV = zeros(21,1);
    dLatMass = zeros(21,1);
    for iAHA = 1:16
        dEDV(iAHA) = aha(iAHA).EDVEst(end);
        dLatMass(iAHA) = aha(iAHA).LatWallMassEst(end);
    end

    disp(min(dEDV));


    %% Plot bullseye

    Fmin = -cLim(1)/(cLim(2)-cLim(1));           Nmin = round(64*Fmin);
    Fpos =  cLim(2)/(cLim(2)-cLim(1));           Npos = round(64*Fpos);
    cMap = [colorbrewer(Nmin,'Greens'); flipud(colorbrewer(Npos, 'Reds'))];
    cMap(Nmin+1,:) = [1 1 1];

    plotBullseyeSegmentResultRV(dEDV, cLim, cMap, 'Change in EDV (%)',...
                                true, fullfile(wDir, sweepName), true)
                            
end