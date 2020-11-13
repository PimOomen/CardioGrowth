
% Script to run a sweep of growth simulations for different ischemia
% patterns and pacing locations (Oomen 2020 Figs. 7-8)
%
% Changes to be made in Compartmental Growth Model (CGM):
%   o Disable clear all; close at the start
%   o Use input file 'ScarPaceSweep'

% Last updated: Pim Oomen, 2020/11/12


clear all; close all



%% Ischemia patterns, used for loading activation timings and setting segments as scar

addpath(genpath('../'))
fitSwitch = true;       % Used to let CGM know it is used in a larger plan

scarTypes = {'',...
             '_LCXscar', '_LCXscar_Basal',...
             '_LADscar', '_LADscar_Basal',...
             '_RCAscar', '_RCAscar_Basal'};

% AHA segments modeled as ischemic         
scars(1).pattern = [];
scars(2).pattern = [11 12 16];
scars(3).pattern = [5 6 11 12];
scars(4).pattern = [7 8 13];
scars(5).pattern = [1 7];
scars(6).pattern = [9 10 15];
scars(7).pattern = [3 4 10];

%%
for iScarCase = 1:2

    wkspName = ['AHAGrowthSweep' scarTypes{iScarCase}];                      

    %% Run all growth predictions

    for iAHA = 1:16


        %% Run model 

        % Load activation timing
        load(['CRT011_PaceAHA' scarTypes{iScarCase} '/tActivationsegment' num2str(iAHA)])

        compartmentalGrowth
        close all

        %% Extract EDV and wall mass

        iLV = 1:16;
        iSep = [2 3 8 9 14];
        iLat = [5 6 12 13 16];
        iPos = [4 10 15];
        iAnt = [1 7 13];
        iRV = 17:21;

        % iLV = 7:12;
        % iSep = [8 9];
        % iLat = [12 13];

        EDVEst = dimensions(:,1);
        ESVEst = dimensions(:,2);

        LVWallMassEst = zeros(Ng,1);
        LatWallMassEst = zeros(Ng,1);
        SepWallMassEst = zeros(Ng,1);
        RVWallMassEst = zeros(Ng,1);

        for iG = 1:Ng

            Fgi = squeeze(Fg(:,:,iG,:));

            % 3D
            LVWallMassEst(iG)  = mean(Fgi(1,1,iLV).*Fgi(3,3,iLV).*Fgi(2,2,iLV));
            LatWallMassEst(iG) = mean(Fgi(1,1,iLat).*Fgi(3,3,iLat).*Fgi(2,2,iLat));
            SepWallMassEst(iG) = mean(Fgi(1,1,iSep).*Fgi(3,3,iSep).*Fgi(2,2,iSep));
            RVWallMassEst(iG) = mean(Fgi(1,1,iRV).*Fgi(3,3,iRV).*Fgi(2,2,iRV));

        end
        % From measures to change
        iForward = iForward;
        aha(iAHA).EDVEst = EDVEst(iForward(end):end)./EDVEst(iForward(end))*100 - 100;
        aha(iAHA).ESVEst = ESVEst(iForward(end):end)./ESVEst(iForward(end))*100 - 100;
        aha(iAHA).LVWallMassEst = LVWallMassEst(iForward(end):end)./LVWallMassEst(iForward(end))*100 - 100;
        aha(iAHA).LatWallMassEst = LatWallMassEst(iForward(end):end)./LatWallMassEst(iForward(end))*100 - 100;
        aha(iAHA).SepWallMassEst = SepWallMassEst(iForward(end):end)./SepWallMassEst(iForward(end))*100 - 100;
        aha(iAHA).RVWallMassEst = RVWallMassEst(iForward(end):end)./RVWallMassEst(iForward(end))*100 - 100;


        %% Hemodynamics

        aha(iAHA).EDPEst = ValuesofInterest(iForward(end):end,1);
        aha(iAHA).ESPEst = ValuesofInterest(iForward(end):end,4);
        aha(iAHA).dpdtMaxEst = ValuesofInterest(iForward(end):end,3);

    end    

    save(wkspName, 'aha')

end