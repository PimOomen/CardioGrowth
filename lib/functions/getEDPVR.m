function pED = getEDPVR(VED, V0, k1, k2)

eV = (VED-V0)./V0;

pED = k1.*(exp(k2.*max(eV,0)) - 1);