%Growth Law
function [r0_new, h0_new,  Fg_new, st, sl]=GrowthLaw_modifiedKOM_isotropic( r0, h0, r, h, Fg_old,...
                                growthPars, ischemicCompartments, sigmoidSwitch, tScale) 

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

% setpoints(1,:) = max(fiber_strain_baseline);
% setpoints(2,:) = max(radial_strain_baseline);
% 
% % Stimulus functions
% sl = max(fiber_strain) -setpoints(1,:);
% st = -(max(radial_strain)-setpoints(2,:));


%% Evolving setpoint setpoints

% Determining Growth Set Points    
% Determine growth setpoint values. calculate history of radial/circ strain.

% Undeformed radius and wall thickness at each growth iteration, assign to
% array with equal dimensions to r and h: (1) cardiac cycle time points (2)
% number of compartments (3) number of growth steps performed thus far
r0_hist = repmat(r0(1:nnz(r0(:,1)),:)', [1 1 size(r,1)]);
h0_hist = repmat(h0(1:nnz(h0(:,1)),:)', [1 1 size(r,1)]);
r0_hist = permute(r0_hist, [3 1 2]);
h0_hist = permute(h0_hist, [3 1 2]);

r_stretch_hist = r./r0_hist;
h_stretch_hist = h./h0_hist;
fiber_strain_hist  = 0.5*(r_stretch_hist.^2 - 1);
radial_strain_hist = 0.5*(h_stretch_hist.^2 - 1);
maxEffhist = squeeze(max(fiber_strain_hist,[],1))';
maxErrhist = squeeze(max(radial_strain_hist,[],1))';

% Construct fading memory, dimensions: (1) growth time (2) compartments
NCompartments = size(r0,2);                 % Number of compartments
Nw = 3*15*round(3/tScale);                  % Length of weighting function
w0 = [1:ceil(Nw/2) floor(Nw/2):-1:1]';      % Weighting functiong
w0 = w0/sum(w0);                            % Normalized weighting function
w = repmat(w0, [1 NCompartments]);          % Weighting function for all compartments

Lhist = size(maxEffhist,1);
Lw = size(w,1);

if Lhist<Lw
    % Repeat initial max strain back in time to create enough time points
    % for weighing
    setpoints(1,:) = dot(w,[maxEffhist(1,:).*ones(Lw - Lhist, NCompartments); maxEffhist]);
    setpoints(2,:) = dot(w,[maxErrhist(1,:).*ones(Lw - Lhist, NCompartments); maxErrhist]);
else
    setpoints(1,:) = dot(w,maxEffhist(end-(Lw-1):end,:));
    setpoints(2,:) = dot(w,maxErrhist(end-(Lw-1):end,:));
end

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
    
    FfgmaxPos = growthPars(1);
    FfgmaxNeg = growthPars(2);
    nfPos = growthPars(3);    
    nfNeg = growthPars(4);
    sl_50_pos = growthPars(5);
    sl_50_neg = growthPars(6);
    frRatio = growthPars(7);
    wc = 0;
    
    % If n is odd, s50 is to be subtracted rather than added in the
    % denominator of the sigmoid in the reversal part (s<0)
    isodd = 1 - (rem(nfNeg,2)==1)*2;
    
    % In-plane direction
    Fgi(1,1,:) = (sl>0) .* sqrt( sl.^nfPos ./ (sl.^nfPos + sl_50_pos.^nfPos) .* FfgmaxPos + 1) +...
                 (sl<0) .* sqrt(-sl.^nfNeg ./ (sl.^nfNeg + isodd*sl_50_neg.^nfNeg) .* FfgmaxNeg + 1) +...
                 (sl==0);

%     %Radial direciton 
%     Fgi(3,3,:) = (st>0) .* (st.^mp ./ (st.^mp + st_50pos.^mp) .* Frgmax + 1) +...
%                  (st<0) .* (-st.^mn ./ (st.^mn + isodd*st_50neg.^mn) .* Frgmax + 1) +...
%                  (st==0);
    
end    

% Eq 10 modified - cross-fiber and fiber growth stretches are the same and 
% radial growth stretch is different
Fgi(2,2,:) = Fgi(1,1,:);

% Radial growth
Fgi(3,3,:) = frRatio*(Fgi(1,1,:)-1)+1;  %0.5

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

