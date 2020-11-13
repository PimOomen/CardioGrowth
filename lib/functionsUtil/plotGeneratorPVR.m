function plotGeneratorPVR(V, p, VED, pED, VES, pES,...
                          lStyle, Visibility, fSize, mSize, lWidth,...
                          xLabel, yLabel, fName, figType, legendList,...
                          xLim, yLim, colours, cBar)

N = size(p,2) + 2;
% lStyle = char(lStyle);

h = figure('Visible', Visibility); hold on


% Fix constant x
if size(V,2) < (N-2)
    V = repmat(V(:,1), [1 N]);
end

% Fix constant line style
if (~isempty(lStyle) && (size(lStyle,2) < N))
    lStyle = repmat(lStyle(:,1), [N 1]);
end

    
for i = 1:N-2
    pf = plot(V(:,i), p(:,i), '-', 'MarkerSize', mSize,...
         'LineWidth', lWidth, 'MarkerFaceColor', [1 1 1]);
    if ~isempty(colours)
        pf.Color = colours(i,:);
    end
end

% EDPVR
i = i + 1;
pf = plot(VED, pED, '--', 'MarkerSize', mSize,...
         'LineWidth', lWidth, 'MarkerFaceColor', [1 1 1]);
if ~isempty(colours)
    pf.Color = colours(i,:);
end

% ESPVR
i = i + 1;
pf = plot(VES, pES, '--', 'MarkerSize', mSize,...
         'LineWidth', lWidth, 'MarkerFaceColor', [1 1 1]);
if ~isempty(colours)
    pf.Color = colours(i,:);
end


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


if ~isempty(cBar)
    
    colormap(cBar.cmap)
    colorbar('Orientation', 'Horizontal', 'FontSize', cBar.fSize,...
         'Ticks', cBar.ticks, 'TickLabels', cBar.tickLabels,...
         'TickDirection', 'in', 'TickLength', cBar.tickLength,...
         'Position', cBar.position, 'LineWidth', lWidth)
     
    annotation('textbox', [cBar.position(1) cBar.position(2)+0.1 cBar.position(3:4)],...
               'String', cBar.title, 'FontSize', cBar.fSize,...
               'EdgeColor', [1 1 1], 'HorizontalAlignment', 'center');
     
end






set(gca,'FontSize',fSize, 'LineWidth', 2);

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