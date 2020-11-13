function [cMap, cMapBar, cBar] = plotOutput(...
                         Volumes, Pressures, t, Valves, simPars,...
                         plotPars, LVPars, LVEes,...
                         fExp, VExp, pExp, lab, eps, eps0, etLV, TriSeg)


%% Total LV volume and pressure

if ~TriSeg.switch
    % LV compartments column indices
    chambers = [2 7:7+simPars.LVCompartments-1]; 
    % Total LV volume
    VLV = Volumes(:,end);
    PLV = Pressures(:,end);
else
    VLV = Volumes(:,2);
    PLV = Pressures(:,2);
end


%% Valves open and closed, ED and ES

% Reference lines for valve opening
valvechange = diff(Valves); %Valves (MV, AoV , TV, PV)
row_AoV_opens = find(valvechange(:,2)==1); 
row_AoV_closes = find(valvechange(:,2)==-1);
row_MV_opens = find(valvechange(:,1)==1, 1, 'last'); 
row_MV_closes = find(valvechange(:,1)==-1, 1, 'last'); 

% MV may close at t=0, which will not be detected with the diff function:
if isempty(row_MV_closes); row_MV_closes = 1; end             

% End-systole and end-diastole
[~,iES] = max(PLV./VLV);
iED = row_MV_closes;


%% Kinematics and hemodynamics

if TriSeg.switch
    % Get LV segment kinematics
    lab = TriSeg.labf(:,((TriSeg.patches==1) | (TriSeg.patches==3)));
    eps = 0.5*(lab.^2-1);
    lab0 = lab./lab(iED,:);
    eps0 = 0.5*(lab0.^2 -1);
end


%% Print some readouts

% Maximum pressure
pMax = max(PLV);

% ES pressure
pES = PLV(iES);
VES = VLV(iES);

% ED Volume (when MV closes)
pED = PLV(iED);
VED = VLV(iED);

% Stroke volume: V(AV open) - V(AV closed)
VStroke = VED - VES;

% dpdtMax
dpdtMax = max(gradient(PLV,t));

% Mean arterial pressure (mmHg)
MAP = mean(Pressures(:,3));

% Cardiac output (L/min)
CO = VStroke/max(t)'*60*1e-3;

% Ejection fraction
EF = VStroke/VED;

% Start spreading the news
s = sprintf(['EDV:\t\t%2.2f\nESV:\t\t%2.2f\nEDP:\t\t%2.2f\nESP:\t\t%2.2f\n'...
             'pMax:\t\t%2.2f\nStroke volume:\t%2.2f\nCO:\t\t%2.2f\nEF:\t\t%2.2f'...
             '\nMAP:\t\t%2.2f\ndpdtMax:\t%2.2f\n'],...
            VED, VES, pED, pES, pMax, VStroke, CO, EF, MAP,dpdtMax);
        
disp(s);
fid = fopen(fullfile(plotPars.figDir, 'readouts.txt'),'w');
fprintf(fid,s);
fclose(fid);


%% Set colours and lines etc.

% Default Matlab colours
colours = lines;

% Line styles: continuous lines for separate compartments, dashed line for
% total LV behaviour (final index)
lStyle = {simPars.LVCompartments+1};
for i = 1:simPars.LVCompartments
    lStyle{i} = '-';
end
lStyle{i+1} = '--k';

% Obtain activation time range
cDepth = 64;
tActivationRange = linspace(min(simPars.tActivation), max(simPars.tActivation), plotPars.nColours);


