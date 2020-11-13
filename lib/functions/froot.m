function F = froot(Vi, VLV, LVPars)

EDP = LVPars(:,1).*(exp(LVPars(:,2).*(Vi' - LVPars(:,4))) - 1);

F(1) = VLV - sum(Vi);
F(2:length(Vi)) = EDP(1) - EDP(2:end);