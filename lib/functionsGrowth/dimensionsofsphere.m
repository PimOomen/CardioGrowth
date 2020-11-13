function [r, h]=dimensionsofsphere(V, r0, h0)

% Inputs:
% V  - Volumes of healthy LV region(s)
% r0 - unloaded LV radius
% h0 - unloaded LV thickness

%Outputs: 
%r - radius of the healthy LV region(s) throughout the cardiac cycle
%h - thickness of the healthy LV region(s) throughout the cardiac cycle


%% Calculating the Dimensions of the LV

%Radius and Thickness (isochoric) of the LV healthy region(s)
r = (0.75.*V.*(1./pi)).^(1/3); 

% See Pim's NB 'Wall Thickness' for derivation of wall thickness. Constant
% wall volume (incompressibility) is wall assumed
h = ( h0.^3 + 3.*h0.^2 .* r0 + 3.*h0.*r0.^2 + r.^3 ).^(1./3) - r;


end



