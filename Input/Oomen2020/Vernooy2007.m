%% User input for the compartmental model
%
% 
%//////////////////////////////////////////////////////////////////////////
% Input file desciption
%//////////////////////////////////////////////////////////////////////////

% Pim Oomen - Matching the experimental data of Vernooy et al., Eur 
% Hearth J 2017.

% Journal entries: Model fitting>Fitting Vernooy, Literature>Vernooy


%//////////////////////////////////////////////////////////////////////////
%% Contents
%//////////////////////////////////////////////////////////////////////////
%
%   0. General
%   1. Compartmental model
%       1.1 Hemodynamics
%       1.2 ESPVR/EDPVR
%           a. Generate data-based e(t)
%           b. Use e(t) data file
%           c. Generate sinoid e(t)
%       1.3 TriSeg paramaters
%       1.4 Pathologies/Interventions
%       1.5 Solver controls
%       1.6 Plotting parameters
%   2. Growth
%       2.1 General
%       2.2 Growth time course
%       2.3 Hemodynamics and mechanical activation during growth
%       2.4 Modified KOM model growth parameters
%       2.5 Plot parameters for growth


%//////////////////////////////////////////////////////////////////////////
%% 0. GENERAL
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

% Figure export directory to store figure, workspace, and some functional
% readouts. If non-existent, it will be created for you.
figDir = 'Output/Vernooy2007Growth';


%//////////////////////////////////////////////////////////////////////////
%% 1. COMPARTMENTAL MODEL
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1.1 Hemodynamics
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % Baseline
HR = 89;            % Heart Rate [beats/min] (will be overwritten if using option 2b)
SBV = 352;           % Stresses blood volume for Vernooy (2007) - acute change x0.95
Ras = 0.940;         % Systemic arterial resistance (SVR in CMW paper)

% % Acute
% HR = 95;
% SBV = 300;
% Ras = 1.04;

% Capicitances (Cvp - Cas - Cvs - Cap) [ml/mmHg] from Santamore
% Cvp: Pulmonary venous compliance      Cas: Systemic arterial compliance
% Cvs: Systemic venous compliance       Cap: Pulmonary arterial compliance
capacitances = [3 1.02 17 2];

% Resistances (from Santamore) [mmHg * s/mL]
resistances = [0.015;...;   % Rvp: pumonary venous resistance - resists return of blood to heart
               5*0.023;...    % Rcs: characteristic resistance - indicates stiffness of the aorta
               Ras;...     % Ras: systemic arterial resistance (SVR in paper)
               0.015;...    % Rvs: systemic venous resistance - resists return of blood to heart
               0.06;...     % Rcp: characteristic resistance - indicates stiffness of the pulmonary arteries
               0.30;...     % Rap: pulmonary arterial resistance
               inf];        % MVBR: backflow resistance of the mitral valve (set to Inf for perfect closure)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1.2 ESPVR / EDPVR
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Start time of systole, onset of contraction [s]
t0 = 0.0;                      

%==========================================================================
% Time-varying elastance

