function  [ dimensions, ValuesofInt]= computing_dimensionsandhemodynamics( ...
                                        Pressures, Volumes, t, Valves, h, TriSeg)
%Inputs:
%         Pressures - pressures in each compartment throughtout the cardiac cycle
%         Volumes - volumes in each compartment throughtout the cardiac cycle
%         TimeVector - time throughout the cardiac cycle
%         Valves - vector showing whether the valves are open or close
%         r - radius of the LV throughout the cardiac cycle:  normal compartment, total compartment, infarct compartment
%         h - thickness of the LV throughout the cardiac cycle: normal compartment, total compartment, infarct compartment
 
%Outputs:
%         dimensions
%               1. EDV
%               2. ESV
%               3. EDWth
%
%         ValuesofInt - 
%               1. EDP
%               2. MAP
%               3. Max dpdt
%               4. ESP
%               5. HR
%               6. SV
%               7. EF

%% Computing dimensions and hemodynamic values of interest

maxdPdt = max(diff(Pressures(:,2))./diff(t));
MAP = mean(Pressures(:,3));

% Total LV volumes and hemodynamics (method depending on experiment you are
% trying to match)
valvechange = diff(Valves);
% iES = find(valvechange(:,2)==-1, 1, 'first');   % find ES index from AoV closing
[~,iES] = max(Pressures(:,2)./Volumes(:,2));    % find ES index from maxP/maxV
iED = find(valvechange(:,1)==-1, 1, 'first');   % find ED index from MV closing

% MV may close at t=0, which will not be detected with the diff function:
if isempty(iED); iED = 1; end
if length(iED) > 1
    warning(['MV closure was detected at multiple time points (' sprintf('t=%f ', t(iED)) ', using first time point'])
    iED = iED(1);
end

if TriSeg.switch
    iV = 2;
else
    iV = size(Volumes,2);
end

ESP = Pressures(iES,iV);
ESV = Volumes(iES,iV);
EDP = Pressures(iED,iV);
EDV = Volumes(iED,iV);
hED = h(iED);

% Functional measures
HR  = 60/t(end);
SV = EDV-ESV;  
EF = SV/EDV*100;

%ValuesofInt: (1)EDP (2)MAP (3)dpdt (4)ESP  (5)HR   (6) SV   (7) EF
ValuesofInt = [EDP MAP maxdPdt ESP HR SV EF];

%Dimensions: (1) EDV (2) ESV (3) EDWth
dimensions = [EDV ESV hED];
    

end

  