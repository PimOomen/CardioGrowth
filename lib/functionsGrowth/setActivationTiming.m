function fEt = setActivationTiming(fEtg, tGi)

% Quick function to determine what fEt should be used, based on the time
% range that is given in which an fEt should be used

Nf = length(fEtg);
iDetect = zeros(Nf,1);

for i = 1:Nf
   iDetect(i) = (tGi >= fEtg(i).timing(1)) & (tGi <= fEtg(i).timing(2));
end

if sum(iDetect) == 0
    error('No activation timing pattern selected')
end

fEt = fEtg(iDetect == 1).fName;