% Dyssynchrony
if ((simPars.LVCompartments > 1) && (simPars.infarctSize == 0))
        
    % Set colour map for colour bar
    if strcmp(plotPars.cMapName, 'parula')
        cMapBar = parula(cDepth);
    elseif strcmp(plotPars.cMapName, 'inferno')
        cMapBar = inferno(cDepth);
    elseif strcmp(plotPars.cMapName, 'magma')
        cMapBar = magma(cDepth);
    elseif strcmp(plotPars.cMapName, 'plasma')
        cMapBar = plasma(cDepth);
    elseif strcmp(plotPars.cMapName, 'viridis')
        cMapBar = viridis(cDepth);
    else
        cMapBar = colorbrewer(cDepth, plotPars.cMapName);
    end

    % Set colourbar properties
    if (simPars.LVCompartments > 1)
        cBar = getColourBar(plotPars.nColours, tActivationRange, plotPars.fSize,...
                            cMapBar, plotPars.cBarTitle);
    else
        cBar = [];
    end

    % Pick colours for each compartment
    cMap = zeros(simPars.LVCompartments,3);
    for i = 1:simPars.LVCompartments
        cMap(i,:) = cMapBar(max([1 ceil(simPars.tActivation(i)/max(simPars.tActivation)*(cDepth-1)+1) 1]),:);
    end
    % Append with black line for total LV plots
    cMap = [cMap; zeros(1,3)];
    
% Ischemia    
elseif (simPars.infarctSize > 0)    
    
    cMapBar = [];
    cMap = [colorbrewer(2, plotPars.cMapName); 0 0 0];
    cBar = [];
    
% Single compartment    
else
    
    cMapBar = [];
    cMap = zeros(simPars.LVCompartments+1,3);
    cBar = [];
    
end    


%% Plot experimental and model PV loop in the same figure

if ~isempty(fExp) 
    plotExp(Volumes, Pressures, fExp, VExp, pExp, plotPars, LVPars, Valves, LVEes)
end 


%% Plot pressures and volumes
               
plotGenerator(t , VLV, "-k", 'Off',...
              plotPars.fSize, plotPars.mSize, plotPars.lWidth,...
                   'Time (s)', 'Volume (mL)', ...
                   fullfile(plotPars.figDir,'plot_Vt'),...
                   plotPars.figType, [], [], plotPars.vLim, [], []);

plotGenerator(t , PLV, "-k", 'Off',...
              plotPars.fSize, plotPars.mSize, plotPars.lWidth,...
                   'Time (s)', 'Pressure (mmHg)', ...
                   fullfile(plotPars.figDir,'plot_Pt'),...
                   plotPars.figType, [], [], plotPars.pLim, [], []);

plotGenerator(t , gradient(PLV,t), "-k", 'Off',...
              plotPars.fSize, plotPars.mSize, plotPars.lWidth,...
                   'Time (s)', 'dp/dt (mmHg/s)', ...
                   fullfile(plotPars.figDir,'plot_dpdt'),...
                   plotPars.figType, [], [], [], [], []);
               
plotGenerator(VLV , PLV, "-k",...
              'Off', plotPars.fSize, plotPars.mSize, plotPars.lWidth,...
              'Volume (ml)', 'Pressure (mmHg)', ...
              fullfile(plotPars.figDir,'plot_PV'),...
              plotPars.figType, [], plotPars.vLim, plotPars.pLim,...
              [], []);
               
               
%% Plot kinematics
               
plotGenerator(t , lab, lStyle, 'Off', plotPars.fSize,...
              plotPars.mSize, plotPars.lWidth,...
              'Time (s)', 'Circumferential stretch (-)',...
              fullfile(plotPars.figDir,'plot_stretch'),...
              plotPars.figType, [], [], plotPars.labLim, cMap, cBar);      
          
plotGenerator(t , eps, lStyle, 'Off', plotPars.fSize,...
              plotPars.mSize, plotPars.lWidth,...
              'Time (s)', 'Circumferential strain (-)',...
              fullfile(plotPars.figDir,'plot_strain'),...
              plotPars.figType, [], [], plotPars.epsLim, cMap, cBar);
          
plotGenerator(t , eps0, lStyle, 'Off', plotPars.fSize,...
              plotPars.mSize, plotPars.lWidth,...
              'Time (s)', 'Circumferential shortening (-)',...
              fullfile(plotPars.figDir,'plot_shortening'),...
              plotPars.figType, [], [], plotPars.labLim-1, cMap, cBar);
     
