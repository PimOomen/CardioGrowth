clear all, close all

% Generate a vector for a time-varying elastance curve e(t)

% Pim J.A. Oomen, March 2019


%% Generate a vector for a time-varying elastance curve e(t)

% Save path (can be created in this script)
dirEt = '~/Postdoc/data/fomovsky/etFunctionsHR101Smooth16Segment/';

% Use this when you want to change the heart rate from the experimental
% data, set to [] when not used
HRTarget = 101;                   % [min^-1]

% Activation timing
tActivation = 0;                  % [ms]

% Simulation type:  0 for infarct 1 for dyssynchrony
% NB Healthy heart is dyssynchrony with only 1 compartment and 0 offset.
simType = 1;

% Change the duration of systole (Compression < 0, Extension > 0)
% Used when LBBB is involved: total P/V will reflect overall LV activation,
% not the individual compartments. All individual will be compressed or 
% extended by the time given here and padded with zeros. Typically, use the
% time of max mechanical activation delay to compress the single activation 
% curve. Set to 0 or leave empty [] to not use this
tSysChange = 0;          % [ms]

% Smoothing degree (fraction of total number of time steps), important to 
% prevent discontinuities in the CM solver
smoothFraction = 0.1;

% Default number of time steps
nSteps = 5000;

% Case-specific information from here on

% Workspace and plot file name
cases(1).name = 'etBaseline';
cases(2).name = 'etBaselineDENSE';
cases(3).name = 'etLBBB';
cases(4).name = 'etBaselineGrowth';
cases(5).name = 'etMI';
cases(6).name = 'etBaselineDENSE5';  
cases(7).name = 'etBaselineDENSE15';
cases(8).name = 'etBaselineDENSE20';

nCases = length(cases);

% Set default values (Target HR, activation timing, time steps and sim type)
r = num2cell(repmat(HRTarget, [1,nCases]));         [cases.HRTarget] = deal(r{:});
r = num2cell(repmat(tActivation, [1,nCases]));      [cases.tActivation] = deal(r{:});
r = num2cell(repmat(simType, [1,nCases]));          [cases.simType] = deal(r{:});
r = num2cell(repmat(nSteps, [1,nCases]));           [cases.nSteps] = deal(r{:});

% Ativation timing 16-segment (default is 0) [ms]
cases(3).tActivation = [2 0 0 8 44 35 20 2 5 35 59 51 39 6 52 63]';          
cases(2).tActivation = 0.10*cases(3).tActivation;         
cases(4).tActivation = zeros(16,1);              
cases(6).tActivation = 0.05*cases(3).tActivation;  
cases(7).tActivation = 0.15*cases(3).tActivation;  
cases(8).tActivation = 0.20*cases(3).tActivation; 

% Number of time steps (default is 5000)
% cases(2).nSteps = 10000;

% Set two MI cases
cases(9).simType = 0;             cases(10).simType = 0;

% Fomovsky
% Load experimental data
load('~/Postdoc/data/fits/normalizedPVlabED1.28/wkspMeanBaseline', 'VMean', 'pMean', 'HR');

% Beloved dog 6
% load('~/Postdoc/data/canineLBBB/CRT006/CRT006Week_1', 'V', 'p', 'HR');
% pMean = p;
% VMean = V;


%% Preamble

addpath(genpath('functionsUtil'))

if ~isfolder(dirEt); mkdir(dirEt); end


%% Main loop

tExp = linspace(0, 60/HR, length(pMean))';

