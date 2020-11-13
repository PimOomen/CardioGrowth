function [fiber_strain, radial_strain]=   computing_stressandstrain(...
                                                        r, h, p, r0, h0)
%Inputs
%r - radius of the LV throughout the cardiac cycle:  normal compartment, total compartment, infarct compartment
%h - thickness of the LV throughout the cardiac cycle: normal compartment, total compartment, infarct compartment
%Remote_Pressure - pressure in the normal compartment
%r0 - unloaded LV radius: normal compartment, total compartment, infarct compartment
%h0 - unloaded LV thickness: normal compartment, total compartment, infarct compartment

%Outputs
%fiber_strain - circumferential strain throughout the cardiac cycle
%radial_strain - radial strain throughout the cardiac cycle
%hoopstress - hoop stress throughout the cardiac cycle



%% Calculating Current Ventricular Strain and Stress

r_strain = 0.5.*((r./r0).^2 - 1);
h_strain = 0.5.*((h./h0).^2 - 1);
fiber_strain = r_strain; 
% crossfiber_strain = r_strain;
radial_strain = h_strain;   
% hoopstress = p.*r./(2.*h);
    
end