% Plot in compartment colours if using 16-segment model
if (simPars.LVCompartments == 16)
    % 16-segment colours
    cSegments =   [0.0314    0.2706    0.5804
                            0.4157    0.2392    0.6039
                            0.6471    0.0588    0.0824
                            1.0000    0.4980         0
                            0.9922    0.8196         0
                            0.0000    0.4275    0.1725
                            0.1216    0.4706    0.7059
                            0.7922    0.6980    0.8392
                            0.9373    0.2314    0.1725
                            0.9922    0.7490    0.4353
                            1.0000    1.0000    0.6000
                            0.2000    0.6275    0.1725
                            0.6510    0.8078    0.8902
                            0.9843    0.6039    0.6000
                            0.9961    0.9020    0.8078
                            0.7804    0.9137    0.7529
                            0         0         0       ];  
    
    plotGenerator(t , eps0(:,1:end-1), lStyle, 'Off', plotPars.fSize,...
              plotPars.mSize, plotPars.lWidth,...
              'Time (s)', 'Circumferential shortening (-)',...
              fullfile(plotPars.figDir,'plot_shortening_segments'),...
              plotPars.figType, [], [], plotPars.eps0Lim, cSegments, []);
end 

if TriSeg.switch
    
    iLFW = find(TriSeg.patches==1);     cLFW = colours(2,:);
    iSW  = find(TriSeg.patches==3);     cSW  = colours(3,:);
    iRFW = find(TriSeg.patches==2);     cRFW = colours(1,:);
    
    hFig = figure('Visible', 'Off'); hold on
    plotValves(t, row_AoV_opens, row_AoV_closes, row_MV_opens, row_MV_closes, plotPars.labLim)
    HL = plot(t, mean(TriSeg.labf(:,iLFW),2), 'LineWidth', 5, 'Color', cLFW);
    HR = plot(t, mean(TriSeg.labf(:,iRFW),2), 'LineWidth', 5, 'Color', cRFW);
    HS = plot(t, mean(TriSeg.labf(:,iSW),2), 'LineWidth', 5, 'Color', cSW);
    plot(t, TriSeg.labf(:,iLFW), 'LineWidth', 1, 'Color', cLFW)
    plot(t, TriSeg.labf(:,iSW), 'LineWidth', 1, 'Color', cSW)
    plot(t, TriSeg.labf(:,iRFW), 'LineWidth', 1, 'Color', cRFW)
    xlabel('Time (s)')
    ylabel('Circumferential stretch (-)')
    ylim(plotPars.labLim)
    legend([HL HR HS], {'Left free wall', 'Right free wall', 'Septal wall'},...
           'Orientation', 'Horizontal','Location', 'North')
    set(gca, 'FontSize', plotPars.fSize, 'LineWidth', plotPars.lWidth)
    fixPaperSize
    print(hFig, '-dpdf', fullfile(plotPars.figDir, 'plot_stretch_walls'))
    close(hFig)

end      


%% Plotting 'Wiggers diagram'

% 
h = figure('Visible', 'Off'); hold on
set(h, 'Position', [800 100 1000 800]); 

chamber_r=[4 5 6]; chamber_l=[1 size(Volumes,2) 3];
chamberstring_r={'Systemic Veins', 'Right Ventricle', 'Pulmonary Arteries' }; 
chamberstring_l={'Pulmonary Veins', 'Left Ventricle', 'Systemic Arteries'}; 


% LV P-t
subplot(2,2,1)
title('Left ventricle');
hold on
for i=1:length(chamber_l)
    plot(t, Pressures(:, chamber_l(i)), '-', 'color', colours(i,:),'LineWidth', plotPars.lWidth)
    hold on
end
ylabel('Pressure (mmHg)'); xlabel ('Time (s)');
if ~isempty(plotPars.pLim)
    ylim(plotPars.pLim)
