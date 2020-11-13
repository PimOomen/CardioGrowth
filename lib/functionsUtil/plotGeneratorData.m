function h = plotGeneratorData(x, y, xData, yData, yDataSEM,...
                               lStyle, Visibility,...
                               fSize, mSize, lWidth,...
                               xLabel, yLabel, fName, figType,...
                               legendList, xLim, yLim, colours,...
                               lStyleData, coloursData)

N = size(y,2);
NData = size(yData,2);

h = figure('Visible', Visibility); hold on

%% Data

% Fix constant x
if size(xData,2) < NData
    xData = repmat(xData(:,1), [1 NData]);
end

% Fix constant line style
if size(lStyleData,2) < NData
    lStyleData = repmat(lStyleData(:,1), [NData 1]);
end

for i = 1:NData
     
     pData(i) = errorbar(xData(:,i), yData(:,i), yDataSEM(:,i), lStyleData{i}, 'MarkerSize', mSize,...
    'LineWidth', lWidth, 'MarkerFaceColor', [1 1 1]);
     
    if ~isempty(coloursData)
        pData(i).Color = coloursData(i,:);
    end
end

%% Model

% Fix constant x
if size(x,2) < N
    x = repmat(x(:,1), [1 N]);
end

% Fix constant line style
if size(lStyle,2) < N
    lStyle = repmat(lStyle(:,1), [N 1]);
end
    
for i = 1:N
    p(i) = plot(x(:,i), y(:,i), lStyle{i}, 'MarkerSize', mSize,...
         'LineWidth', lWidth, 'MarkerFaceColor', [1 1 1]);
     
    if ~isempty(colours)
        p(i).Color = colours(i,:);
    end
end





%% Axis and optics

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

if strcmp(Visibility, 'Off')
    close(h);
end