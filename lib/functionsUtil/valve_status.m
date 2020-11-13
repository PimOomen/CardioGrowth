function  [Valves] = valve_status(Pressure_Array)
%Determines whether valves are open or closed
    %   Column  Compartment       
    %   1       pulmonary veins                 
    %   2       left ventricle           
    %   3       systemic arteries            
    %   4       systemic veins               
    %   5       right ventricle                 
    %   6       pulmonary arteries  

    
%Initialize
Valves=zeros(size(Pressure_Array,1),4);

%Ventricles Only
%Valves (MV, AoV , TV, PV)
Valves(:,1) = logical(Pressure_Array(:,1) > Pressure_Array(:,2)); %PCvp > P_LV
Valves(:,2) = logical(Pressure_Array(:,2) > Pressure_Array(:,3)); %P_LV > PCas
Valves(:,3) = logical(Pressure_Array(:,4) > Pressure_Array(:,5)); %PCvs > P_RV 
Valves(:,4) = logical(Pressure_Array(:,5) > Pressure_Array(:,6)); %P_RV > PCap 


   if isnan(Valves(1,1)) == 1 || isnan(Valves(1,2))==1 || isnan(Valves(1,3)) == 1 || isnan(Valves(1,4))==1
            fprintf('%s\n%s\n', 'Time Step is ill-conditioned:', 'Input a slightly different time step')
   end
   

end
