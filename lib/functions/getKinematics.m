function [lab, eps, eps0, Volumes, Pressures] = getKinematics(Volumes, Pressures,...
                                                                  LVPars, V0, simPars, Valves)


% Append volumes and pressure arrays with column of p and V of the total LV
Volumes(:,6+simPars.LVCompartments) = sum(Volumes(:,[2 7:7+simPars.LVCompartments-2]),2);
Pressures(:,6+simPars.LVCompartments) = Pressures(:,2);

chambers = [2 7:7+simPars.LVCompartments-1];

% Calculate stretch based on volumes
lab = getStretch(Volumes(:,chambers), [LVPars(:,4)' V0], 1);

% Calculate Green-Lagrange strain
eps = 0.5*(lab.^2 - 1);

% Compute 'clinical circumferential strain': reference state at ED
iED = find(diff(Valves(:,1))==-1, 1, 'first'); 
lab0 = lab./lab(iED,:);
eps0 = 0.5*(lab0.^2 -1);