% EDPVR & ESPVR parameters (note A & B are switched from Colleen's paper)
A = 2.76e-3;                % Linear ED component [mmHg]
B = 1.13e-1;                % Exponential ED component [1/mL] 
LVEes = 3.55;               % End-systolic elastance of LV [mmHg/mL]
V0 = 31.6;                 % End-systolic elastance of LV [mmHg/mL]

% Scaling factor of maximum contraction of RV compared to LV
RVScale = 3/7;

% Choice of three options for e(t) curves, make sure to set fPVExp, fEt to
% empty if not using option a or b, resp., or etSinoid false is not using a
% sinoid e(t) curve.
%__________________________________________________________________________
% Option a: generate e(t) in this script based on the workspace fPVExp, see
% comments in generateEtFunction for more details on the following parameters
% The number of elements in tActivation determines the number of LV
% compartments, as well as their mechanical activation times
fPVExp = '~/Postdoc/data/fits/normalizedPVlabED1.28/wkspMeanBaseline';
VExpEt = 'VMean';           % Variable that contains experimental volumes
pExpEt = 'pMean';           % Variable that contains experimental pressures
HRExpEt = 'HR';             % Variable that contains experimental HR
tSysChange = 0;             % [ms] Change systole duration (Compression < 0, Extension > 0)
smoothFraction = 0.1;       % Smoothing kernel size, fraction of total time vector length

%__________________________________________________________________________
% Option b: load data file with activation functions and information.
%   The data file should contain e(t) variables for the LV (etLV) and 
%   RV (etRV), heart rate (HR), and a variable 'tActivation' for
%   activation times of all compartments for plotting purposes. See
%   generateEt.m for an example of how to generate such a workspace. 
fEt = [];

%__________________________________________________________________________
% Option c: Santamore/Colleen e(t) sinoid e(t) curve, in this method, the
% duration of systole is relative to the duration of the cardiac cycle.
etSinoid = false;
        

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1.3 TriSeg parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Use TriSeg? Otherwise thin-walled sphere
TriSeg.switch = true;

% Wall properties from average CRT dogs' MRI
TriSeg.AmRefw = 1.56*1.18^(-2)*[7301   9416    4683];                 % [mm^2]
TriSeg.Vwvw =   [61782    46659   39318]*120000/sum([61782 39318]); 

% Patch wall location and amount per wall
% TriSeg.Ischemic = zeros(1,21);
TriSeg.patches = [1 3 3 1 1 1 1 3 3 1 1 1 1 3 1 1 2 2 2 2 2 ];      
TriSeg.NPatches = [ sum(TriSeg.patches==1),...      % Each column is a wall
                    sum(TriSeg.patches==2),...
                    sum(TriSeg.patches==3)];   

% Patch reference area and volume, here distribute evenly
TriSeg.AmRef = TriSeg.AmRefw(TriSeg.patches)./TriSeg.NPatches(TriSeg.patches);
TriSeg.Vwv = TriSeg.Vwvw(TriSeg.patches)./TriSeg.NPatches(TriSeg.patches);              


% Parameter estimation
TriSeg.LsRef = 2.0;          % um        Reference sarcomere length at zero stress
TriSeg.Lseiso = 0.04;      % um        Isometrically stresses series elastic element
TriSeg.Lsc0 = 1.51;        % um        Contractile element length
TriSeg.vMax = 5e-3;        % um/ms    Sarcomere shortening velocity
TriSeg.TR = 0.1375;          % [-]      Duration of rise time, fraction of TR
TriSeg.TD = 0.0825;         % [-]      Duration of decay time, fraction of TD
TriSeg.TAct = 168;         % ms       Base duration of contraction, changes with sarcomere length
TriSeg.Crest = 0.0;        % [-]      Diastolic resting level of activation
TriSeg.SfAct = 0.150;       % MPa
TriSeg.k1 = 0.0597;       % MPa
TriSeg.k3 = 5.71e-04;       % MPa
TriSeg.k4 = 25;       % MPa




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1.4 Pathologies/Interventions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Compartment number(s) that is/are ischemic, for use in combination with
% dyssynchrony in a 16-segment NYHA model. When only ischemia without 
% dyssynchrony, it will be ignored. When using TriSeg and/or growth, will 
% be ignored
load('tActivation_C6_CRTLatMidwall');
tActivation = tActivationBaseline;

% Compartment number(s) that is/are ischemic, for use in combination with
% dyssynchrony. When only ischemia without dyssynchrony, it will be ignored.
ischemicCompartments = [];

% Infarction size (LV fraction), set 0 if using LBBB-ischemia combination
% Will be ignored for TriSeg or multiple compartments
infarctSize = 0.0;

if TriSeg.switch
    TriSeg.Ischemic = zeros(size(TriSeg.patches));
    TriSeg.Ischemic(ischemicCompartments) = 1;
    TriSeg.tActivation = tActivation';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1.5 Solver controls
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Solver settings
solverSettings.cutoff = 0.14;      % Convergence criterium
solverSettings.iterMax = 50;       % Maximum number of iterationsclear all
solverSettings.nSteps = 3000;      % Number of time steps during heart beat
                                   % (will be over-written if
                                   % time-varying elastance is chosen)

% Initial estimate for compartmental volumes, fraction of SBV. Weighting 
% compartments by average literature blood volume.
k = [0.1160    0.1538    0.1049    0.3588    0.1308    0.1357];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1.6 Plotting parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Will be ignored when using growth simulation
plotPars.cMapName = 'RdYlGn';                   % Colorbrewer map name
plotPars.cBarTitle = 'Activation delay (ms)';   % Title of colour bar
plotPars.fSize = 18;                            % Font size
plotPars.lWidth = 3;                            % Line width
plotPars.mSize = 5;                             % Marker size
plotPars.figType = '-dpdf';                     % Figure export type
plotPars.vLim = [40 140];                        % Axis limits from here on
plotPars.pLim = [0 150];                        %
plotPars.labLim = [0.8 1.3];                        %
plotPars.epsLim = [-0.2 0.2];                        %
plotPars.nColours = 10;                         % Colour bar colour levels

% Optional: compare with experimental data, give workspace (fExp) in which 
% experimental volumes and pressures are located, and their variable names 
% (set fExp = [] if not required).
VExp = 'V';         % Name of volume variable in the workspace
pExp = 'p';         % Name of the pressure variable
fExp = [];


if growthSwitch

%//////////////////////////////////////////////////////////////////////////
%% 2. GROWTH
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2.1 Simulation type
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Drug perterbation?
drugSwitch = false;

% LV wall volume, determined such that the acute change in LV wall 
% thickness in the normal compartment matched reported values
% LVwallvolume = 0.1*1.3020e+03*8*11.5;           % [mL]
LVwallvolume = 150;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2.2 Growth time course
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Timing
tTotal = 16*7;              % Total simulation time [days]
tScale = 3;                                    
tG = [-1 0 tScale:tScale:(tTotal/2)]'; tG = [tG; ((tG(end)+1):tScale:tTotal)']; 
Ng = length(tG);
iForward = 2:(round(Ng/2));         NForward = length(iForward);
iReversal = (round(Ng/2)+1):Ng;     NReversal = length(iReversal);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2.3 Hemodynamics and mechanical activation during growth
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

