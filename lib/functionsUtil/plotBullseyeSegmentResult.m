function plotBullseyeSegmentResult(c, cLim, cMap, cBarTitle,...
                             shadingSwitch, fName, txtFormat)

                         
%% Segment coordinates

segments(1).thetaLim =  [1/3*pi 2/3*pi];      segments(1).radLim =  [90 120];
segments(2).thetaLim =  [0      1/3*pi];      segments(6).radLim =  [90 120];
segments(3).thetaLim =  [5/3*pi 6/3*pi];      segments(5).radLim =  [90 120];
segments(4).thetaLim =  [4/3*pi 5/3*pi];      segments(4).radLim =  [90 120];
segments(5).thetaLim =  [3/3*pi 4/3*pi];      segments(3).radLim =  [90 120];
segments(6).thetaLim =  [2/3*pi 3/3*pi];      segments(2).radLim =  [90 120];

segments(7).thetaLim  =  [1/3*pi 2/3*pi];      segments(7).radLim =  [55 90];
segments(8).thetaLim  = [0      1/3*pi];      segments(12).radLim = [55 90];
segments(9).thetaLim  = [5/3*pi 6/3*pi];      segments(11).radLim = [55 90];
segments(10).thetaLim = [4/3*pi 5/3*pi];      segments(10).radLim = [55 90];
segments(11).thetaLim =  [3/3*pi 4/3*pi];      segments(9).radLim =  [55 90];
segments(12).thetaLim =  [2/3*pi 3/3*pi];      segments(8).radLim =  [55 90];

segments(13).thetaLim = [1/4*pi 3/4*pi];      segments(13).radLim = [15 55];
segments(14).thetaLim = [7/4*pi 1/4*pi];      segments(16).radLim = [15 55];
segments(15).thetaLim = [5/4*pi 7/4*pi];      segments(15).radLim = [15 55];
segments(16).thetaLim = [3/4*pi 5/4*pi];      segments(14).radLim = [15 55];

nSegments = length(segments);

[contours.X1, contours.Y1] =pol2cart(0:.01:2*pi,120);
[contours.X2, contours.Y2] =pol2cart(0:.01:2*pi,90);
[contours.X3, contours.Y3] =pol2cart(0:.01:2*pi,55);
[contours.X0, contours.Y0] =pol2cart(0:.01:2*pi,15);
[contours.X4, contours.Y4] =pol2cart(0*pi/180,55:1:120);
[contours.X5, contours.Y5] =pol2cart(300*pi/180,55:1:120);
[contours.X6, contours.Y6] =pol2cart(240*pi/180,55:1:120);
[contours.X7, contours.Y7] =pol2cart(180*pi/180,55:1:120);
[contours.X8, contours.Y8] =pol2cart(120*pi/180,55:1:120);
[contours.X9, contours.Y9] =pol2cart(60*pi/180,55:1:120);
[contours.X10,contours.Y10]=pol2cart(315*pi/180,15:1:55);
[contours.X11,contours.Y11]=pol2cart(225*pi/180,15:1:55);
[contours.X12,contours.Y12]=pol2cart(135*pi/180,15:1:55);
[contours.X13,contours.Y13]=pol2cart(45*pi/180,15:1:55);
    

% Segment patches for plotting
for i = 1:nSegments

    if (i~=14)
        % Theta
        segments(i).thetaPatch = [linspace(segments(i).thetaLim(1), segments(i).thetaLim(2), 100)...
                flip(linspace(segments(i).thetaLim(1), segments(i).thetaLim(2), 100))];
        
        % Center
        [segments(i).xCenter, segments(i).yCenter] = pol2cart(mean(segments(i).thetaLim), mean(segments(i).radLim));
    % Segment 14 crosses over theta = 0
    else
        segments(i).thetaPatch = [linspace(segments(i).thetaLim(1), 2*pi, 50) linspace(0, segments(i).thetaLim(2), 50)...
                flip([linspace(segments(i).thetaLim(1), 2*pi, 50) linspace(0, segments(i).thetaLim(2), 50)])];
        [segments(i).xCenter,segments(i).yCenter] = pol2cart(0, mean(segments(i).radLim));    
    end
    segments(i).radPatch = [ones(1,100)*segments(i).radLim(1) ones(1,100)*segments(i).radLim(2)];    
    [segments(i).xPatch, segments(i).yPatch] = pol2cart(segments(i).thetaPatch, segments(i).radPatch);
    
