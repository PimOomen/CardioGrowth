function plotTriSeg(TriSeg,Volumes,Pressures,Valves,t,plotPars)

patches = TriSeg.patches;

% Plotting properties and initialization of pGeo handle
cMap = lines;
cMap = cMap([2 1 3],:);

% Patch color maps

cMapLfw = [ 255,245,240
            255,245,240
            254,224,210
            252,187,161
            252,187,161
            252,146,114
            251,106,74
            239,59,44
            203,24,29
            165,15,21
            103,0,13];

cMapRfw = [ 158,202,225
            107,174,214
            66,146,198
            33,113,181
            8,69,148]/255;
        
cMapSp = [  237,248,233
            186,228,179
            116,196,118
            49,163,84
            0,109,44 ];
        

%% Create EDPVR

plotGenerator(Volumes(:,2), TriSegEDPVR.P(1:Ned,1), "-k", 'Off',...
              plotPars.fSize, plotPars.mSize, plotPars.lWidth,...
                   'Volume (mL)', 'Pressure (mmHg)',...
                   fullfile(plotPars.figDir,'plot_EDPVR'),...
                   plotPars.figType, [], [], [0 50], [], []);
        

%% Plot V and P over time

plotGenerator(t, Volumes(:,2), "-k", 'Off',...
              plotPars.fSize, plotPars.mSize, plotPars.lWidth,...
                   'Time (s)', 'LV Cavity volume (mL)',...
                   fullfile(plotPars.figDir,'plot_Vt'),...
                   plotPars.figType, [], [], plotPars.vLim, [], []);
               
plotGenerator(t, Pressures(:,2), "-k", 'Off',...
              plotPars.fSize, plotPars.mSize, plotPars.lWidth,...
                   'Time (s)', 'LV Pressure (mmHg)',...
                   fullfile(plotPars.figDir,'plot_Pt'),...
                   plotPars.figType, [], [], plotPars.pLim, [], []);

               
%% Print some readouts

% Reference lines for valve opening
valvechange = diff(Valves); %Valves (MV, AoV , TV, PV)
row_AoV_opens = find(valvechange(:,2)==1); 
row_AoV_closes = find(valvechange(:,2)==-1);
row_MV_opens = find(valvechange(:,1)==1, 1, 'first'); 
row_MV_closes = find(valvechange(:,1)==-1, 1, 'first'); 

% Maximum pressure
pMax = max(Pressures(:,2));

% ES
[~,iES] = max(Pressures(:,2)./Volumes(:,2));
pES = Pressures(iES,2);
VES = Volumes(iES,2);

% ED Volume (when MV opens)
iED = row_MV_closes;
pED = Pressures(iED,2);
VED = max(Volumes(iED,2));

% Stroke volume and EF
% VStroke = Volumes(row_AoV_opens,2) - Volumes(row_AoV_closes,2);
VStroke = VED-VES;
EF = (VED-VES)/VED;

% Cardiac output (L/min)
CO = VStroke/max(t)'*60/1000;

% dpdtMax
dpdtMax = max(gradient(Pressures(:,2),t));

% Mean arterial pressure (mmHg)
MAP = mean(Pressures(:,3));

% Start spreading the news
s = sprintf(['EDV:\t\t%2.2f\nEDP:\t\t%2.2f\nESV:\t\t%2.2f\nESP:\t\t%2.2f\n'...
             'pMax:\t\t%2.2f\nStroke volume:\t%2.2f\nCO:\t\t%2.2f\nEF:\t\t%2.2f'...
             '\nMAP:\t\t%2.2f\ndpdtMax:\t%2.2f\n'],...
            VED, pED, VES, pES, pMax, VStroke, CO, EF, MAP,dpdtMax);
        
disp(s);
fid = fopen(fullfile(plotPars.figDir, 'readouts.txt'),'w');
fprintf(fid,s);
fclose(fid);


