%% Wrapper to run a bunch of utlity functions
% Calculate and plot dimensions, mechanical constituents

% For multicompartmental (Witzenburg 2019)
if ~TriSeg.switch
    
    % Store material properties before growth
    RVParsg(iG,:) = RVPars;
    LVParsg(iG,:,:) = LVPars;
    
    % Compute the radius and thickness of the LV over the cardiac cycle for
    % non-MI compartments only
    [r(:,:,iG), h(:,:,iG)] = dimensionsofsphere(Volumes(:,[2 7:end-1-(drugSwitch==1)]), r0(iG,:), h0(iG,:)); 
    
    % Compute the stress-strain relationships of the LV
    [sigma_ED(:,:,iG), sigma_ES(:,:,iG), strainc(:,:,iG), ees(iG,:), a(iG,:), b(iG,:)] = ...
        calculate_stress_strain_relationships(squeeze(LVParsg(iG,:,:)), r0(iG,:), h0(iG,:), t);

    % Wall volume, assuming isochoric deformation
    VWall(iG,:) = 4/3*pi*( (r0(iG,:) + h0(iG,:)).^3  -r0(iG,:).^3);
    
    % Fiber and radial elastic stretch
    labfg(:,:,iG) = lab(:,1:end-1);
    labrg(:,:,iG) = 1./(lab(:,1:end-1).^2);

% For TriSeg (Oomen 2020)
else
    % Wall thickness
    h(:,:,iG) = TriSeg.H;
    
    % Wall volume and midwall area
    TriSeg.Vwvg(iG,:) = TriSeg.Vwv;
    TriSeg.AmRefg(iG,:) = TriSeg.AmRef;
    
    % Fiber and radial strain history
    labfg(:,:,iG) = TriSeg.labf;
    labrg(:,:,iG) = TriSeg.H./h0(iG,:);
end

% Calculate dimensions (EDV, ESV) and VOI (MAP, SV, EF, etc)
[dimensions(iG,:), ValuesofInterest(iG,:)] = computing_dimensionsandhemodynamics( ...
        Pressures, Volumes, t, Valves, h(:,:,iG), TriSeg);
