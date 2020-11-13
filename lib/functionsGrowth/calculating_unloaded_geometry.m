function [Fg, st, sl, r0, h0]= calculating_unloaded_geometry(Vwall, Ng, LVPars)
%Inputs:
%V0tot - unloaded volume of the total LV
%IS - infarct size
%Vwall - mass of the LV wall
%GrowthTime - days to simulate growth

%Outputs:
%iteration_growth_max - final time step in the model note that this is 4 
% more than the day since we have control, MI and MI+drug conditions
%Fg - growth deformation tensor
%st - thickening stimulus
%sl - lengthening stimulus
%r0 - unloaded LV radius: normal compartment, total compartment, infarct compartment
%h0 - unloaded LV thickness: normal compartment, total compartment, infarct compartment


%% Initializing Growth 

% Number of compartments
nCompartments = size(LVPars,1);

% Initialize growth tensors and stimuli
Fg = zeros(3,3,Ng, nCompartments);
st = zeros(Ng,nCompartments, 1);
sl = zeros(Ng,nCompartments, 1);

% Set Fg in the first two iterations as the identity tensor
Fg(:,:,1,:) = repmat(eye(3,3), [1 1 nCompartments]); 
Fg(:,:,2,:) = repmat(eye(3,3), [1 1 nCompartments]); 

% Determine V0
V0 = LVPars(:,4)';

%Determining initial (ungrown) r0 for each compartment
r0 = zeros(Ng, nCompartments); 
r0(1,:) = (3/(4*pi)*V0).^(1/3) ;

%Determining h0 for all compartments (see PJO NB "Wall thickness" for a
%derivative of this calculation. 
h0 = zeros(Ng,nCompartments);
h0(1,:) = (r0(1,:).^3 + Vwall.*3./(4.*pi).*(V0./sum(V0))).^(1/3) - r0(1,:);


end