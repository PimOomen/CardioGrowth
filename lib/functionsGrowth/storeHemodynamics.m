% Store hemodynamics during heart beat at the current growth step

Pressuresg(:,iG) = Pressures(:,2);

if TriSeg.switch
    Volumesg(:,iG)  = Volumes(:,2);
    VolumesgT(:,iG)  = Volumes(:,2);
else
    Volumesg(:,:,iG)  = Volumes(:,[2 7:end-1]);
    VolumesgT(:,iG)  = Volumes(:,end);
end

% Track valve openings
valvechange = diff(Valves); %Valves (MV, AoV , TV, PV)
row_AoV_opens = find(valvechange(:,2)==1); 
row_AoV_closes = find(valvechange(:,2)==-1);
row_MV_opens = find(valvechange(:,1)==1, 1, 'first'); 
row_MV_closes = max([1 find(valvechange(:,1)==-1, 1, 'first')]); 
valveEventsg(iG,:) = [row_AoV_opens row_AoV_closes row_MV_opens row_MV_closes];