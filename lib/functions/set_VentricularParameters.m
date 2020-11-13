function [LVPars, RVPars] = set_VentricularParameters(simPars, RVScale, pars)

% Set material parameters for each ventricle and compartment based on
% overall LV parameters given as user input (assembled in 'pars')

% Material parameters indices
% 1 - A
% 2 - B
% 3 - E
% 4 - V0
% 13 - t0

% Set RV parameters (scale maximum contraction of RV with respect to LV)
RVPars = pars;
RVPars(3) = RVScale*RVPars(3);


% Initialize LV parameter array
LVPars = repmat(pars, [simPars.LVCompartments 1]);

% Set V0 (and activation timing for dyssynchrony)
if (simPars.infarctSize == 0)
    LVPars(:,4) = LVPars(:,4)/simPars.LVCompartments;
    % Activation time of each compartment
    LVPars(:,5) = LVPars(:,end) + simPars.tActivation/1000;      % [s]
elseif (simPars.infarctSize > 0)
    LVPars(1,4) = LVPars(1,4)*(1-simPars.infarctSize);
    LVPars(2,4) = LVPars(2,4)*(simPars.infarctSize);
end

% Adjust B and E to maintain EDPVR and ESPVR despite the compartment volume
% changes
LVPars(:,2) = LVPars(:,2).*pars(4)./LVPars(:,4);
LVPars(:,3) = LVPars(:,3).*pars(4)./LVPars(:,4); 


end
