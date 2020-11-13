function [Pressures,Volumes,TriSeg] = calculate_pressuresandvolumesinitial(Volumes,...
                                 VLV, capacitances, LVPars, RVPars, simPars,TriSeg)

    %   Column  Compartment       
    %   1       pulmonary veins                 
    %   2       left ventricle - compartment 1          
    %   3       systemic arteries            
    %   4       systemic veins               
    %   5       right ventricle                 
    %   6       pulmonary arteries  
    %   7-end   additional left ventricle compartments 
    
%We assume that we start with all compartments acting
%passively,i.e. the elastance of every compartment is zero

% Material parameters indices
% 1 - A
% 2 - B
% 3 - E
% 4 - V0
% 5 - a6
% 6 - a4
% 7 - tr0
% 8 - td
% 9 - tMax
% 10 - P0
% 11 - K1
% 12 - K2
% 13 - t0


%% Calculate Circulation Pressures 
% Equations A.6 - A. 9 from Burkhoff and Tyberg

Pressures(1) = Volumes(1)/capacitances(1);      %P_Cvp
Pressures(3) = Volumes(3)/capacitances(2);      %P_Cas
Pressures(4) = Volumes(4)/capacitances(3);      %P_Cvs
Pressures(6) = Volumes(6)/capacitances(4);      %P_Cap   

% TriSeg
if TriSeg.switch
    
    TriSeg = TriSegV2P(TriSeg, Volumes(:,[2 5]), 0, 1);
    Pressures([2 5]) = TriSeg.P(1,:);

% Non-TriSeg
else

    %% Calculate RV Pressure
    
    Pressures(5) =  RVPars(1)*(exp(RVPars(2)*(Volumes(5) - RVPars(4))) - 1);



    %% Calculate LV Volume corrections for ischemia and dyssnchrony   
    % Perform volume correction to prevent additive numerical errors to
    % cause different pressures between LV compartments. Use a numerical solver
    % (fsolve) to solve a system of equations where (1) the sum of all
    % compartmental volumes is equal to the total LV volume at the end of the
    % previous solver iteration and (2-N-1) compartmental EDPs are equal to
    % the EDP of compartment 1. ESP can be ignored here as e(t) is 0 at the
    % beginning of the cardiac cycle. 

    if (simPars.LVCompartments >= 2) && (~TriSeg.switch)

        chambers = [2 7:size(Volumes,2)];

        F = @(Vi) froot(Vi, VLV, LVPars);
        x0 = Volumes(chambers);
        options = optimset('Display', 'Off');     
        Volumes(chambers) = fsolve(F, x0, options);

    end


    %% Calculate LV Pressure(s)

    Pressures([2 7:(5+simPars.LVCompartments)]) =  ...
            LVPars(:,1)'.*(exp(LVPars(:,2)'.*(Volumes([2 7:end]) - LVPars(:,4)')) - 1);


end

        
end
