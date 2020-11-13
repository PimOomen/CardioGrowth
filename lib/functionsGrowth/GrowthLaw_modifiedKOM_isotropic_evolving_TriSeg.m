function [h0_new, Fg_new, st, sl, TriSeg] = GrowthLaw_modifiedKOM_isotropic_evolving_TriSeg(...
                        h0, Fg_old, growthPars,...
                        sigmoidSwitch, tScale, labfg, labrg, TriSeg, iG)
                               

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

% Calculate the current elastic fiber and radial strains
fiber_strain = 0.5*(labfg(:,:,iG-1).^2 - 1);
radial_strain = 0.5*(labrg(:,:,iG-1).^2 - 1);


%% Evolving setpoint setpoints

% Determining Growth Set Points    
% Determine growth setpoint values. calculate history of radial/circ strain.

% Undeformed radius and wall thickness at each growth iteration, assign to
% array with equal dimensions to r and h: (1) cardiac cycle time points (2)
% number of compartments (3) number of growth steps performed thus far
fiber_strain_hist  = 0.5*(labfg(:,:,1:iG-1).^2 - 1);
radial_strain_hist = 0.5*(labrg(:,:,1:iG-1).^2 - 1);
maxEffhist = squeeze(max(fiber_strain_hist,[],1))';
maxErrhist = squeeze(max(radial_strain_hist,[],1))';

% Construct fading memory, dimensions: (1) growth time (2) compartments
NCompartments = TriSeg.NPatchesTot;                 % Number of compartments
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

%% Stimulus functions
% Ischemic areas don't grow, partially ischemic regions' stimulus is
% proportional to non-ischemic fraction.

sl = (max(fiber_strain) -setpoints(1,:)).*(1-TriSeg.Ischemic);
st = -(max(radial_strain)-setpoints(2,:)).*(1-TriSeg.Ischemic);


%% MODIFIED GROWTH LAW FOR SPHERE 

Fgi = zeros(size(Fg_old));

% Modified KOM, fit to PO and VO fitting simulations by CMW
if ~sigmoidSwitch

    % Growth Law Constants
    f_f = growthPars(1);          sl_50 = growthPars(2);
    c_fpos = growthPars(3);       c_fneg = growthPars(4);
    st_50pos = growthPars(5);     st_50neg = growthPars(6);
    f_ff_max = growthPars(7);     f_cc_max = growthPars(8);
    frRatio = 1;

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
    
%     FtgmaxPos = 0.5*growthPars(1);
%     FtgmaxNeg = growthPars(2);
%     ntPos = growthPars(3);    
%     ntNeg = growthPars(4);
%     st_50_pos = growthPars(5);
%     st_50_neg = growthPars(6);
    
    % If n is odd, s50 is to be subtracted rather than added in the
    % denominator of the sigmoid in the reversal part (s<0)
    isodd = 1 - (rem(nfNeg,2)==1)*2;
    
    % In-plane direction. Scale with degree of ischemia for partially 
    % ischemic compartments
    Fgi(1,1,:) = ((sl>0) .* sqrt( sl.^nfPos ./ (sl.^nfPos + sl_50_pos.^nfPos) .* FfgmaxPos + 1) +...
                 (sl<0) .* sqrt(-sl.^nfNeg ./ (sl.^nfNeg + isodd*sl_50_neg.^nfNeg) .* FfgmaxNeg + 1) +...
                 (sl==0));

%     %Radial direciton 
%     Fgi(3,3,:) = (st>0) .* sqrt( st.^ntPos ./ (st.^ntPos + st_50_pos.^ntPos) .* FtgmaxPos + 1) +...
%                  (st<0) .* sqrt(-st.^ntNeg ./ (st.^ntNeg + isodd*st_50_neg.^ntNeg) .* FtgmaxNeg + 1) +...
%                  (st==0);
    
end 

% Eq 10 modified - cross-fiber and fiber growth stretches are the same and 
% radial growth stretch is different.
Fgi(2,2,:) = Fgi(1,1,:);

% Radial growth
Fgi(3,3,:) = frRatio*(Fgi(1,1,:)-1)+1;

% Set RV growth to 1
Fgi(1,1,TriSeg.patches==2) = 1;
Fgi(2,2,TriSeg.patches==2) = 1;
Fgi(3,3,TriSeg.patches==2) = 1;

Fg_new = Fgi .* Fg_old;




%% Calculate the new unloaded geometry, change from previous state
% Prevent TriSeg patches having zero volume and area

% New wall area - only in-plane growth
TriSeg.AmRef = max( TriSeg.AmRef.*squeeze(Fgi(1,1,:))'.*squeeze(Fgi(2,2,:))', 0.01);

% New wall volume
for iPatch = 1:TriSeg.NPatchesTot
    TriSeg.Vwv(iPatch) = max(TriSeg.Vwv(iPatch)*det(squeeze(Fgi(:,:,iPatch))), 0.1);
end

% New wall thickness
h0_new = h0(1,:).*squeeze(Fgi(3,3,:))';                                                    
                               
                               
end