% Assign the values of SBV, Ras, and HR at each time step of the growth 
% simulation. This will overwrite the overlapping parameters of the CM.
% Any change in V0 due to growth will be added/substracted to SBV during 
% the growth simulation.

% Timing protocol
% iForward = 2:(round(Ng/2));         NForward = length(iForward);
% iReversal = (round(Ng/2)+1):Ng;     NReversal = length(iReversal);

% Hemodynamics
% SBVg = [SBV; repmat(300, [Ng-1 1])];
% Rasg = [Ras; repmat(1.08, [Ng-1 1])];
HRg = [89; linspace(95, 82, NForward)'; linspace(90, 92, NReversal)'];
MVBRg = repmat(resistances(7),  [Ng 1]); 
SBVg = [379; linspace(330,355,NForward)'; linspace(400,335,NReversal)'];
Rasg = [0.503; linspace(0.65,0.80,NForward)'; linspace(0.75,0.65,NReversal)'];

% HRg = repmat(89,Ng,1);
% SBVg = repmat(379,Ng,1);
% Rasg = repmat(0.503, Ng,1);

% Load mechanical activation maps with the chosen pacing location. This is
% the updated mechanical activation map from CRT011
% Load mechanical activation maps with the chosen pacing location. This is
% the updated mechanical activation map from CRT011
load('tActivation_C6_CRTLatMidwall')
tActivationg = zeros(21,Ng);
tActivationg(:,iForward) = repmat(tActivationLBBB, [1 NForward]);
tActivationg(:,iReversal) = repmat(tActivationCRT, [1 NReversal]);
tActivationg(:,1) = tActivationBaseline;
tActivationg = tActivationg*0.88;

% Ischemic compartments: compartment numbers, i.e. the row numbers of 
% tActivationg. Leave empty if no dyssynchrony + ischemia
ischemicCompartments = [];  
Ischemicg = zeros(size(tActivationg));            

% For option 1b: workspaces with e(t) curves for time-varying 
% elastance. Make sure the number of compartments/activation times is equal 
% in each workspace and timing points do not overlap
fEtg(1).fName = '~/Postdoc/data/fomovsky/etFunctionsHR101Smooth16Segment/etBaselineDENSE';
fEtg(1).timing = [-1 -1];
fEtg(2).fName = '~/Postdoc/data/fomovsky/etFunctionsHR101Smooth16Segment/etLBBB';
fEtg(2).timing = [0 tTotal];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2.4 Modified KOM model growth parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Choice of growth curve: modified KOM fitted by CMW (false) or true
% sigmoid fitted to modified KOM by Vignesh (true)
sigmoidSwitch = true;

% Growth parameters (from CMW et al. 2018)
if ~sigmoidSwitch
    f_ff_max=0.1*tScale;
    f_cc_max=0.1*tScale;
    f_f = 31;
    sl_50 = 0.215;
    r_f_neg = 576;
    negst_50 = 0.034;
    r_f_pos = 36.42;  posst_50=0.0971;
else
    % Growth parameters for a true sigmoid growth curve
    FfgmaxPos = 0.1*tScale;
    FfgmaxNeg = 0.03*tScale;
    nfPos = 3;    
    nfNeg = 9;   
    sl_50_pos = 0.075;
    sl_50_neg = 0.11;
    frRatio = 1;
end

% Work in progress, leave at 0 for now
wc = 0;         % Thickness growth direction, 0.5 = endo and epicardial
                %                               0 = epicardial only
                %                               1 = endocardial only


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2.5 Plot parameters for growth
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

% Reference state to calculate percent change (1 = control, 2 = acute)
refState = 1;

% Plot parameters
plotSwitchg = true;                                 % Make plots?
plotParsg.fSize = 18;                               % Font size
plotParsg.lWidth = 3;                               % Line width
plotParsg.mSize = 8;                                % Marker size
plotParsg.cMapName = 'plasma';                      % Colormap: parula, viridis, magma, plasma, inferno, or any Colorbrewer map
plotParsg.figType = '-dpdf';                        % Figure export type
plotParsg.plotShow = 'Off';                         % 'On' / 'Off'  Show plots?
plotParsg.cBarTitle = 'Days of growth';             % Colour bar title
plotParsg.plotTime = 7;                             % Plot time in days (=1) or weeks (=7)?
plotParsg.nColours = 10;                            % Number of colour levels for the colour bar
plotParsg.tLim = [tG(1)-1 ceil(tG(end)/10)*10];       % Axis limits from here on
plotParsg.dimLim = [-20 60];
plotParsg.dVOILim = [-10 10];
plotParsg.VLim = [40 150];                           % For PV loops only
plotParsg.pLim = [0 150];                           % For PV loops only          
plotParsg.FgLim = [0.9 1.4];
plotParsg.LVVLim = [0 20];
plotParsg.MALim = [0 80];
plotParsg.bgColour = [19 19 19]/255;                % Background colour for progress plots
plotParsg.fgColour = [1 1 1];                       % Foreground/txt colour for progress plots

end