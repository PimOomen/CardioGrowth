function [sigma_ED, sigma_ES, strainc,  ees, a, b] = ...
                calculate_stress_strain_relationships(LVParsi, r0, h0, t)
%Inputs:
%LV_param - ED and ES LV parameters for the normal compartment 
%r0 - unloaded LV radius: normal compartment, total compartment, infarct compartment
%h0 - unloaded LV thickness: normal compartment, total compartment, infarct compartment

%Outputs:
%sigma_ED - ED hoop stress as LV is inflated
%sigma_ES - ES hoop stress as LV is inflated
%strainc - circumferential strain as LV is inflated
%ees - intrinsic contractility of the ventricle, material parameter
%a and b - intrinsic parameters governing the passive behavior of the ventricle, material parameters 

%% Determining the ED and ES stress-strain relationships of the myocardium

% Flip direction if only one compartment
if (size(LVParsi,2) == 1)
    LVParsi = LVParsi';
end

nCompartments = size(LVParsi,1);

% Set up inflation of LV to a stretch of max 2
V_test = repmat(linspace(0,2^3*min(LVParsi(:,4)),5000)', [1 nCompartments]);  
r_test = (0.75*V_test*(1/pi)).^(1/3);
h_test= ( h0.^3 + 3.* h0.^2 .* r0 + 3* h0.* r0.^2 + r_test.^3).^(1/3) - r_test; %ischoric, page 26 CMW notebook 5  

% Set up isometric contraction
V_iso = 1.28^3*LVParsi(:,4)';               % Using stretch = (V/V0)^1/3
r_iso = (0.75*V_iso*(1/pi)).^(1/3);
h_iso = (  h0.^3 + 3.*h0.^2.*r0 + 3.* h0.* r0.^2 + r_iso.^3).^(1/3)-r_iso;
t_test = linspace(0,t(end), 5000)';

PES = (  LVParsi(3)*(V_test-LVParsi(4))  ); %ESPVR
PED = (  LVParsi(1)* ( exp(  LVParsi(2)*(V_test-LVParsi(4))  )  -1)  );       %EDPVR 
sigma_ES = (PES.*r_test./(2*h_test))';


%Determine the hoop stress to circumferential strain relationship assuming a thin walled sphere
sigma_ED = (PED.*r_test./(2.*h_test))*0.133;

stretch = r_test./r0;
strainc = (0.5.*(stretch.^2-1));

%% Calculate the Material parameters of the Sphere using the Stress-Stretch Equations:
%sigma_ED_hoop = (r/r0)*(h0/h)*[ exp( a*( (r/r0)^3-1 ) ) - 1 ] * b 
%where b = B/2* r0/h0 and a = A *4/3pi*r0^3
%sigma_ES_hoop = (r/r0)*(h0/h)*( (r/r0)^3-1  ) * ees
%where ees=EES*2/3*pi* (r0^4/h0)
%thus parameters with lowercase letters indicate material parameters and
%those with UPPERCASE letters indicate pressure-volume parameters
%see CMW notebook 6 pages 76-79 for more info
 
% Time-varying elastance 
a   = LVParsi(:,1)'.*r0./(2.*h0);
b   = LVParsi(:,2)'.*4./3.*pi.*r0.^3;
ees = LVParsi(:,3)'.*2./3.*pi.*(r0.^4./h0);  



end