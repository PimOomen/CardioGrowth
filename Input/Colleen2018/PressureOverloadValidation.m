%% User input for the compartmental model
%
%//////////////////////////////////////////////////////////////////////////
% Input file desciption
%//////////////////////////////////////////////////////////////////////////

% Vignesh Valaboju -- Replication of Witzenberg 2018 Pressure Overload
% Validation Study w/ Nagatomo Data 

% Vignesh's Lab Notebook: Replication of Colleen's Growth Simulations 


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
figDir = 'Output/POValidation';


%//////////////////////////////////////////////////////////////////////////
%% 1. COMPARTMENTAL MODEL
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1.1 Hemodynamics
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

HR = 101;            % Heart Rate [beats/min] (will be overwritten if using option 2b)
SBV = 366.0;           % Stresses blood volume
Ras = 1.11;         % Systemic arterial resistance (SVR in CMW paper)

% Capicitances (Cvp - Cas - Cvs - Cap) [ml/mmHg] from Santamore
% Cvp: Pulmonary venous compliance      Cas: Systemic arterial compliance
% Cvs: Systemic venous compliance       Cap: Pulmonary arterial compliance
capacitances = [3 1.02 17 2];

% Resistances (from Santamore) [mmHg * s/mL]
resistances = [0.015;...    % Rvp: pumonary venous resistance - resists return of blood to heart
               0.023;...    % Rcs: characteristic resistance - indicates stiffness of the aorta
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

% EDPVR & ESPVR parameters (note A & B are switched from Colleen's paper)
A = 0.057;                % Linear ED component [mmHg]
B = 0.090;                % Exponential ED component [1/mL] 
LVEes = 12.0;               % End-systolic elastance of LV [mmHg/mL]
V0 = 16.5;                 % End-systolic elastance of LV [mmHg/mL]

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
fPVExp = '';
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
etSinoid = true;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1.3 Pathologies/Interventions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

TriSeg.switch = false;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1.3 Pathologies/Interventions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Dyssynchrony (if using contraction options a or c), set as 0 if no
% dyssynchrony is to be simulated
tActivation = 0;

% Compartment number(s) that is/are ischemic, for use in combination with
% dyssynchrony in a 16-segment NYHA model. When only ischemia without 
% dyssynchrony, it will be ignored.
ischemicCompartments = [];

% Infarction size (LV fraction), set 0 if using LBBB-ischemia combination
infarctSize = 0.0;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1.4 Solver controls
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Solver settings
solverSettings.cutoff = 0.14;      % Convergence criterium
solverSettings.iterMax = 50;       % Maximum number of iterationsclear all
solverSettings.nSteps = 5000;      % Number of time steps during heart beat
                                   % (will be over-written if
                                   % time-varying elastance is chosen)

% Initial estimate for compartmental volumes, fraction of SBV. Weighting 
% compartments by average literature blood volume.
k = [0.1160    0.1538    0.1049    0.3588    0.1308    0.1357];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1.5 Plotting parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Will be ignored when using growth simulation
plotPars.cMapName = 'plasma';                   % Colorbrewer map name
plotPars.cBarTitle = 'Activation delay (ms)';   % Title of colour bar
plotPars.fSize = 18;                            % Font size
plotPars.lWidth = 3;                            % Line width
plotPars.mSize = 5;                             % Marker size
plotPars.figType = '-dpng';                     % Figure export type
plotPars.vLim = [];                        % Axis limits from here on
plotPars.pLim = [];                        %
plotPars.labLim = [1 2];                        %
plotPars.eps0Lim = [-0.3 0.2];                  %
plotPars.epsLim = [0 1];                        %
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

% LBBB data file containing experimental data (will be ignored for 
% non-dyssynchrony simulations)
fData = '~/Postdoc/data/Vernooy/VernooyDataFig4';

% If using a drug perturbation in between acute and growth, set this switch
% to true. Has not been used in while so may be outdated, check results!
drugSwitch = false;

% LV wall volume, determined such that the acute change in LV wall 
% thickness in the normal compartment matched reported values
LVwallvolume = 112.4045;           % [mL???]


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2.2 Growth time course
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Growth timing, always preceded by acute, control (and drug perturbation)
tTotal = 10;              % Total simulation time [days]
tScale = 1;                 % Number of days per growth step [days]

% Do not change this block, construct growth time vector, growth always 
% starts at t = 1, preceded by:
%   o No drugs: control is -1, acute is 0
%   o Drugs: control is -2, acute is -1, drug perturbation is 0
tG = [[-1 0]-drugSwitch 1:tScale:tTotal]';                
Ng = length(tG);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2.3 Hemodynamics and mechanical activation during growth
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

% Assign the values of SBV, Ras, HR, etc at each time step of the growth 
% simulation. This will overwrite the overlapping parameters of the CM.
% Any change in V0 due to growth will be added/substracted to SBV during 
% the growth simulation.

% Hemodynamics
SBVg = [366; repmat(456, [Ng-1 1])];
Rasg = [1.53; repmat(2.47, [12-1 1])];
maxpdivco = [1.9323 2.8413 3.1625 3.4836 3.8048 4.1259 4.4470 4.3235 4.2000 4.0765 3.9530 3.8295]; %calculated from colleens code from growth_circulation.m lines 77 to 82
ratioval_P_overload_validation = Rasg(2) / maxpdivco(2);
Rasg(3:end) = maxpdivco(3:end)*ratioval_P_overload_validation;
HRg = [87, interp1([0 5 10], [104 98 96], 0:10)]'; %HRs from NagatomoData3.xlsx
MVBRg = repmat(resistances(7), [Ng 1]);

% Mechanical activation - columns are time rows are compartments.
% N.B. The number of rows determines the numbers of compartments!
tActivationg = zeros(1, Ng);

% Ischemic compartments: compartment numbers, i.e. the row numbers of 
% tActivationg. Leave empty if no dyssynchrony + ischemia
ischemicCompartments = [];              

% For option 1b (see main CM): workspaces with e(t) curves for time-varying 
% elastance. Make sure the number of compartments/activation times is equal 
% in each workspace and timing points do not overlap
fEtg(1).fName = '~/Postdoc/data/fomovsky/etFunctionsHR101Smooth16Segment/etBaselineDENSE';
fEtg(1).timing = [-1 -1];
fEtg(2).fName = '~/Postdoc/data/fomovsky/etFunctionsHR101Smooth16Segment/etLBBB';
fEtg(2).timing = [0 tTotal];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2.4 Modified KOM model growth parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Growth parameters (from Witzenburg et al. 2018)
f_ff_max=0.1*tScale;
f_cc_max=0.1*tScale;
f_f = 31;
sl_50 = 0.215;
r_f_neg = 576;
negst_50 = 0.034;
r_f_pos = 36.42;  posst_50=0.0971;
% Work in progress, leave at 0 for now
wc = 0;         % Thickness growth direction, 0.5 = endo and epicardial
                %                               0 = epicardial only
                %                               1 = endocardial only

% % Sigmoid
% sigmoidSwitch = true;
% n = 5;
% sl_50 = 0.21;
% Ffgmax = 0.05;
% mp = 4.0827;
% mn = 11;
% st_50_pos = 0.0909;
% st_50_neg = 0.0366; 
% Frgmax = 0.1; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2.5 Plot parameters for growth
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

% Reference state to calculate percent change (1 = control, 2 = acute)
refState = 1;

% Plot parameters
plotSwitchg = true;                                 % Make plots?
vidSwitchg = false;                                 % Make video? (slow but cool)
plotParsg.kineSwitch = false;                        % Plot all kinematics history? Time and space-consuming
plotParsg.stimuliSwitch = true;
plotParsg.fSize = 18;                               % Font size
plotParsg.lWidth = 3;                               % Line width
plotParsg.mSize = 8;                                % Marker size
plotParsg.cMapName = 'plasma';                      % Colorbrewer colour map name
plotParsg.figType = '-dpng';                        % Figure export type
plotParsg.plotShow = 'Off';                         % 'On' / 'Off'  Show plots?
plotParsg.cBarTitle = 'Days of growth';             % Colour bar title
plotParsg.plotTime = 1;                             % Plot time in days (=1) or weeks (=7)?
plotParsg.nColours = 10;                            % Number of colour levels for the colour bar
plotParsg.tLim = [tG(1)-1 ceil(tG(end)/10)*10];       % Axis limits from here on
plotParsg.dimLim = [-inf inf];
plotParsg.dVOILim = [-10 10];
plotParsg.VLim = [-inf inf];                           % For PV loops only
plotParsg.pLim = [-inf inf];                           % For PV loops only
plotParsg.epsffLim = [0 1];                           
plotParsg.epsrrLim = [-0.2 0.1];                    
plotParsg.eps0Lim = [-0.2 0.15];                   
plotParsg.FgLim = [0.9 1.4];
plotParsg.LVVLim = [0 20];
plotParsg.bgColour = [19 19 19]/255;                % Background colour for progress plots
plotParsg.fgColour = [1 1 1];                       % Foreground/txt colour for progress plots

end



