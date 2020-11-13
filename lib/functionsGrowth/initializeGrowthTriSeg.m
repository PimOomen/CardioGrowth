function [Fg, st, sl, r0, h0] = initializeGrowthTriSeg(TriSeg,Ng)


    % Initialize growth tensor and set first iterations to identify tensor
    Fg = zeros(3,3,Ng,TriSeg.NPatchesTot);
    Fg(:,:,1,:) = repmat(eye(3,3), [1 1 TriSeg.NPatchesTot]); 
    Fg(:,:,2,:) = repmat(eye(3,3), [1 1 TriSeg.NPatchesTot]); 
    
    % Initialize growth stimuli
    sl = zeros(Ng,TriSeg.NPatchesTot);
    st = zeros(Ng,TriSeg.NPatchesTot);
    
    % Unloaded wall thickness
    h0 = zeros(Ng,TriSeg.NPatchesTot);
    h0(1,:) = TriSeg.Vwv./TriSeg.AmRef;
    h0(2,:) = TriSeg.Vwv./TriSeg.AmRef;
    
    % Unloaded radius, not used for TriSeg growth, in multicompartmental it
    % is needed to compute compartmental stretches
    r0 = [];
    