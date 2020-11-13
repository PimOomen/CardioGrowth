%Growth Law
function [r0_new, h0_new,  Fg_new, st, sl]=GrowthLaw_modifiedKOM( r0, h0, r, h, Fg_old,...
                                growthPars, ischemicCompartments, sigmoidSwitch) 

%Inputs:
%r0 - current unloaded LV radius: normal compartment, total compartment, infarct compartment
%h0 - current unloaded LV thickness: normal compartment, total compartment, infarct compartment
%r - radius of the LV throughout the cardiac cycle:  normal compartment, total compartment, infarct compartment
%h - thickness of the LV throughout the cardiac cycle: normal compartment, total compartment, infarct compartment
%Fg_old - current growth deformation tensor
%growthparams - vector containing the growth parameters

%Outputs:
%r0_new - new unloaded LV radius: normal compartment, total compartment, infarct compartment
%h0_new - new unloaded LV thickness: normal compartment, total compartment, infarct compartment
%Fg_new - new growth deformation tensor
%st - current stimulus for thickening
%sl - current stimulus for lengthening

%% This function determines the new grown unloaded dimensions of the LV

% Current Loading (stored in final dimension of r and h)
% Calculate the total stretch within the LV in each compartment, note that 
% the reference configuration is the original unloaded radius and thickness 
r_stretch = r(:,:,end)./r0(1,:);
h_stretch = h(:,:,end)./h0(1,:);

% Calculate the elastic fiber and radial stretches and strains where 
% Fe = F * Fg^-1
fiber_stretch  = r_stretch./squeeze(Fg_old(1,1,:))';
radial_stretch = h_stretch./squeeze(Fg_old(3,3,:))';
fiber_strain = 0.5*(fiber_stretch.^2 - 1);
radial_strain = 0.5*(radial_stretch.^2 - 1);

% Determining Growth Set Points    
% Determine growth setpoint values. The set points are unknown. We will use
% the "normal" values from the initial run of the circuit model.
r_stretch_baseline = (r(:,:,1)./r0(1,:));
h_stretch_baseline = (h(:,:,1)./h0(1,:));
fiber_strain_baseline  = 0.5*(r_stretch_baseline.^2 - 1);
radial_strain_baseline = 0.5*(h_stretch_baseline.^2 - 1);

setpoints(1,:) = max(fiber_strain_baseline);
setpoints(2,:) = max(radial_strain_baseline);

% Stimulus functions
sl = max(fiber_strain) -setpoints(1,:);
st = -(max(radial_strain)-setpoints(2,:));


%% Ischemia: no growth in scar

sl(ischemicCompartments) = 0;
st(ischemicCompartments) = 0;


%% MODIFIED GROWTH LAW FOR SPHERE 

Fgi = zeros(size(Fg_old));

% Modified KOM, fit to PO and VO fitting simulations by CMW
if ~sigmoidSwitch

    % Growth Law Constants
    f_f = growthPars(1);          sl_50 = growthPars(2);
    c_fpos = growthPars(3);       c_fneg = growthPars(4);
    st_50pos = growthPars(5);     st_50neg = growthPars(6);
    f_ff_max = growthPars(7);     f_cc_max = growthPars(8);
    wc = growthPars(9);

    % Fiber direction, eq 8
    Fgi(1,1,:) = (sl>0).*sqrt(   f_ff_max ./ (1+exp(-f_f.*(sl-sl_50)) ) +1 ) + ...
                 (sl<0).*sqrt(  -f_ff_max ./ (1+exp( f_f.*(sl+sl_50)) ) +1 ) + ...
                 (sl==0);         

    % radial direction        
    Fgi(3,3,:)= (st>0).*(  f_cc_max ./ (1+exp(-c_fpos.*(st-st_50pos)) )+1 ) + ...
              (st<0).*( -f_cc_max ./ (1+exp( c_fneg.*(st+st_50neg)) )+1 ) + ...
              (st==0);  %eqn 9     
          
% Modified modified KOM: true sigmoid curve fitted by Vignesh to the 
% modified KOM growth curve that CMW fitted to PO and VO         
else   
    
    % Fitted parameters, to be included in input file
    % n = 5;
    % sf50 = 0.21;
    % Ffgmax = 0.05;
    % mp = 4.0827;
    % mn = 11;
    % sr50_pos = 0.0909;
    % sr50_neg = 0.0366; 
    % Frgmax = 0.1;
    
    n = growthPars(1);          sl_50 = growthPars(2);
    Ffgmax = growthPars(3);     mp = growthPars(4);
    mn = growthPars(5);         st_50pos = growthPars(6);
    st_50neg = growthPars(7);   Frgmax = growthPars(8);
    wc = growthPars(9);
    
    % If n is odd, s50 is to be subtracted rather than added in the
    % denominator of the sigmoid in the reversal part (s<0)
    isodd = 1 - (rem(n,2)==1)*2;
    
    % Circumferential direction
    Fgi(1,1,:) = (sl>0) .* (sl.^n ./ (sl.^n + sl_50.^n) .* Ffgmax + 1) +...
             (sl<0) .* (-sl.^n ./ (sl.^n + isodd*sl_50.^n) .* Ffgmax + 1) +...
             (sl==0);

    % Radial direciton 
    Fgi(3,3,:) = (st>0) .* (st.^mp ./ (st.^mp + st_50pos.^mp) .* Frgmax + 1) +...
                 (st<0) .* (-st.^mn ./ (st.^mn + isodd*st_50neg.^mn) .* Frgmax + 1) +...
                 (st==0);
    
end    

% Eq 10 modified - cross-fiber and fiber growth stretches are the same and 
% radial growth stretch is different
Fgi(2,2,:) = Fgi(1,1,:); 

Fg_new = Fgi .* Fg_old;

%% Calculate the new unloaded geometry  - note that the reference is the original unloaded state  

% New wall thickness
h0_new = h0(1,:).*squeeze(Fg_new(3,3,:))';

% New unloaded cavity radius
% NEW (not in Colleen's paper): wall thickness change can influence cavity 
% radius. Wall coupling can be:
%   wc = 0.5        equal growth in endo and epicardial directions
%   wc = 0          only growth in the epicardial directions, unloaded wall
%                   thickness does not influence unloaded cavity volume
%   wc = 1         only growth in the endocardial direction
r0_new = r0(1,:).*squeeze(Fg_new(1,1,:))' - wc.*h0(1,:).*(squeeze(Fg_new(1,1,:))' - 1);
 

   
end

