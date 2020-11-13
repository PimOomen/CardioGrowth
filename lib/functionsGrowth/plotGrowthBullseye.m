function plotGrowthBullseye(r0, h0, plotParsg, Fg, tScale)


%% Generate patch data

nCompartments = size(r0,2);
N = size(r0,1);
nPoints = 50;   

frameSwitch = true;

if frameSwitch
    figDirVid = fullfile(plotParsg.figDir, 'vidFrames');
    if ~isfolder(figDirVid); mkdir(figDirVid); end
end


%% Compute wall mass ratio

% J = zeros(N,nCompartments);
% for iT = 1:N
%     for iV = 1:nCompartments
%         J(iT,iV) = det(Fg(:,:,iT,iV));
%     end
% end        

J = zeros(N,nCompartments);
for iT = 1:N
    for iV = 1:nCompartments
        J(iT,iV) = det(Fg([1 3],[1 3],iT,iV));
    end
end 


%% Symmetry

JSym = [J flip(J,2)];
r0Sym = [r0 flip(r0,2)];
nCompartments = nCompartments*2;


%% Colour map

cLim = plotParsg.LVVLim; 

% cMap = colorbrewer(64, plotParsg.cMapName);
cMap = parula(64);
cBar = getColourBar(plotParsg.nColours, cLim(1):cLim(2)/(plotParsg.nColours):cLim(2), plotParsg.fSize,...
                    cMap, 'Wall mass change (%)');
                
                
%% Plot area evolution
                
% Compartment fraction of total LV, to compute radial angles
JFrac = JSym./sum(JSym,2);

% Total LV radius
V0g = 4/3*pi*(sum(r0.^3,2));
r0g = getRadius(V0g);
rho = [r0g r0g+mean(h0,2)/10];
rho = [r0g 2*r0g];


%%

X = zeros(N, nCompartments, 2*nPoints);
Y = zeros(N, nCompartments, 2*nPoints);

for iT=1:N
tht1 = -180;
  for iCompartment=1:nCompartments
      
    dtht = -diff([0 360*JFrac(iT, iCompartment)]);
    if iCompartment > 1
        tht1 = tht2;
    end
    tht2 = tht1 + JFrac(iT,iCompartment)*360;
    ang = linspace(tht1/180*pi,tht2/180*pi,nPoints);
    
    [x1, y1] = pol2cart(ang,rho(iT,1));
    [x2, y2] = pol2cart(ang,rho(iT,2));
    X(iT,iCompartment,:) = [x1 x2(end:-1:1)];
    Y(iT,iCompartment,:) = [y1 y2(end:-1:1)];
    
  end
end

%% Make video

v = VideoWriter(fullfile(plotParsg.figDir,'bullseye.mp4'), 'MPEG-4');
v.Quality = 95;
v.FrameRate = 16;
open(v);

for iT = 1:N
    multiWaitbar( 'Generating video...', (iT-1)/N, 'Color', [0.2 0.9 0.3] );
    
    h = figure('Visible', 'Off'); hold on
    for iCompartment = 1:nCompartments
        patch(squeeze(X(iT,iCompartment,:)),squeeze(Y(iT,iCompartment,:)), ...
              cMap(round((JSym(iT,iCompartment)-1)*100/cLim(end)*(64-1)+1),:), 'linewidth',3);

    end

    xlim([-1 1]*1.4*max(rho(:)));
    ylim([-1 1]*1.4*max(rho(:)));
    axis equal
    axis off
    
    set(gcf, 'Color', [1 1 1])

    fixPaperSize
    
    %% Time bar
    annotation('rectangle',[0.1    0.25    0.04    0.5],...
               'LineWidth', 2, 'Color', [0 0 0])

    annotation('rectangle',[0.1    0.25    0.04    .5*iT/N],...
               'LineWidth', 2, 'Color', [0 0 0], 'FaceColor', [0 0 0])

    annotation('textbox', [0.08 0.15 0.10 0.10], 'String',...
               strcat(num2str(iT*tScale), ' days'),...
               'FontSize', plotParsg.fSize-2, 'HorizontalAlignment', 'right',...
               'LineStyle', 'none');
    
           
    %% Colour bar
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
    
    
    %% Export plot to figure to video frame
    cData = print('-RGBImage');
    writeVideo(v,cData);
    
    
    %% Export frame
    if frameSwitch
        print(h, '-dpng', fullfile(figDirVid, ['frame_' num2str(iT)]))
    end
    close(h)
    
end

close(v)