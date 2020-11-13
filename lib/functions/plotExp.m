function plotExp(Volumes, Pressures, fExp, VExp, pExp, plotPars,...
                 LVPars, Valves, LVEes)

%% Load experimental data

load(fExp, VExp, pExp);

eval(strcat('VExp = ', VExp, ';'))
eval(strcat('pExp = ', pExp, ';'))


%% Add EDPVR and ESPVR

% Total initial LV volume
V0LV = sum(LVPars(:,4));

% ED
valvechange = diff(Valves);
% VED = Volumes(valvechange(:,1)==-1,end);
VEDEst = (V0LV:0.01:plotPars.vLimLV(end))';
pEDEst = getEDPVR(VEDEst, V0LV, LVPars(1,11), LVPars(1,12));

% ES
[~,iES] = max([max(Pressures(:,end)./Volumes(:,2)) max(pExp./VExp)]);
VES = Volumes(iES,end);
VESEst = (V0LV:0.01:1.2*VES)';
pESEst = getESPVR(VESEst, V0LV, LVEes);


%% Plot
    
h = figure('Visible', 'Off'); hold on

% Exp
plot(VExp, pExp, '-k', 'MarkerSize', plotPars.mSize,...
     'LineWidth', plotPars.lWidth);


% Model
plot(Volumes(:,end), Pressures(:,end), '-', 'MarkerSize', plotPars.mSize,...
     'LineWidth', plotPars.lWidth, 'Color', [0.8500    0.3250    0.0980]);
 
% EDPVR
plot(VEDEst, pEDEst, '--k', 'MarkerSize', plotPars.mSize,...
     'LineWidth', plotPars.lWidth);
 
% ESPVR
plot(VESEst, pESEst, '--k', 'MarkerSize', plotPars.mSize,...
     'LineWidth', plotPars.lWidth);



xlabel('Volume (mL)', 'FontSize', plotPars.fSize);
ylabel('Pressure (mmHg)', 'FontSize', plotPars.fSize);


legend({"Exp", "Est"}, 'Location', 'North', 'Orientation', 'Horizontal')


set(gca,'FontSize',plotPars.fSize, 'LineWidth', 2);


xlim(plotPars.vLimLV)
ylim(plotPars.pLim)

% Fix paper size
set(h,'Units','Inches');
pos = get(h,'Position');
set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])

print(h, plotPars.figType, fullfile(plotPars.figDir, 'plot_PV_expest'))



close(h);
