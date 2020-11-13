function [Volumes, TimeVector, Tes] =set_initialconditions_noventricles(  HR, BV, Vint)
%Inputs: 
%HR - heart rate
%BV - stressed blood volume
%Vint - proportion of the total stressed blood volume in each compartment

%Outputs:
%Volumes - volumes in each compartment 
%TimeVector - time throughout the cardiac cycle
%Tes - time to end-systole

%% Within this function the circulation parameters are set and the 
%initial circulation volumes are calculated

%Initialize Timing
nRows = 5000; %number of time steps throughout a single cardiac cycle
Tes =60/HR* 0.2/0.75;
TimeVector=linspace(0, 60/HR, nRows)'; %setting time vector to length of a single beat (s)
    
%Initialize Volume
Vtotal = BV;  %total effective or stressed blood volume (ml)
Volumes = zeros(nRows,7);   
    

%Estimating initial Volumes
%Weighting compartments by average literature blood volume
Volumes(1,:)=Vint*Vtotal;  
  

end