function [Volumes, t, detLV] ...
          = set_initialconditions(simPars, HR, SBV, k, solverSettings, ...
                                  growthSwitch, growthIni, etLV, LVPars,...
                                  TriSeg)
         
% Calculate initial circulation and ventricle compartments' volumes and set
% time array

%   Volume columns
%   1           pulmonary veins                 
%   2           left ventricle compartment 1        
%   3           systemic arteries            
%   4           systemic veins               
%   5           right ventricle                 
%   6           pulmonary arteries
%   7 - end     additional left ventricle compartments


%% Initialize Timing

nSteps = solverSettings.nSteps;             % Number of time steps [-]
t = linspace(0, 60/HR, nSteps)';            % Time vector [s]


%% Compute time derivative of et(t) if using time-varying elastance                                  

nCompartments = size(etLV,2);
detLV = zeros(nSteps, nCompartments);

for i = 1:nCompartments
    detLV(:,i) = gradient(etLV(:,i), t);
end


%% Initializing Volumes 

% Add multicompartmental LV if no TriSeg
Volumes = zeros(nSteps,6 +~TriSeg.switch*(simPars.LVCompartments-1));   

% Apply weight factors
Volumes(1,1:length(k)) = k.*SBV; 

% For multicompartmental approach (MI or dyssynchrony, recalculate 
% initial LV volumes. During growth simulations (after initialization), 
% skip this block as this is covered by the k that is passed in the CM from
% the growth code to dramatically decrease convergence time
if (~TriSeg.switch)
    Volumes(1,[2 7:(5+simPars.LVCompartments)]) = Volumes(1,2).*LVPars(:,4)./sum(LVPars(:,4));
end

    


end