%
% -------------------------------------------------------------------------
% Growth Code using the Compartmental model (CM)
% -------------------------------------------------------------------------
%
%           |  \ \ | |/ /
%           |  |\ `' ' /
%           |  ;'aorta \      / , pulmonary
%           | ;    _,   |    / / ,  arteries
%  superior | |   (  `-.;_,-' '-' ,
% vena cava | `,   `-._       _,-'_
%           |,-`.    `.)    ,<_,-'_, pulmonary
%          ,'    `.   /   ,'  `;-' _,  veins
%         ;        `./   /`,    \-'
%         | right   /   |  ;\   |\
%         | atrium ;_,._|_,  `, ' \
%         |        \    \ `       `,
%         `      __ `    \   left  ;,
%          \   ,'  `      \,  ventricle (this one can grow here)
%           \_(            ;,      ;;
%           |  \           `;,     ;;
%  inferior |  |`.          `;;,   ;'
% vena cava |  |  `-.        ;;;;,;'
%           |  |    |`-.._  ,;;;;;'
%           |  |    |   | ``';;;'  FL
%                   aorta
%
% Simulate growth with the compartmental model (CompartmentalModel.m)
% Original concept from Colleen Witzenburg (CMW), published in J Cardiovasc
% Trans Res 2018 (doi:10.1007/s12265-018-9793-1), rewritten and adapted by 
% Pim Oomen (PJO) to include active contraction and dyssynchrony. Please be
% refered to the included input files for extended documentation and 
% instructions. You are encouraged to create your own input files based on
% the included files and share them with others.
%
% Last updated: Pim Oomen 2020/11/12 

% Disable the following line if using within aanother code
clear all; close all

% Add functions to path
addpath(genpath('lib'));
addpath(genpath('input'));

% Inform the input file it is used in a growth simulation
growthSwitch = true;


%% User input: call user input file

% Run LBBB and CRT growth simulation calibrated to Vernooy et al., 2007, as
% published in Oomen et al., 2020
Vernooy2007
% ScarPaceSweep

% Input files for Witzenburg et al. 2018
% PressureOverloadFitting
% PressureOverloadValidation
% VolumeOverloadFitting
% VolumeOverloadValidation


%% Preamble

tic

% Create figure directory
if ~isdir(figDir); mkdir(figDir); end

% Assemble growth parameters to pass between functions, choice between
% modified KOM and sigmoid. For older input file versions, this switch did
% not exist so set automatically to false to keep using modified KOM
if ~exist('sigmoidSwitch','var'); sigmoidSwitch = false; end
if ~sigmoidSwitch
    growthPars = [f_f sl_50 r_f_pos r_f_neg posst_50 negst_50 f_ff_max f_cc_max wc];
else
    growthPars = [FfgmaxPos FfgmaxNeg nfPos nfNeg sl_50_pos sl_50_neg frRatio];
end

% Initiate dimensions and ValuesofInterest arrays, stores useful readouts
dimensions = zeros(Ng, 3);
ValuesofInterest = zeros(Ng, 7);

% Append plot parameterds with figure directory
plotParsg.figDir = figDir;


%% RUNNING CONTROL CIRCULATION LOOP

% Growth step, baseline 
iG = 1;                         % Iteration #

% Call on CM (and let it know it's being used in a growth simulation)
growthIni = true;
growthSwitch = true;
CompartmentalModel;


%% INITIALIZING GROWTH

% Initiate pressure and volume time history arrays
Pressuresg = zeros(solverSettings.nSteps, Ng);
if TriSeg.switch
    VolumesgT  = zeros(solverSettings.nSteps, Ng);
    Volumesg = VolumesgT;           % Not used in TriSeg growth
else
    % Volumes time history
    Volumesg  = zeros(solverSettings.nSteps, LVCompartments, Ng);   % LV subcompartments
    VolumesgT  = zeros(solverSettings.nSteps, Ng);     % Total volume
    
    % Initiate material property arrays (see CMW 2018, change with growth
    % when using thin-walled compartmental ventricles
    LVParsg = zeros(Ng, LVCompartments, 5);
    RVParsg = zeros(Ng, 5);
end

% Initialize elastic stretch time history arrays
labfg = zeros(solverSettings.nSteps, LVCompartments, Ng);
labrg = zeros(solverSettings.nSteps, LVCompartments, Ng);

% Store hemodynamics at current time point
storeHemodynamics

% Determine the size of the unloaded LV geometry and initiate growth stuff
if TriSeg.switch
    [Fg, st, sl, r0, h0] = initializeGrowthTriSeg(TriSeg,Ng);
else
    [Fg, st, sl, r0, h0] = calculating_unloaded_geometry(LVwallvolume, Ng, LVPars); 
end

% Calculate and plot a range of geometrical and mechanical constituents
runCalculatePlotDimensionsStresses

% Plot progress
if plotSwitchg
    [hProgress1, hProgress2, hProgress3, hProgress4, hProgress] = plotGrowthProgress(VolumesgT, ...
                                    Pressuresg, Fg, plotParsg, iG, tG,...
                                    [], [], labfg, [], [], [], []);
end


%% Acute change

iG = 2;

% No growth occurs during perturbation
if ~TriSeg.switch
    r0(iG,:) = r0(iG-1,:);      
end
h0(iG,:) = h0(iG-1,:);

% Run the CM, now with acute change
simType = 0;
growthSwitch = true;
growthIni = false;
kg = Volumes(1,1:end-1)./SBV; 
CompartmentalModel;

% Store hemodynamics
storeHemodynamics

% Calculate and plot a range of geometrical and mechanical constituents
runCalculatePlotDimensionsStresses

% Create bullseye plots for progress report
if LVCompartments == 16
    [BSegments, BActivation] = bullseyeInit(tActivationg, plotParsg, ischemicCompartments);
else
    BSegments = [];     BActivation = [];
end

% Plot progress
if plotSwitchg
    [hProgress1, hProgress2, hProgress3, hProgress4, ~] = plotGrowthProgress(VolumesgT, ...
                                Pressuresg, Fg, plotParsg, iG, tG,...
                                BSegments, BActivation, labfg,...
                                hProgress1, hProgress2, hProgress3, hProgress4);
end


%% SETTING PARAMETERS FOR GROWTH

% Setting constitutive material parameters constant throughout growth
if ~TriSeg.switch
    [ees, a, b, LVParsg, RVParsg] = material_properties_during_growth(...
        ees, a, b, LVParsg, RVParsg, iG, Ng);
end

% Let CM know playtime is over, time to grow
growthIni = false;


%% SIMULATING GROWTH

% Preset change in cavity volume during growth, to update SBV
dVCavity = 0;

for iG = (iG+1):Ng
    
    %% Wait bar =D
    disp(['Growth step ' num2str(iG) '/' num2str(Ng)]);
    
    
    %% Let it grow, let it grow, let it grow...
     
    % Thick-walled TriSeg, as in Oomen 2020
    if TriSeg.switch   
        [h0(iG,:), Fg(:,:, iG,:), st(iG,:), sl(iG,:), TriSeg] = ...
            GrowthLaw_modifiedKOM_isotropic_evolving_TriSeg(h0(iG-1,:), squeeze(Fg(:,:, iG-1,:)), growthPars,...
                                   sigmoidSwitch, tScale,...
                                   labfg, labrg, TriSeg, iG);  
    % Thin-walled sphere, as in Witzenburg 2018
    else
        
        [r0(iG,:), h0(iG,:), Fg(:,:, iG,:), st(iG,:), sl(iG,:)] = ...
            GrowthLaw_modifiedKOM( r0, h0, r, h, squeeze(Fg(:,:, iG-1,:)),...
                                growthPars, ischemicCompartments, sigmoidSwitch);
                               
       % Computing the altered LV pressure-volume parameters
        LVParsg(iG,:,[1:4]) = Recomputing_LV_params(r0(iG,:), h0(iG,:),...
                                    a(iG,:),b(iG,:), ees(iG,:));
    
    end                       
    
    % Adjusting "Stressed" Blood Volume      
    % The "Stressed" Blood Volume within the compartmental model acutally 
    % includes some unstressed volume since the unloaded volumes from the 
    % LV and RV are incorporated in this number. Thus, when the unloaded LV
    % volume is increased or decreased with growth the total "Stressed" 
    % blood volume parameter within the circulation model should change
    % dVCavity = dVCavity +  sum((LVParsg(iG,:,4))) - sum((LVParsg(iG-1,:,4)));
    SBVg(iG) = SBVg(iG) + dVCavity;
    

    %% Re-loading the grown ventricle 

    % Run CM
    growthSwitch = true;
    CompartmentalModel;

    % Store hemodynamics
    storeHemodynamics

    % Calculate and plot a range of geometrical and mechanical constituents
    runCalculatePlotDimensionsStresses

    % Plot progress
    if plotSwitchg
        [hProgress1, hProgress2, hProgress3, hProgress4, ~] = plotGrowthProgress(VolumesgT, ...
                                Pressuresg, Fg, plotParsg, iG, tG,...
                                BSegments, BActivation, labfg,...
                                hProgress1, hProgress2, hProgress3, hProgress4);
    end

end         % End of main while loop

toc


%% Plotting section

if plotSwitchg
    plotGrowthMulti(plotParsg, dimensions, ValuesofInterest, Fg,...
                         sl, st, VolumesgT, Pressuresg, t, r0, h0,...
                         refState, tActivationg, tG);
end  


%% Wrap up

% Save disk space before saving workspace
clear sigma_ES sigma_ED BActivation BSegments strainc hProgress h

save(fullfile(figDir, 'wkspGrowth'));

