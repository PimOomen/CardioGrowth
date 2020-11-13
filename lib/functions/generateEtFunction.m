function [etLV, etRV] = generateEtFunction(...
                            tActivation, HRTarget, nSteps, fPVExp,...
                            VExpEt, pExpEt, HRExpEt, tSysChange,...
                            smoothFraction, fSave, t0)

                        
%% Load experimental data                        
                        
load(fPVExp, VExpEt, pExpEt, HRExpEt);

eval(strcat('VExp = ', VExpEt, ';'))
eval(strcat('pExp = ', pExpEt, ';'))
eval(strcat('HRExp = ', HRExpEt, ';'))

tExp = linspace(0, 60/HRExp, length(pExp))';

%% Generate experimental curve for RV

t = linspace(0, 60/HRTarget, nSteps)';

% Experimental e(t) is p/V, when min = 0, max = 1, and never going
% negative.
etRV = max(pExp./VExp - pExp(1)/VExp(1) - .01, 0);
etRV = etRV/max(etRV);
etRV = smooth(interp1(tExp, etRV, t),200);

% Shift time point of systole
etRV = circshift(etRV, round(t0*nSteps/max(t)));

%% Set heart rate
% Duration of systole remains unchanged when changing heart rate, so only
% change the time period of diastole

if ((~HRTarget) && (HRTarget ~= HRExp))

    % New time duration and current time step
    tEnd = (60/HRTarget);
    dt = mean(diff(t));

    if HRTarget < HRExp
        % Append diastole length to decrease heart rate
        t2 = [t(1:end-1); (t(end):dt:tEnd)'];
        etRV = [etRV(1:end-1); zeros(size((t(end):dt:tEnd)'))];
    elseif HRTarget > HRExp
        % Shorten diastole length
        t2 = t(t<tEnd);
        etRV = etRV(t<tEnd);
    end

    % Reinterpolate to desired number of time point
    t = linspace(0, tEnd, nSteps)';
    etRV = interp1(t2, etRV, t);

    HR = HRTarget;

end

%% Change systole duration

if (~isempty(tSysChange) && (tSysChange ~= 0))

    % Find end of systole
    [~,iMax] = max(etRV);
    iEnd = find(etRV(iMax:end)==0, 1, 'first') + iMax - 1;
    
    % Time and et only during systole (et > 0)
    etRVCompress = etRV(1:iEnd);
    tSys = t(1:iEnd);

    % Create time array with same number of points as original time array, but
    % adjusted time step to change the time duration of systole
    tCompress = linspace(0, tSys(end) + tSysChange*1e-3, length(tSys))';

    % Time step
    dt = mean(diff(tCompress));

    % Pad the remaining time and et arrays with zeros
    tCompressPadding = ((tCompress(end)+dt):dt:t(end))';
    tCompress = [tCompress; tCompressPadding];
    etRVCompress = [etRVCompress; zeros(size(tCompressPadding))];

    % Reinterpolate to the desired number of time points
    etRV = interp1(tCompress, etRVCompress, t);

end

% Remove Nan thay may occur at the beginning or end of the array
etRV(isnan(etRV)) = 0;


%% Smooth and renormalize

etRV = smooth(etRV, round(nSteps*smoothFraction));

etRV(etRV<0) = 0;
etRV = etRV/max(etRV);


%% For LV compartments

nCompartments = length(tActivation);

% Iniate curves
etLV = zeros(nSteps, nCompartments);

% Shift the e(t) curve for each compartment to start at its activation time
for iCompartment = 1:nCompartments
    etLV(:,iCompartment) = circshift(etRV, ...
        round(tActivation(iCompartment)/1000*nSteps/max(t)));
end


%% Save data

if ~isempty(fSave)

    save(fSave, 'etLV', 'etRV', 'tActivation', 'HR', 't');

    plotGenerator(t , [etLV etRV], [repmat("-", [size(etLV,2) 1]); "--k"], 'Off',  18, 8, 3,...
                  'Time (s)', 'e(t) (-)',   fSave,...
                  '-dpdf', [], [], [0 1], [], []);

    plotGenerator(t , gradient(etRV, t), "-", 'Off',  18, 8, 3,...
                  'Time (s)', 'e(t) (-)',   [fSave '_dedt'],...
                  '-dpdf', [], [], [], [], []);
              
end