function plotGrowthMulti(plotParsg, dimensions, ValuesofInterest, Fg,...
                         sl, st, VolumesgT, Pressuresg, t, r0, h0,...
                         refState, tActivationg, tG)

% Data
% ValuesofInt: (1)EDP (2)MAP (3)dpdt (4)ESP  (5)HR (6)SV (7)EF
% Dimensions: (1) EDV (2) ESV (3) EDWth

%% Set up time array and load experimental data

% Number of growth steps and compartments/segments
N = length(dimensions);
nCompartments = size(sl,2);


%% Plot time in days or weeks?

if (plotParsg.plotTime == 1)
    timeAxis = 'Time (days)';
elseif (plotParsg.plotTime == 7)
    timeAxis = 'Time (weeks)';
else
    warning('Please indicate if plot time is in days (plotParsg.plotTime=1) or weeks (plotParsg.plotTime=7)')
    timeAxis = 'Time';
end


%% Set plot colours

% Default Matlab line colours
colours = lines;

% Set colour map
if strcmp(plotParsg.cMapName, 'parula')
    cMap = [0 0 0; parula(N)];
    cMapBar = parula(64);
elseif strcmp(plotParsg.cMapName, 'inferno')
    cMap = [0 0 0; inferno(N)];
    cMapBar = inferno(64);
elseif strcmp(plotParsg.cMapName, 'magma')
    cMap = [0 0 0; magma(N)];
    cMapBar = magma(64);
elseif strcmp(plotParsg.cMapName, 'plasma')
    cMap = [0 0 0; plasma(N)];
    cMapBar = plasma(64);
elseif strcmp(plotParsg.cMapName, 'viridis')
    cMap = [0 0 0; viridis(N)];
    cMapBar = viridis(64);
else
    cMap = [0 0 0; colorbrewer(N, plotParsg.cMapName)];
    cMapBar = colorbrewer(64, plotParsg.cMapName);
end
       

% Set colourbar properties
cBar = getColourBar(plotParsg.nColours, 0:(max(tG))/(plotParsg.nColours):tG(end), plotParsg.fSize,...
                    cMapBar, plotParsg.cBarTitle);


%% Calculate percentage change

% Calculate dimensional percentage change with acute change as reference
dimChange = dimensions./dimensions(refState,:)*100 - 100;       % [%]

% Calculate dimensional percentage change with acute change as reference
valsOIChange = ValuesofInterest./ValuesofInterest(refState,:)*100 - 100;       % [%]
    
% Compute mass change (3D)
M = zeros(N,nCompartments);
for iT = 1:N
    for iV = 1:nCompartments
        M(iT,iV) = det(Fg(:,:,iT,iV));
    end
end
LVV = M*100 - 100;
LVVTot = sum(M,2)/nCompartments*100 - 100;

% % Compute mass change (2D)
% M = zeros(N,nCompartments);
% for iT = 1:N
%     for iV = 1:nCompartments
%         M(iT,iV) = det(Fg([1 3],[1 3],iT,iV));
%     end
% end        
% 
% LVV = M*100 - 100;
% LVVTot = sum(M,2)/nCompartments*100 - 100;


%% Set compartment plot colours

% If using a 16-segment LBBB model
if nCompartments == 16
    
    % 16-segment colours
    compartmentColours =[0.0314    0.2706    0.5804
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
                0.7804    0.9137    0.7529];  
            
    compartmentLegend = [];

% Non-16-segment model    
elseif (nCompartments == 1)
    compartmentColours = [];
    compartmentLegend = [];
