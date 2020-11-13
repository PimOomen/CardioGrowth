function [HRg, SBVg, Eesg, Rasg, kg] =  initialize_circulation(simType, iG, infarctSizeg)


%% Within this function the circulation parameters are intialized 
%circulation parameters were fit using the circuit model of the circulation
%to match reported hemodynamics

%inputs: simulation type - control, MI w/o NTG, MT w/NTG
        %growth step - timing within the protocol: control, MI (if relevant), MI w/NTG (if relevant)
        
%outputs: pars.HR  - heart rate
%         pars.BV  - stressed blood volume 
%         pars.Resistances  - systemic Vascular Resistance
%         pars.EES  - LV End-systolic elastance 
%         pars.Vint  - initial proportions of stressed blood volume

%%

if iG==1 %control
                HRg =70; %Heart Rate (beats/min)
                SBVg = 427.5787; % %Stressed Blood Volume (ml)
                Eesg = 10.2837; %%LV End-systolic elastance (mmHg/ml)
                Rasg = 2.807; %%Systemic Vascular Resistance (mmHg*s/ml)
                kg = [     0.0674    0.1538    0.2910    0.2736    0.1361    0.0781         0]; %Volume Proportions for Compartments, must add to 1       
                
elseif iG==2 %myocardial infarction
        if simType==1 || simType==2 %same MI parameters whether NTG will be administered or not
                HRg =106; %Heart Rate (beats/min)
                SBVg =467.7154; %%Stressed Blood Volume (ml)
                Eesg =6.0658; %  %LV End-systolic elastance (mmHg/ml)
                Rasg =2.369;  % %Systemic Vascular Resistance (mmHg*s/ml)
                kg = [        0.0982    0.1682    0.2712    0.2324    0.1219    0.1081         0]; %Volume Proportions for Compartments, must add to 1

        elseif simType==0 %used if we want to run growth for the baseline case and verify no growth
                HRg =70; %Heart Rate (beats/min)
                SBVg = 427.5787; % %Stressed Blood Volume (ml)
                Eesg = 10.2837; %%LV End-systolic elastance (mmHg/ml)
                Rasg = 2.807; %%Systemic Vascular Resistance (mmHg*s/ml)
                kg = [     0.0674    0.1538    0.2910    0.2736    0.1361    0.0781         0]; %Volume Proportions for Compartments, must add to 1
        end
        
elseif iG==3 %drug treatment
        if simType==1 %MI with no drug treatment (same as growthstep =0)
                HRg =106; %Heart Rate (beats/min)
                SBVg =467.7154; %%Stressed Blood Volume (ml)
                Eesg =6.0658; %  %LV End-systolic elastance (mmHg/ml)
                Rasg =2.369;  % %Systemic Vascular Resistance (mmHg*s/ml)
                kg = [        0.0982    0.1682    0.2712    0.2324    0.1219    0.1081         0]; %Volume Proportions for Compartments, must add to 1
 
        elseif simType==2 %MI with treatment with NTG
                HRg =140; %Heart Rate (beats/min)
                SBVg =349.7662; %%Stressed Blood Volume (ml)
                Eesg =8.0718; %  %LV End-systolic elastance (mmHg/ml)
                Rasg = 1.900; %1.688;  % %Systemic Vascular Resistance (mmHg*s/ml)
                kg = [        0.0982    0.1682    0.2712    0.2324    0.1219    0.1081         0]; %Volume Proportions for Compartments, must add to 1

        elseif simType==0 %used if we want to run growth for the baseline case and verify no growth
                HRg =70; %Heart Rate (beats/min)
                SBVg = 427.5787; % %Stressed Blood Volume (ml)
                Eesg = 10.2837; %%LV End-systolic elastance (mmHg/ml)
                Rasg = 2.807; %%Systemic Vascular Resistance (mmHg*s/ml)
                kg = [     0.0674    0.1538    0.2910    0.2736    0.1361    0.0781         0]; %Volume Proportions for Compartments, must add to 1
   
        end
        
        
end

% Fix initial volume estimate for infarct size
kg([2 7]) = [kg(2)*(1-infarctSizeg)     kg(2)*infarctSizeg];


end
