function [LV_params_new] = Recomputing_LV_params( r0, h0,  a, b, ees)
%Inputs:
%r0 - current unloaded LV radius: normal compartment, total compartment, infarct compartment
%h0 - current unloaded LV thickness: normal compartment, total compartment, infarct compartment
%a and b - intrinsic parameters governing the passive behavior of the ventricle, material parameters 
%ees - intrinsic contractility of the ventricle, material parameter

%Outputs:
%LV_params_new - Updated pressure-volume LV parameters for the normal compartment

%% Computing the altered LV pressure-volume behavior assuming no change (or
%prescribed changes) in the LV hoop stress - circumferential strain
%behavior

%Since we treated the ventricle as a thin-walled spherical pressure vessel the relationship between hoop stress and LV volume at end-systole and end-diastole are 
%?_hoop,ED=P_ED*r_ED/(2h_ED ) and ?_hoop,ES=P_ES*r_ES/(2h_ES )   or
%?_hoop,ED=r_ED/(2h_ED )*B*(exp[A*(V_ED-V_0 )]-1) and ?_hoop,ES=r_ES/(2h_ES )*E*(V_ES-V_0 )

%If we reframe this equation using the unloaded radius and thickness then
%?_hoop,ED=r_ED/r0*h0/h_ED*b*(exp[a*(r_ED/r0)^3-a]-1) and ?_hoop,ES=r_ES/r0*h0/h_ES*e*((r_ES/r0)^3 -1)

%If r0 and h0 are the current unloaded dimensions then this is hoop stress as a function of elastic stretch since Feg = Fe * 1/Fg. 
%In the spherical context Feg = r/r0_initial, thus Fe = r/r0_initial *1/Fg_current.
%But, Fg_current = r0_current/r0_initial so Fe = r/r0_initial * r0_initial/r0_current = r/r0_current
%Thus, in order to calculate the elastic stretch we just divid the loaded radius by the current unloaded radius
%Then the material constants a, b, and e can be used to determine the new
%values of A, B, and E when the unloaded LV grows


%Unloaded LV Volume (ml)
V0 = 4/3*pi*r0.^3;

%LV exponential constant in EDPVR  (1/ml)
B = b.*3./(4.*pi)./(r0.^3);

%LV End-systolic elastance (mmHg/ml)
EES = 3./(2.*pi).*ees.*h0.*(1./r0.^4);

%LV linear constant in EDPVR (mmHg)
A  = a.*2.*h0./r0;


% Assemble
LV_params_new = [A' B' EES' V0'];


end