else
    compartmentColours = [];
    compartmentLegend = num2str((1:nCompartments)');
end

%% Compute cardiac output

CO = ValuesofInterest(:,6)./max(t)'*60/1000;


%% Changes in ED and ES volumes and pressures

plotGenerator(tG , dimChange(:,1), "-", plotParsg.plotShow,...
              plotParsg.fSize, plotParsg.mSize, plotParsg.lWidth,...
              timeAxis, 'EDV change (%)', ...
              fullfile(plotParsg.figDir,'plot_EDV'),...
              plotParsg.figType, [], plotParsg.tLim, plotParsg.dimLim, [0 0 0], []);
                
plotGenerator(tG , dimChange(:,2), "-", plotParsg.plotShow,...
              plotParsg.fSize, plotParsg.mSize, plotParsg.lWidth,...
              timeAxis, 'ESV change (%)', ...
              fullfile(plotParsg.figDir,'plot_ESV'),...
              plotParsg.figType, [], plotParsg.tLim, plotParsg.dimLim, [0 0 0], []);
                
plotGenerator(tG , dimChange(:,3), "-", plotParsg.plotShow,...
              plotParsg.fSize, plotParsg.mSize, plotParsg.lWidth,...
              timeAxis, 'EDWTh change (%)', ...
              fullfile(plotParsg.figDir,'plot_EDWTh'),...
              plotParsg.figType, [], plotParsg.tLim, [], [0 0 0], []);

plotGenerator(tG , valsOIChange(:,1), "-", plotParsg.plotShow,...
              plotParsg.fSize, plotParsg.mSize, plotParsg.lWidth,...
              timeAxis, 'EDP change (%)', ...
              fullfile(plotParsg.figDir,'plot_EDP'),...
              plotParsg.figType, [], plotParsg.tLim, -flip(plotParsg.dimLim), [0 0 0], []);
          
plotGenerator(tG , valsOIChange(:,4), "-", plotParsg.plotShow,...
              plotParsg.fSize, plotParsg.mSize, plotParsg.lWidth,...
              timeAxis, 'ESP change (%)', ...
              fullfile(plotParsg.figDir,'plot_ESP'),...
              plotParsg.figType, [], plotParsg.tLim, plotParsg.dimLim, [0 0 0], []);
          
          
%% Clinical readouts          
          
plotGenerator(tG , valsOIChange(:,2), "-", plotParsg.plotShow,...
              plotParsg.fSize, plotParsg.mSize, plotParsg.lWidth,...
              timeAxis, 'MAP change (%)', ...
              fullfile(plotParsg.figDir,'plot_MAP'),...
              plotParsg.figType, [], plotParsg.tLim, plotParsg.dimLim, [0 0 0], []);
          
plotGenerator(tG , valsOIChange(:,5), "-", plotParsg.plotShow,...
              plotParsg.fSize, plotParsg.mSize, plotParsg.lWidth,...
              timeAxis, 'Heart rate change (%)', ...
              fullfile(plotParsg.figDir,'plot_HR'),...
              plotParsg.figType, [], plotParsg.tLim, plotParsg.dimLim, [0 0 0], []);
          
plotGenerator(tG , valsOIChange(:,6), "-", plotParsg.plotShow,...
              plotParsg.fSize, plotParsg.mSize, plotParsg.lWidth,...
              timeAxis, 'Stroke volume change (%)', ...
              fullfile(plotParsg.figDir,'plot_SV'),...
              plotParsg.figType, [], plotParsg.tLim, plotParsg.dimLim, [0 0 0], []);
          
plotGenerator(tG , CO/CO(1)*100-100, "-", plotParsg.plotShow,...
              plotParsg.fSize, plotParsg.mSize, plotParsg.lWidth,...
              timeAxis, 'Cardiac output change (%)', ...
              fullfile(plotParsg.figDir,'plot_CO'),...
              plotParsg.figType, [], plotParsg.tLim, plotParsg.dimLim, [0 0 0], []);
          
          
%% Wall volume       
          
plotGenerator(tG , LVV, "-", plotParsg.plotShow,...
              plotParsg.fSize, plotParsg.mSize, plotParsg.lWidth,...
              timeAxis, 'LV wall volume change (%)', ...
              fullfile(plotParsg.figDir,'plot_LVV'),...
              plotParsg.figType, [], plotParsg.tLim, plotParsg.dimLim, [], []);
          
plotGenerator(tG , LVVTot, "-", plotParsg.plotShow,...
              plotParsg.fSize, plotParsg.mSize, plotParsg.lWidth,...
              timeAxis, 'LV wall volume change (%)', ...
              fullfile(plotParsg.figDir,'plot_LVVTot'),...
              plotParsg.figType, [], plotParsg.tLim, plotParsg.dimLim, [], []);


%% Plot growth

plotGenerator(tG , squeeze(Fg(1,1,:,:)), "-", plotParsg.plotShow,...
              plotParsg.fSize, plotParsg.mSize, plotParsg.lWidth,...
              timeAxis, 'F_{g,ff} (-)', ...
              fullfile(plotParsg.figDir,'plot_Fgff'),...
              plotParsg.figType, compartmentLegend, plotParsg.tLim, [], compartmentColours, []);
          
plotGenerator(tG , squeeze(Fg(3,3,:,:)), "-", plotParsg.plotShow,...
              plotParsg.fSize, plotParsg.mSize, plotParsg.lWidth,...
              timeAxis, 'F_{g,rr} (-)', ...
              fullfile(plotParsg.figDir,'plot_Fgrr'),...
              plotParsg.figType, compartmentLegend, plotParsg.tLim, [], compartmentColours, []);
          
plotGenerator(tG , [squeeze(Fg(1,1,:,1)) squeeze(Fg(3,3,:,1))], "-", plotParsg.plotShow,...
              plotParsg.fSize, plotParsg.mSize, plotParsg.lWidth,...
              timeAxis, 'F_g (-)', ...
              fullfile(plotParsg.figDir,'plot_Fgffrr'),...
              plotParsg.figType, {'F_{g,ff}', 'F_{g,rr}'}, plotParsg.tLim, [], [], []);
          
plotGenerator(tG , sl, "-", plotParsg.plotShow,...
              plotParsg.fSize, plotParsg.mSize, plotParsg.lWidth,...
              timeAxis, 'Lengthening stimulus (-)', ...
              fullfile(plotParsg.figDir,'plot_sl'),...
              plotParsg.figType, compartmentLegend, plotParsg.tLim, [], compartmentColours, []);
          
plotGenerator(tG , st, "-", plotParsg.plotShow,...
              plotParsg.fSize, plotParsg.mSize, plotParsg.lWidth,...
              timeAxis, 'Thickening stimulus (-)', ...
              fullfile(plotParsg.figDir,'plot_st'),...
              plotParsg.figType, compartmentLegend, plotParsg.tLim, [], compartmentColours, []);
          
          
%% Plot dimensions

plotGenerator(tG , r0, "-", plotParsg.plotShow,...
              plotParsg.fSize, plotParsg.mSize, plotParsg.lWidth,...
              timeAxis, 'Radius (cm)', ...
              fullfile(plotParsg.figDir,'plot_r0'),...
              plotParsg.figType, [], plotParsg.tLim, [], compartmentColours, []);
          
plotGenerator(tG , h0, "-", plotParsg.plotShow,...
              plotParsg.fSize, plotParsg.mSize, plotParsg.lWidth,...
              timeAxis, 'Thickness (mm)', ...
              fullfile(plotParsg.figDir,'plot_h0'),...
              plotParsg.figType, [], plotParsg.tLim, [], compartmentColours, []);
    
          
%% Plot growth in bullseye plot, only for 16-compartment dyssynchrony

if (nCompartments == 16)
                         
    plotBullseyeSegmentResult((squeeze(Fg(1,1,end,:))-1)*100, [0 20], cMapBar, 'Circ. growth (%)',...
                                true, fullfile(plotParsg.figDir,'bullseye_Fg11'), '%1.0f%%')

    plotBullseyeSegmentResult((squeeze(Fg(3,3,end,:))-1)*100, [0 20], cMapBar, 'Rad. growth (%)',...
                                true, fullfile(plotParsg.figDir,'bullseye_Fg33'), '%1.0f%%')

    plotBullseyeSegmentResult(LVV(end,:)', [0 20], cMapBar, 'Total growth (%)',...
                                true, fullfile(plotParsg.figDir,'bullseye_J'), '%1.0f%%')


    plotBullseyeSegmentResult(tActivationg(:,1), plotParsg.MALim, cMapBar, 'Mechanical activation time (ms)',...
                                true, fullfile(plotParsg.figDir,'bullseye_MABaseline'), '%1.0f%')
                            

    plotBullseyeSegmentResult(tActivationg(:,2), plotParsg.MALim, cMapBar, 'Mechanical activation time (ms)',...
                                true, fullfile(plotParsg.figDir,'bullseye_MAAcute'), '%1.0f%')

    plotBullseyeSegmentResult(tActivationg(:,end), plotParsg.MALim, cMapBar, 'Mechanical activation time (ms)',...
                                true, fullfile(plotParsg.figDir,'bullseye_MAEnd'), '%1.0f%')
                            
end                        
                        
%% Plot PV-loops

plotPVHistory(plotParsg, VolumesgT, Pressuresg, [], cMap,...
              'plot_PV', plotParsg.VLim, plotParsg.pLim, 'Volume (mL)', 'Pressure (mmHg)',...
              cBar, plotParsg.figDir)

coloursPV3 = [0 0 0
              197  194  222
              229 113 0]/255;          
          
% Total p-V, at baseline, acute, and grown
plotGenerator(VolumesgT(:,[1 2 end]) , Pressuresg(:,[1 2 end]), ["--", "-", "-"], ...
              plotParsg.plotShow, plotParsg.fSize, plotParsg.mSize, plotParsg.lWidth,...
              'Volume (mL)', 'Pressure (mmHg)', ...
              fullfile(plotParsg.figDir,'plot_PV3'),...
              plotParsg.figType, {"Baseline", "Acute", "Chronic"}, plotParsg.VLim, plotParsg.pLim,...
              coloursPV3, []);  
