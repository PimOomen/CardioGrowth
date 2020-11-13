function frame = plotBullsEye(cPlot, RInner, ROuter, cMap, cLim,...
                              plotPars, t, iFrame, vidSwitch, figName)



% Set colour limits and ticks for colour bar
cTicks = cell(plotPars.nColours+1,1);
cTicks{1} = num2str(cLim(1));
cTicks{end} = num2str(cLim(2));
cTicks{ceil((plotPars.nColours+1)/2)} = sum(cLim)/2;
                          
                          
h = figure('Visible', 'Off'); hold on

% Bull's eye plot (rotate by a quarter to have septum on the left
hb = bullseye(cPlot, 'rho', [RInner ROuter]);
set(hb, 'LineWidth', 2)

% Colour stuff
colormap(cMap)
caxis(cLim)
hc = colorbar('Orientation', 'Vertical', 'FontSize', plotPars.fSize-2,...
         'Ticks', cLim(1):(cLim(2)-cLim(1))/10:cLim(2), 'TickLabels', cTicks,...
         'TickDirection', 'in', 'TickLength', 0.1,...
         'LineWidth', plotPars.lWidth, 'Limits', cLim,...
         'Position', [0.9    0.25    0.04    0.5]);

% Set axis limits
xlim([-1 1]*max(ROuter))
ylim([-1 1]*max(ROuter))


%% Annote time

if vidSwitch

    annotation('rectangle',[0.1    0.25    0.04    0.5],...
               'LineWidth', 2, 'Color', [0 0 0])

    annotation('rectangle',[0.1    0.25    0.04    .5*t(iFrame)/t(end)],...
               'LineWidth', 2, 'Color', [0 0 0], 'FaceColor', [0 0 0])

    annotation('textbox', [0.08 0.15 0.10 0.10], 'String',...
               strcat(num2str(round(t(iFrame)*1000)), ' ms'),...
               'FontSize', plotPars.fSize-2, 'HorizontalAlignment', 'right',...
               'LineStyle', 'none');
end  

       
%%

drawnow;
frame = getframe(gcf);


if ~vidSwitch
    % Fix paper size
    set(h,'Units','Inches');
    pos = get(h,'Position');
    set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])

    print(h, plotPars.figType, fullfile(plotPars.figDir, figName))
end


close(h);