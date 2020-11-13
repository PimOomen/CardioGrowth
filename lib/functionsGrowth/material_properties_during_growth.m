function [ees, a, b, LVParsg, RVParsg]=material_properties_during_growth( ...
                                        ees_in, a_in, b_in, ...
                                        LVParsg, RVParsg, iG, iGMax)
%Input:
%ees_in - intrinsic contractility of the ventricle, material parameter
%a_in and b_in - intrinsic parameters governing the passive behavior of the ventricle, material parameters 
%LVInfarct_param_in - ED and ES LV parameters for the infarct compartment
%iteration_growth_max - final time step in the model note that this is 4 more than the day since we have control, MI and MI+drug conditions

%Output:
%ees - intrinsic contractility of the ventricle, material parameter, for the entire simulation
%a and b - intrinsic parameters governing the passive behavior of the ventricle, material parameters, for the entire simulation
%LVInfarct_param - ED and ES LV parameters for the infarct compartment for the entire simulation


%% Within this function the material properties of the LV during growth are prescribed

%Holding Material Properties Constant

% Set constant constitutive properties for the healthy compartment
ees = [ees_in; repmat(ees_in(end,:), [iGMax - iG 1])];
a   = [a_in;   repmat(a_in(end,:),   [iGMax - iG 1])];
b   = [b_in;   repmat(b_in(end,:),   [iGMax - iG 1])];

% Preset the p-V parameters for all compartments, subject to change during
% subsequent growth steps
LVParsg(iG+1:end,:,:) = repmat(LVParsg(iG,:,:), [iGMax-iG 1]);
RVParsg(iG+1:end,:) = repmat(RVParsg(iG,:), [iGMax-iG 1]);



end
