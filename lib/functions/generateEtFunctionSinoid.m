function [etLV, etRV] = generateEtFunctionSinoid(tActivation, HR, nSteps, t0)



%% Create RV activation timing

t = linspace(0,60/HR, nSteps)';
Tes = 0.2*(60/HR)*(80/60);

etRV = zeros(nSteps,1);
etRV(t<=2*Tes) = 1/2*(1 - cos(pi * t(t<=2*Tes)/Tes));

% Shift time point of systole
etRV = circshift(etRV, round(t0*nSteps/max(t)));

%% Create LV activation timing curves

nCompartments = length(tActivation);

% Iniate curves
etLV = zeros(nSteps, nCompartments);

% Shift the e(t) curve for each compartment to start at its activation time
for iCompartment = 1:nCompartments
    etLV(:,iCompartment) = circshift(etRV, ...
        round(tActivation(iCompartment)/1000*nSteps/max(t)));
end