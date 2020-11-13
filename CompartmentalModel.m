%
% -------------------------------------------------------------------------
% Compartmental model (CM) of the heart and circulation
% -------------------------------------------------------------------------
%
%
%    .:::.   .:::.
%   :::::::.:::::::
%   :::::::::::::::
%   ':::::::::::::'
%     ':::::::::'
%       ':::::'              
%         ':'
% 
% This code simulates pressure-volume behavior of left and right ventricles
% coupled to a circuit model of the systemic and pulmonary circulations.
% Ischemia and dyssynchrony can be simulated based on Sunagawa's (multi-)
% compartmental model, or TriSeg/MultiPatch (Lumens, Walmsley). This model 
% is specifically designed to be used in combination with a growth code.
%
% Original version from Colleen Witzenburg (CMW), published in J Cardiovasc
% Trans Res 2018 (doi:10.1007/s12265-018-9793-1), rewritten and adapated by
% Pim Oomen (PJO) to include active contraction and dyssynchrony. Please be
% refered to the included input files for extended documentation and 
% instructions. You are encouraged to create your own input files based on
% the included files and share them with others.
%
% Last updated: Pim Oomen, 11/12/2020
%
%%

% Only rebuild workspace if not using within the growth framework
if ~exist('growthSwitch','var')
    clear all; close all
    addpath(genpath('lib'))
    addpath(genpath('input'))
    growthSwitch = false;
end

CMRootDir = fileparts(mfilename('fullpath'));


%% User input: call user input file

% Only call input function when not being used within the growth framework
if ~growthSwitch

    % Run LBBB and CRT growth simulation calibrated to Vernooy et al., 2007, as
    % published in Oomen et al., 2020
    Vernooy2007
    % ScarPaceSweep

    % Input files for Witzenburg et al. 2018
    % PressureOverloadFitting
    % PressureOverloadValidation
    % VolumeOverloadFitting
    % VolumeOverloadValidation

end


%% Preamble - initialization operations

% Load initial volumes from previous simulation (if available) to 
% accelarate convergence of the current simulation
if exist(fullfile(CMRootDir,'convergedSols/kconverged.mat'), 'file') == 2
    disp('Volumes initialized using previous simulation outcome')
    load(fullfile(CMRootDir,'convergedSols/kconverged'), 'ConSol')
    k = ConSol.k;
% When running within a growth simulation, use the previous converged
% solution
else
    ConSol = [];
end

% Set parameters when using CM within growth simulation
if growthSwitch
    HR = HRg(iG);
    SBV = SBVg(iG);
    resistances(3) = Rasg(iG);
    resistances(7) = MVBRg(iG);
    tActivation = tActivationg(:,iG);
    % Option 1b, only when opted out of 1a by setting fPVExp = []
    if isempty(fPVExp)
        fEt = setActivationTiming(fEtg, tG(iG));
    end
else
    growthIni = false;
    growthSwitch = false;
end

% Set compartments, infarct size and offset for simulation choices
if infarctSize == 0     % Dyssynchrony / Single compartment
    LVCompartments = length(tActivation);
else % Ischemia
    LVCompartments = 2;   % Set compartment number to 2: healthy myocardium and scar
    tActivation = [0 0]';           % No offset in activation: no contraction in scar
    ischemicCompartments = 2;
end

% Assemble material parameters in one array for passing between functions
pars = [A B LVEes V0 t0];

% Assemble simulation parameters in a single structure for passing between functions
simPars.infarctSize = infarctSize;
simPars.LVCompartments = LVCompartments;
simPars.tActivation = tActivation;

% When using a the model within a fitting algorithm (declare fitSwitch in
% this script!) or growth model, surpress plots for improved fitting speed
if exist('fitSwitch','var') || growthSwitch
    plotPars.plotKill = true;
else
    plotPars.plotKill = false;
end

% Version-compatibility, set TriSeg false for old versions
if ~exist('TriSeg','var')  
    TriSeg.switch = false;
end

% Create figure directory if non-existent (and required)
if ~plotPars.plotKill
    if ~isdir(figDir); mkdir(figDir); end
end

% Append plot parameters with figure directory
plotPars.figDir = figDir;

% Remove log file if existing from previous run
if exist(fullfile(figDir,'solver.log'), 'file')==2; delete(fullfile(figDir,'solver.log')); end


%% Set e(t) function for time-varying elastance

