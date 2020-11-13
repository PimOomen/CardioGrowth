function plotGeneratorFit(V, P, vRef, pRef, vEst, pEst,...
                          Visibility, fSize, mSize, lWidth,...
                          xLabel, yLabel, fName, figType, legendList,...
                          xLim, yLim, lStyle)

c = [0.8500    0.3250    0.0980];

h = figure('Visible', Visibility); hold on

if isempty(lStyle)
    lLoop = '.';
    lEst = '-';
    lRef = 'o';
else
    lLoop = lStyle{1};
    lEst = lStyle{2};
    lRef = lStyle{3};
end

plot(V, P, lLoop, 'MarkerSize', mSize, 'Color', [0 0 0],...
         'LineWidth', lWidth, 'MarkerFaceColor', [1 1 1]);
     
plot(vEst, pEst, lEst, 'MarkerSize', mSize, 'Color', c,...
         'LineWidth', lWidth, 'MarkerFaceColor', [1 1 1]); 

plot(vRef, pRef, lRef, 'MarkerSize', mSize, 'Color', [0 0 0],...
         'LineWidth', lWidth, 'MarkerFaceColor', [1 1 1]); 
    

xlabel(xLabel,'FontSize',fSize);
ylabel(yLabel,'FontSize',fSize);

if ~isempty(xLim)
    xlim(xLim)
end
if ~isempty(yLim)
    ylim(yLim)
end

if ~isempty(legendList)
    legend(legendList, 'Location', 'North', 'Orientation', 'Horizontal')
end






set(gca,'FontSize',fSize, 'LineWidth', lWidth);

if ~isempty(fName)
    % Fix paper size
    set(h,'Units','Inches');
    pos = get(h,'Position');
    set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3), pos(4)])

    print(h, figType, fName)
end

if ~Visibility
    close(h);
end