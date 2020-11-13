function EF = getEjectionFraction(V, EDV)

% Calculate mean ejection fraction for multiple PV-cycles

% Detect maximum and minimum volume within each cycle
iMin = peakfinder(-V, [], [], [], false);
iBET = peakfinder(V);

% Only use maximum and minima within the analyzed cycles
VMin = V(iMin);
VMax = V(iBET);

EF = (VMax - VMin)/EDV;