% Generate e(t) function(s) for LV and RV
% If running a growth simulation with ischemia, activate the (not quite 
% yet) ischemic part during the first iteration
if ( ~TriSeg.switch )
    % Option c
    if etSinoid
        disp('Using time-varying elastance with sinoid e(t)')
        [etLV, etRV] = generateEtFunctionSinoid(tActivation, HR,...
                                solverSettings.nSteps, t0);
    % Option b
    elseif ~isempty(fEt)
        disp('Using time-varying elastance with custom e(t)')
        load(fEt, 'etLV', 'etRV', 'HR', 'tActivation');
    % Option 1a
    elseif ~isempty(fPVExp)
        disp('Using time-varying elastance with data-based e(t)')
        [etLV, etRV] = generateEtFunction(...
            tActivation, HR, solverSettings.nSteps,...
            fPVExp, VExpEt, pExpEt, HRExpEt, tSysChange, smoothFraction, [], t0);
    end

% For active contraction with TriSeg, set e(t) empty
else
    etLV = [];
    etRV = [];
end

% Set possible ischemic compartments to not contract (after growth control)
if ~growthIni
    etLV(:,ischemicCompartments) = 0;
end


%% Set LV and RV parameters

% Material parameters columns (every row represents a different
% compartment):
% 1 - A             % 8 - td
% 2 - B             % 9 - tMax
% 3 - E             % 10 - P0
% 4 - V0            % 11 - K1
% 5 - a6            % 12 - K2
% 6 - a4            % 13 - t0
% 7 - tr0

[LVPars, RVPars] = set_VentricularParameters(simPars, RVScale, pars); 


%% LV parameters update due to growth

% After baseline and acute change, use the parameters calculated in the growth script
if (growthSwitch) && (iG > 2) && (~TriSeg.switch)
    LVPars(:,1:4) = squeeze(LVParsg(iG,:,1:4));
    RVPars(:,1:4) = RVParsg(iG,1:4);
end

%% Initialize volumes and time array

% Volume and Pressure Compartment Designations
%   Column  Compartment       
%   1       pulmonary veins                 
%   2       left ventricle - compartment 1        
%   3       systemic arteries            
%   4       systemic veins               
%   5       right ventricle                 
%   6       pulmonary arteries
%   7-end   additional left ventricle compartments  

% Calculate initial (t=0) volumes and set material parameters based on the
% given set of parameters and simulation type (baseline, MI, dyssynchrony).
[Volumes, t, detLV] = set_initialconditions(simPars, HR, SBV, k, solverSettings,...
                                          growthSwitch, growthIni, etLV, LVPars, TriSeg);   


%% TriSeg initialization

if TriSeg.switch
    if growthSwitch
        TriSeg.tActivation = tActivationg(:,iG)';
        TriSeg.Ischemic = Ischemicg(:,iG)';
    end
    TriSeg = TriSegInit(TriSeg,t,Volumes, ConSol);
end


%% Simulate Heart Beat

% Core of the code: run circulation model until convergence of the
% full circulation
[Volumes, Pressures, Valves, TriSeg] = simulate_heart_beat(Volumes,...
                resistances, capacitances, LVPars, RVPars, t,...
                simPars, solverSettings, plotPars,...
                etLV, etRV, detLV,TriSeg);
            
%% Compute kinematics for CM

if (~TriSeg.switch)
    % Stretch, strain, circumferential shortening, and add additional column to
    % the volume and pressure arrays for total LV (for MI and dyssynchrony).
    [lab, eps, eps0, Volumes, Pressures] = getKinematics(Volumes, Pressures,...s
                                                             LVPars, V0, simPars, Valves);  
else
    lab = [];
    eps = [];
    eps0 = [];
end
    

%% Output 

if (~plotPars.plotKill && ~growthSwitch)
    [cMap, cMapBar, cBar] = plotOutput(...
                                   Volumes, Pressures, t, Valves, simPars,...
                                   plotPars, LVPars, LVEes,...
                                   fExp, VExp, pExp, lab, eps, eps0, etLV, TriSeg);
end

%% Save results workspace if not in a growth simulation or fitting procedure

% Save initial volumes at convergence to be used in a next model run, to
% speed up the next simulartion. Combine multiple LV compartments in one
% single LV volume. Don't save if for some reason volumes are complex, NaN
% or negative.
if ( ~sum(isnan(Volumes(:))) && isreal(Volumes) && ~(sum(Volumes(1,:)<0)) )
    if TriSeg.switch 
        ConSol.VS = TriSeg.VS;
        ConSol.YS = TriSeg.YS;
        ConSol.C = TriSeg.C;
        ConSol.Lsc = TriSeg.Lsc;  
        ConSol.k = Volumes(1,:)/SBV;
    else
        ConSol.k = [Volumes(1,1) sum(Volumes(1,[2 7:(6+LVCompartments-1)])) Volumes(1,3:6)]/SBV;
    end
    save(fullfile(CMRootDir,'convergedSols/kconverged'), 'ConSol')
end
if (~plotPars.plotKill && ~growthSwitch)
    
    save(fullfile(figDir,'wksp'))
    clear growthSwitch      % If rerunning the model without clearing workspace
    
end



