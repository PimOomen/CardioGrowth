function [newVolumes, newPressures, TriSeg] = rk4(currentVolumes, currentPressures, currentt,...
                                          resistances, capacitances, LVPars, RVPars, dt,...
                                          inc, etLV, etRV, detLV, TriSeg)

% Code engine: Runge-Kutta differential equation solver to calculate 
% volumes and pressures at the current time point
    
   %%Volume and Pressu  34W5ERre Compartment Designations
    %   Column  Compartment       
    %   1       pulmonary veins                 
    %   2       left ventricle - compartment 1        
    %   3       systemic arteries            
    %   4       systemic veins               
    %   5       right ventricle                 
    %   6       pulmonary arteries
    %   7-end   additional left ventricle compartments   
    
    %%Resistances Compartment Designations
    %   Column  Compartment       
    %   1       pumonary venous resistance - resists return of blood to heart (mmHg * s/mL) Rvp                  
    %   2       characteristic resistance - indicates stiffness of the aorta (mmHg * s/mL) Rcs       
    %   3       systemic arterial resistance (mmHg * s/mL) Ras          
    %   4       systemic venous resistance - resists return of blood to heart (mmHg * s/mL) Rvs          
    %   5       characteristic resistance - indicates stiffness of the pulmonary arteries (mmHg * s/mL) Rcp               
    %   6       pulmonary arterial resistance (mmHg * s/mL) Rap 
    %   7       backflow resistance of the mitral valve RMV


%% Initiate pressures
newPressures = zeros(size(currentPressures));    

    
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RK4 solver components k1-k4, used to update compartment volumes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    %% K1       - includes *dt
    if TriSeg.switch
        DV2 = dv2Single(currentPressures, resistances);
        DV_LVcompartments = [];
    else
        [DV2, DV_LVcompartments]=dv2(currentPressures, resistances, currentVolumes,...
                                LVPars, etLV, detLV, inc);
    end
    k1 = dt*[  dv1(currentPressures, resistances), ...
            DV2, ...  
            dv3(currentPressures, resistances), ...
            dv4(currentPressures, resistances), ...
            dv5(currentPressures, resistances), ...
            dv6(currentPressures, resistances), ...
            DV_LVcompartments];    
        
        
    %% K2
    P_k2 = currentPressures + 0.5 * k1;
    if TriSeg.switch
        DV2 = dv2Single(P_k2, resistances);
        DV_LVcompartments = [];
    else
        [DV2, DV_LVcompartments]=dv2(P_k2, resistances, currentVolumes,...
                                LVPars, etLV, detLV, inc);
    end
    k2 = dt*[  dv1(P_k2, resistances), ...    
            DV2, ...
            dv3(P_k2, resistances), ...  
            dv4(P_k2, resistances), ...  
            dv5(P_k2, resistances), ...
            dv6(P_k2, resistances), ... 
            DV_LVcompartments];
        
        
    %% K3
    P_k3 = currentPressures + 0.5 * k2;
    if TriSeg.switch
        DV2 = dv2Single(P_k3, resistances);
        DV_LVcompartments = [];
    else
        [DV2, DV_LVcompartments]=dv2(P_k3, resistances, currentVolumes,...
                                LVPars, etLV, detLV, inc);
    end
    k3 = dt*[  dv1(P_k3, resistances), ...
            DV2, ...
            dv3(P_k3, resistances), ...
            dv4(P_k3, resistances), ...
            dv5(P_k3, resistances), ...
            dv6(P_k3, resistances), ... 
            DV_LVcompartments];


    %% K4
    P_k4 = currentPressures  + dt * k3;
    if TriSeg.switch
        DV2 = dv2Single(P_k4, resistances);
        DV_LVcompartments = [];
    else
        [DV2, DV_LVcompartments]=dv2(P_k4, resistances, currentVolumes,...
                                LVPars, etLV, detLV, inc);
    end
    k4 = dt*[  dv1(P_k4, resistances), ...
            DV2, ...
            dv3(P_k4, resistances), ...
            dv4(P_k4, resistances), ...
            dv5(P_k4, resistances), ...
            dv6(P_k4, resistances), ... 
            DV_LVcompartments];  
        
    
    %% Compute new volumes 
    
    dV = 1/6 * (k1 + 2*k2 + 2*k3 + k4);         % Multiplied by dt through k1-4
    newVolumes = currentVolumes + dV;
  
