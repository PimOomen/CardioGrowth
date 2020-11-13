function cBar = getColourBar(nColours, tActivationRange, fSize, cMap, cBarTitle)

% Generate colour bar properties

iCentre = ceil((nColours+1)/2);

% Tick position and labels
cTicks = cell(nColours+1,1);
cTicks{1} = '0';
cTicks{iCentre} = num2str(tActivationRange(iCentre));
cTicks{end} = num2str(tActivationRange(end));
     
% Set properties
cBar.fSize = fSize-2;
cBar.ticks = 0:1/nColours:1;
cBar.tickLabels = cTicks;
cBar.position = [0.3 0.85 0.4 0.04];
cBar.tickLength = 0.07;
cBar.cmap = cMap;
cBar.title = cBarTitle;