end

%% Plot

h = figure('Visible', 'Off'); hold on

% Patches - flip x axis as theta = 0 is in the septum (on the right)
for i = 1:length(c)
    patch(-segments(i).xPatch, segments(i).yPatch, c(i,:), 'EdgeColor', 'None')    
end

% Contour lines
plot(contours.X1,contours.Y1, 'k', 'LineWidth', 3);
plot(contours.X2,contours.Y2, 'k', 'LineWidth', 3);
plot(contours.X3,contours.Y3, 'k', 'LineWidth', 3);
plot(contours.X0,contours.Y0, 'k', 'LineWidth', 3);
plot(contours.X4,contours.Y4, 'k', 'LineWidth', 3);
plot(contours.X5,contours.Y5, 'k', 'LineWidth', 3);
plot(contours.X6,contours.Y6, 'k', 'LineWidth', 3);
plot(contours.X7,contours.Y7, 'k', 'LineWidth', 3);
plot(contours.X8,contours.Y8, 'k', 'LineWidth', 3);
plot(contours.X9,contours.Y9, 'k', 'LineWidth', 3);
plot(contours.X10,contours.Y10, 'k', 'LineWidth', 3);
plot(contours.X11,contours.Y11, 'k', 'LineWidth', 3);
plot(contours.X12,contours.Y12, 'k', 'LineWidth', 3);
plot(contours.X13,contours.Y13, 'k', 'LineWidth', 3);


text(0,128,'Anterior','fontsize',12,'fontweight','b','HorizontalAlignment','center')
text(-128,0,'Septal','fontsize',12,'Rotation',90,'fontweight','b','HorizontalAlignment','center')
text(128,0,'Lateral','fontsize',12,'Rotation',270,'fontweight','b','HorizontalAlignment','center')
text(0,-128,'Posterior','fontsize',12,'fontweight','b','HorizontalAlignment','center')
     
set(gca, 'LineWidth', 3)


if shadingSwitch

    shading flat;
    colormap(cMap)
    
    if ~isempty(cLim)
        caxis(cLim)
    end

end

axis([-120 120 -120 120]);
axis off equal;
set(gcf,'Color','white')

% Set figure square
pos = get(gcf,'Position');
set(gcf, 'Position', [pos(1) pos(2) pos(3) pos(3)])

removePadding
fixPaperSize

print(h, '-depsc', fName)

for i = 1:length(c)
    
    % Print segments numbers if no patch data color coding
    if ~shadingSwitch
        text(-segments(i).xCenter, segments(i).yCenter, num2str(i, txtFormat),...
                'FontSize', 14, 'Color', [0 0 0],'HorizontalAlignment','center')
    % Else, place data value in center of each patch
    else
        text(-segments(i).xCenter, segments(i).yCenter, num2str(c(i), txtFormat),...
                'FontSize', 14, 'Color', [0 0 0],'HorizontalAlignment','center')

    end
end

if ~isempty(fName)
    print(h, '-depsc', strcat(fName, 'Txt'))

end
close(h)


%% Print colorbar in a seperate figure

if (~isempty(cLim) && shadingSwitch)

    h = figure('Visible', 'Off'); hold on

    % Set figure square
    pos = get(gcf,'Position');
    set(gcf, 'Position', [pos(1:3) pos(4)/4])
    
    colormap(cMap)

    hcb = colorbar('Orientation', 'Horizontal', 'position',[0.2 0.3 0.6 .4],...
             'LineWidth', 3, 'FontSize', 20, 'TickLength', 0, 'Ticks', [cLim(1) mean(cLim) cLim(end)]);

    caxis(cLim)     
    axis off
    set(gcf,'Color','white')

    set(get(hcb,'Title'),'String',cBarTitle)

    fixPaperSize

    if ~isempty(fName)
        print(h, '-dpdf', strcat(fName, 'Cbar'))
    end
end