%     disp(dV([2 7:end])')  
%     disp(newVolumes([2 7:end])')
     
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute new pressures of all model compartments based on new volumes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      


    %% Compute new pressures
    
    %Calculate circulation Pressures
    newPressures(1) = newVolumes(1)/capacitances(1);    %P_Cvp
    newPressures(3) = newVolumes(3)/capacitances(2);    %P_Cas
    newPressures(4) = newVolumes(4)/capacitances(3);    %P_Cvs
    newPressures(6) = newVolumes(6)/capacitances(4);    %P_Cap
    
    if TriSeg.switch
        TriSeg = TriSegV2P(TriSeg, newVolumes(:,[2 5]), currentt, inc);
        newPressures([2 5]) = TriSeg.P(inc,:);        
    else
        
        % RV pressure
        newPressures(5) = etRV(inc) * RVPars(3)*(newVolumes(5) - RVPars(4)) + ...
                          (1-etRV(inc))*RVPars(1)*( exp(RVPars(2)*(newVolumes(5)-RVPars(4))) - 1 );

        % LV pressure(s)
        V = newVolumes([2 7:end])';
        newPressures([2 7:end]) = etLV(inc,:)' .* LVPars(:,3).*(V - LVPars(:,4)) + ...
                                  (1-etLV(inc,:)') .* LVPars(:,1).*( exp(LVPars(:,2).*(V-LVPars(:,4))) - 1 );

    end                  
        
end



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Functions to compute volume changes in all compartments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% dV1: Pulmonary veins

function deltaVolume = dv1(P, R)
    % Calculate volume change of the pulmonary veins
    % equation A16 from "Why does pulmonary venous pressure rise after onset of
    % LV dysfunction: a theoretical analysis." by Burkhoff and Tyberg with
    % alteration for MV regurgitation
    deltaVolume = (P(6) - P(1)) / R(6) - (P(1) - P(2)) / R(1) * (P(1) > P(2)) - ...
                  (P(1) - P(2)) / R(7) * (P(2) > P(1)) ;
end


%% dV2: LV 

function [deltaVolume, deltaVolumeCompartments] = dv2Single(P, R)  
    % Calculate volume change of the total LV
    % equation A12 from "Why does pulmonary venous pressure rise after onset of
    % LV dysfunction: a theoretical analysis." by Burkhoff and Tyberg modified
    % to include mitral regurgitation
    Qin = (P(1) - P(2)) / R(1) * (P(1) > P(2)) + (P(1) - P(2))/R(7) * (P(2) > P(1));
    Qout = (P(2) - P(3)) / R(2) * (P(2) > P(3));
    deltaVolume = Qin - Qout;
    deltaVolumeCompartments = []; 
end



%% dV2: LV 

function [deltaVolume, deltaVolumeCompartments] = dv2(P, R, V, LVPars,...
                                                      etLV, detLV, inc)  
    % Calculate volume change of the total LV
    % equation A12 from "Why does pulmonary venous pressure rise after onset of
    % LV dysfunction: a theoretical analysis." by Burkhoff and Tyberg modified
    % to include mitral regurgitation
    Qin = (P(1) - P(2)) / R(1) * (P(1) > P(2)) + (P(1) - P(2))/R(7) * (P(2) > P(1));
    Qout = (P(2) - P(3)) / R(2) * (P(2) > P(3));

    % If there is only one compartment dV equals the net difference in
    % inflow and outlow of the LV
    if size(LVPars,1)==1 
        
        deltaVolume = Qin - Qout;
        deltaVolumeCompartments = [];
        
    % For more compartments, compute volume change in all compartments all
    % at once, by assuming pressure in all compartments is equal and the
    % total change in volume is given by Qin-Qout
    % For the mathematical derivationsee page CMW notebook 7 (pp61-66) and 
    % PJO notebook 1 (pp16-19)
    else
        
        NCompartments=size(LVPars,1);
        
        %% Compute compartments x and y to solve linear system
        % Components are dependent on the chosen active contraction model
        % and should thus correspond to the function used to calculate
        % pressure in the LV and RV based on their volumes
        [x, y] = getXYet(LVPars, V([2 7:end]), etLV, detLV, inc);

        
        %% Solve linear system to compute volume change in all compartments
        
        % Building A
        A = zeros(NCompartments);
        A(end,:) = 1;
        A(1:end-1, 1) = y(1);

        for j = 2:NCompartments
            A(j-1,j) = -y(j);
        end

        % Solve linear system to compute volume changes, given in array s
        dV=A\[x(2:NCompartments) - x(1); Qin-Qout];

        deltaVolume=dV(1);                       % dV in first compartment
        deltaVolumeCompartments=dV(2:end)';      % dV in all other compartments

    end
    
end


%% dV3: Systemic arterial resistance

function deltaVolume = dv3(P, R) 
    % Calculate volume change of the systemic arteries
    % equation A12 from "Why does pulmonary venous pressure rise after onset of
    % LV dysfunction: a theoretical analysis." by Burkhoff and Tyberg
    deltaVolume = (P(2) - P(3)) / R(2) * (P(2) > P(3)) - (P(3) - P(4)) / R(3);
end


%% dV4: Systemic veins

function deltaVolume = dv4(P, R) 
    % Calculate volume change of the systemic venules
    % equation A13 from "Why does pulmonary venous pressure rise after onset of
    % LV dysfunction: a theoretical analysis." by Burkhoff and Tyberg
    deltaVolume = (P(3) - P(4)) / R(3) - (P(4) - P(5)) / R(4) * (P(4) > P(5));
end


%% dV5: Right ventricle

function deltaVolume = dv5(P, R) 
    % Calculate volume change of the right ventricle
    % equation A14 from "Why does pulmonary venous pressure rise after onset of
    % LV dysfunction: a theoretical analysis." by Burkhoff and Tyberg
    deltaVolume = (P(4) - P(5)) / R(4) * (P(4) > P(5)) - (P(5) - P(6)) / R(5) * (P(5) > P(6));
end


%% dV6: Pulmonary arteries

function deltaVolume = dv6(P, R) 
    % Calculate volume change of the pulmonary arteries
    % equation A15 from "Why does pulmonary venous pressure rise after onset of
    % LV dysfunction: a theoretical analysis." by Burkhoff and Tyberg
    deltaVolume = (P(5) - P(6)) / R(5) * (P(5) > P(6)) - (P(6) - P(1)) / R(6);
end