for iCase = 1:nCases
    
    tActivation = cases(iCase).tActivation;

    %% Generate experimental curve for RV

    t = linspace(0, 60/HR, cases(iCase).nSteps)';

    % Experimental e(t) is p/V, when min = 0, max = 1, and never going
    % negative.
    etRV = max(pMean./VMean - pMean(1)/VMean(1) - .01, 0);
    etRV = etRV/max(etRV);
    etRV = smooth(interp1(tExp, etRV, t),200);


    %% Set heart rate
    % Duration of systole remains unchanged when changing heart rate, so only
    % change the time period of diastole

    if ((~isempty(cases(iCase).HRTarget)) && (cases(iCase).HRTarget ~= HR))

        % New time duration and current time step
        tEnd = (60/cases(iCase).HRTarget);
        dt = mean(diff(t));

        if cases(iCase).HRTarget < HR
            % Append diastole length to decrease heart rate
            t2 = [t(1:end-1); (t(end):dt:tEnd)'];
            etRV = [etRV(1:end-1); zeros(size((t(end):dt:tEnd)'))];
        elseif cases(iCase).HRTarget < HR
            % Shorten diastole length
            t2 = t(t<tEnd);
            etRV = etRV(t<tEnd);
        end

        % Reinterpolate to desired number of time point
        t = linspace(0, tEnd, cases(iCase).nSteps)';
        etRV = interp1(t2, etRV, t);

        HR = cases(iCase).HRTarget;

    end

    %% Change systole duration

    if (~isempty(tSysChange) && (tSysChange ~= 0))

        % New time duration and current time step
        tEnd = (60/cases(iCase).HRTarget);

        etRVSys = etRV;
        tSys = t;

        % Create time array with same number of points as original time array, but
        % shorter duration, then add time points
        tCompress = linspace(0, tSys(end) + tSysChange*1e-3, length(tSys))';

        % Time step
        dt = mean(diff(tCompress));

        % Pad the remaining et with zeros
        tCompressPadding = ((tCompress(end)+dt):dt:t(end))';
        tCompress = [tCompress; tCompressPadding];
        etRVCompress = [etRVSys; zeros(size(tCompressPadding))];

        % Reinterpolate to the desired number of time points
        etRV0 = etRV;
        etRV = interp1(tCompress, etRVCompress, t);

    else
        etRV0 = etRV;
    end

    % Remove Nan thay may occur at the beginning or end of the array
    etRV(isnan(etRV)) = 0;


    %% Smooth and renormalize

    etRV = smooth(etRV, round(cases(iCase).nSteps*smoothFraction));
    
    etRV(etRV<0) = 0;
    etRV = etRV/max(etRV);
    
    etRV0(etRV0<0) = 0;
    etRV0 = etRV/max(etRV0);

    %% For dyssynchrony, offset curves

    nCompartments = length(tActivation);

    % For dyssynchrony (or healthy if LVCompartments=1)
    if cases(iCase).simType

        % Iniate curves
        etLV = zeros(cases(iCase).nSteps, nCompartments);

        % Shift the e(t) curve for each compartment to start at its activation time
        for iCompartment = 1:nCompartments
            etLV(:,iCompartment) = circshift(etRV, ...
                round(tActivation(iCompartment)/1000*cases(iCase).nSteps/max(t)));
        end

    % For infarct    
    else
        etLV(:,1) = etRV;
        etLV(:,2) = zeros(size(etRV));
    end


    %% Save data

    save(fullfile(dirEt, cases(iCase).name), 'etLV', 'etRV', 'tActivation', 'HR', 't');

    plotGenerator(t , [etLV etRV0], [repmat("-", [size(etLV,2) 1]); "--k"], 'Off',  18, 8, 3,...
                  'Time (s)', 'e(t) (-)',   fullfile(dirEt, cases(iCase).name),...
                  '-dpdf', [], [0 1], [], [], []);

    plotGenerator(t , gradient(etRV, t), "-", 'Off',  18, 8, 3,...
                  'Time (s)', 'e(t) (-)',   fullfile(dirEt, [cases(iCase).name '_dedt']),...
                  '-dpdf', [], [], [], [], []);
              
    % Clear etLV to prevent appending data to previous iterations when MI
    clear etLV
       
end         % End of main loop   
          
% %% Smooth
% 
% etRV = smooth(etRV, 1000);
% 
% for i = 1:size(etLV,2)
%     etLV(:,i) = smooth(etLV(:,i), 1000);
%     etLV(:,i) = etLV(:,i)/max(etLV(:,i));
% end

% %% Generate sinosoid e(t) for RV
%     
% % Construct time-varying elastance curve
% t = linspace(0, 60/HR, nSteps)';
% etRV = zeros(nSteps,1);
% etRV(t < Tes) = 1/2 * (1 - cos(pi * t(t < Tes)  / (0.5*Tes) ));