end
yL = get(gca,'YLim');
plot([t(row_AoV_opens) t(row_AoV_opens)],yL,'--k','LineWidth', plotPars.lWidth);
plot([t(row_AoV_closes) t(row_AoV_closes)],yL,'-k','LineWidth', plotPars.lWidth);
plot([t(row_MV_opens) t(row_MV_opens)],yL, ':k','LineWidth', plotPars.lWidth);
plot([t(row_MV_closes) t(row_MV_closes)],yL,'-.k','LineWidth', plotPars.lWidth);
hold off   
set(gca,'FontSize',plotPars.fSize, 'LineWidth', plotPars.lWidth);
legend(chamberstring_l, 'FontSize', plotPars.fSize-8); 
    
% RV V-t
subplot(2,2,2)
title('Right ventricle');
hold on
for i=1:length(chamber_r)
    plot(t, Pressures(:, chamber_r(i)), '-', 'color', colours(i+3,:),'LineWidth', plotPars.lWidth)
    hold on
end
ylabel('Pressure (mmHg)'); xlabel ('Time (s)');
if ~isempty(plotPars.pLim)
    ylim(plotPars.pLim)
end
yL = get(gca,'YLim');
plot([t(row_AoV_opens) t(row_AoV_opens)],yL,'--k','LineWidth', plotPars.lWidth);
plot([t(row_AoV_closes) t(row_AoV_closes)],yL,'-k','LineWidth', plotPars.lWidth);
plot([t(row_MV_opens) t(row_MV_opens)],yL, ':k','LineWidth', plotPars.lWidth);
plot([t(row_MV_closes) t(row_MV_closes)],yL,'-.k','LineWidth', plotPars.lWidth);

hold off
set(gca,'FontSize',plotPars.fSize, 'LineWidth', plotPars.lWidth);
legend(chamberstring_r, 'FontSize', plotPars.fSize-8); 
    
% LV V-t
subplot(2,2,3)
hold on
for i=1:length(chamber_l)
plot(t, Volumes(:, chamber_l(i)), '-', 'color', colours(i,:),'LineWidth', plotPars.lWidth)
hold on
end
ylabel('Volume (ml)'); xlabel ('Time (s)');
if ~isempty(plotPars.pLim)
    ylim(plotPars.pLim)
end
yL = get(gca,'YLim');
plot([t(row_AoV_opens) t(row_AoV_opens)],yL,'--k','LineWidth', plotPars.lWidth);
plot([t(row_AoV_closes) t(row_AoV_closes)],yL,'-k','LineWidth', plotPars.lWidth);
plot([t(row_MV_opens) t(row_MV_opens)],yL, ':k','LineWidth', plotPars.lWidth);
plot([t(row_MV_closes) t(row_MV_closes)],yL,'-.k','LineWidth', plotPars.lWidth);

hold off
set(gca,'FontSize',plotPars.fSize, 'LineWidth', plotPars.lWidth);

legend(chamberstring_l, 'FontSize', plotPars.fSize-8);     

% RV V-t
subplot(2,2,4)
hold on
for i=1:length(chamber_r)
    plot(t, Volumes(:, chamber_r(i)), '-', 'color', colours(i+3,:),'LineWidth', plotPars.lWidth)
    hold on
end
ylabel('Volume (ml)'); xlabel ('Time (s)');
if ~isempty(plotPars.pLim)
    ylim(plotPars.pLim)
end
yL = get(gca,'YLim');
plot([t(row_AoV_opens) t(row_AoV_opens)],yL,'--k','LineWidth', plotPars.lWidth);
plot([t(row_AoV_closes) t(row_AoV_closes)],yL,'-k','LineWidth', plotPars.lWidth);
plot([t(row_MV_opens) t(row_MV_opens)],yL, ':k','LineWidth', plotPars.lWidth);
plot([t(row_MV_closes) t(row_MV_closes)],yL,'-.k','LineWidth', plotPars.lWidth);

hold off
set(gca,'FontSize',plotPars.fSize, 'LineWidth', plotPars.lWidth);

legend(chamberstring_r, 'FontSize', plotPars.fSize-8); 


% Save figure
fixPaperSize
print(h, plotPars.figType, fullfile(plotPars.figDir, 'plot_overview')) 
close(h)
   
    
    
    %% Clean up colourmap
    
    cMap = cMap(1:end-1,:);
    
    
 end

