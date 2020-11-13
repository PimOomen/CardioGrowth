function [x, y] = getXYet(LVPars, LVVolumes, etLV, detLV, iter)

% Parameters
A =  LVPars(:,1);
B =  LVPars(:,2);
E =  LVPars(:,3);
V0 = LVPars(:,4);

x = detLV(iter,:)' .*( E.*(LVVolumes'-V0) - ...
                      A.*(exp(B.*(LVVolumes' - V0)) - 1) );

y = etLV(iter,:)'.*E + (1-etLV(iter,:)') .* A.*B.*...
       exp(B.*(LVVolumes'-V0));