function [BSegments, BActivation] = bullseyeInit(tActivationg, plotParsg, ischemicCompartments)

%% Plot bullseye code coloring

% Segment colours
cSegments =[0.0314    0.2706    0.5804
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

% Set colour map
N = 64;
if strcmp(plotParsg.cMapName, 'parula')
    cMap = parula(N);
elseif strcmp(plotParsg.cMapName, 'inferno')
    cMap = inferno(N);
elseif strcmp(plotParsg.cMapName, 'magma')
    cMap = magma(N);
elseif strcmp(plotParsg.cMapName, 'plasma')
    cMap = plasma(N);
elseif strcmp(plotParsg.cMapName, 'viridis')
    cMap = viridis(N);
else
    cMap = colorbrewer(N, plotParsg.cMapName);
end


%% Segments colour coding

hb = plotBullseyeSegment(cSegments, [], [], 'Segments', false, [], '%1.0f', 'Off',...
                            40, 10, plotParsg, ischemicCompartments);
set(hb, 'Position', hb.Position.*[1 1 3 3]);
BSegments = getframe(gca);
close(hb)


%% Activation time

dtActivation = tActivationg(:,2) - tActivationg(:,1);

hb = plotBullseyeSegment(dtActivation, [0 70], cMap, 'Segments', true, [],...
                            '%1.0f', 'Off', 40, 10, plotParsg, ischemicCompartments);
set(hb, 'Position', hb.Position.*[1 1 3 3]);
BActivation = getframe(gca);
close(hb)