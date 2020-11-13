function cBar = getColourBar(LVCompartments, tActivation, fSize, cMap, cBarTitle)

% Generate colour bar properties


% Tick position and labels
cTicks = cell(LVCompartments+1,1);
cTicks{1} = '0';
cTicks{ceil((LVCompartments+1)/2)} = num2str(tActivation(end)/2);
cTicks{end} = num2str(tActivation(end));
     
% Set properties
cBar.fSize = fSize-2;
cBar.ticks = 0:0.1:1;
cBar.tickLabels = cTicks;
cBar.position = [0.3 0.85 0.4 0.04];
cBar.tickLength = 0.07;
cBar.cmap = cMap;
cBar.title = cBarTitle;