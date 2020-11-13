
function plotPVHistory(plotParsg, VolumesgN, Pressuresg, LVParsgN, cMap,...
                       fName, xLim, yLim, xLabel, yLabel, cBar, figDir)



h = figure('Visible', plotParsg.plotShow); hold on


% Calculate and plot EDPVR and ESPVR if LV pars are given, end with
% reference state to plot this line on top
if ~isempty(LVParsgN)
    for i = [2:size(Pressuresg,2) 1]
        VRef = (LVParsgN(i,4):.1:plotParsg.VLim(end))';
        plot(VRef, LVParsgN(i,1)*( exp(LVParsgN(i,2)*(VRef - LVParsgN(i,4))) - 1 ),...
             '-', 'Color', cMap(i,:), 'LineWidth', plotParsg.lWidth-1)
        plot(VRef, LVParsgN(i,3)*(VRef - LVParsgN(i,4)),...
             '-', 'Color', cMap(i,:), 'LineWidth', plotParsg.lWidth-1)
    end
end

for i = [2:size(Pressuresg,2) 1]
    % Plot loop
    plot(VolumesgN(:,i), Pressuresg(:,i), 'Color', cMap(i,:), 'LineWidth', plotParsg.lWidth)
end
set(gca, 'LineWidth', plotParsg.lWidth, 'FontSize', plotParsg.fSize)

if ~isempty(xLim)
    xlim(xLim);
end

if ~isempty(yLim)
    ylim(yLim);
end

xlabel(xLabel);      ylabel(yLabel)

if ~isempty(cBar)
    
    colormap(cBar.cmap)
    colorbar('Orientation', 'Horizontal', 'FontSize', cBar.fSize,...
         'Ticks', cBar.ticks, 'TickLabels', cBar.tickLabels,...
         'TickDirection', 'in', 'TickLength', cBar.tickLength,...
         'Position', cBar.position, 'LineWidth', plotParsg.lWidth)
     
    annotation('textbox', [cBar.position(1) cBar.position(2)+0.1 cBar.position(3:4)],...
               'String', cBar.title, 'FontSize', cBar.fSize,...
               'EdgeColor', [1 1 1], 'HorizontalAlignment', 'center');
     
end

% Fix paper size
fixPaperSize

print(h, plotParsg.figType, fullfile(figDir, fName))
          
if strcmp(plotParsg.plotShow, 'Off')
    close(h);
end