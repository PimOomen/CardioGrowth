function [hProgress1, hProgress2, hProgress3, hProgress4, hProgress] = plotGrowthProgress(...
                                V, P, Fg, plotParsg, iG, tG, ...
                                BSegments, BActivation, labfg, hProgress1, hProgress2,...
                                hProgress3, hProgress4)


%% Preamble

% Number of simulation time steps, compartments, and growth steps
Nt = size(P, 2);
NCompartments = size(Fg,4);
Ng = size(Fg,3);


%% Colours

% Display colours
% plotParsg.bgColour = [43 43 43]/255;
plotParsg.fgColour = [1 1 1];

% Segment colour coding
if (NCompartments == 16)
    cSegments =[0.0314    0.2706    0.5804
        0.4157    0.2392    0.6039
        0.6471    0.0588    0.0824
        1.0000    0.4980         0
        0.9922    0.8196         0
        0.0000    0.4275    0.1725
        0.1216    0.4706    0.7059
        0.7922    0.6980    0.8392
        0.9373    0.2314    0.1725
        0.9922    0.7490    0.4353
        1.0000    1.0000    0.6000
        0.2000    0.6275    0.1725
        0.6510    0.8078    0.8902
        0.9843    0.6039    0.6000
        0.9961    0.9020    0.8078
        0.7804    0.9137    0.7529];  
elseif (NCompartments == 1)
    cSegments = [1 1 1];
else
    cSegments = lines(NCompartments);
end

% Set colour map
if strcmp(plotParsg.cMapName, 'parula')
    cMap = [plotParsg.fgColour; plotParsg.fgColour; parula(Nt)];
elseif strcmp(plotParsg.cMapName, 'inferno')
    cMap = [plotParsg.fgColour; plotParsg.fgColour; inferno(Nt)];
elseif strcmp(plotParsg.cMapName, 'magma')
    cMap = [plotParsg.fgColour; plotParsg.fgColour; magma(Nt)];
elseif strcmp(plotParsg.cMapName, 'plasma')
    cMap = [plotParsg.fgColour; plotParsg.fgColour; plasma(Nt)];
elseif strcmp(plotParsg.cMapName, 'viridis')
    cMap = [plotParsg.fgColour; plotParsg.fgColour; viridis(Nt)];
else
    cMap = [plotParsg.fgColour; plotParsg.fgColour; colorbrewer(Nt, plotParsg.cMapName)];
end


% Set line style
lStyle = ["-"; "--"; repmat("-", [Nt 1])];


%% Compute mass change (2D)
M = zeros(Nt,NCompartments);
for iT = 1:Nt
    for iV = 1:NCompartments
        M(iT,iV) = det(Fg([1 3],[1 3],iT,iV));
    end
end        

LVV = M*100 - 100;
LVVTot = sum(M,2)/NCompartments*100 - 100;


%% If first iteration, initialize plot

if iG == 1

    %% Initialise figure

%     close all
    screen = get(0, 'ScreenSize');

    hProgress = figure('Visible', 'On',...
               'Position', [0.1*screen(3), screen(4),...
                            0.8*screen(3), screen(3)]); hold on;

    set(gcf, 'color', plotParsg.bgColour, 'MenuBar', 'none', 'ToolBar', 'none')                    


    %% PV loops

    hProgress1 = subplot(2,2,1); hold on; box on

    plot(V(:,iG), P(:,iG), '-k', 'Color', cMap(iG,:), 'LineWidth', plotParsg.lWidth)

    xlabel('Total LV Volume (mL)')
    ylabel('Pressure (mL)')

    set(gca, 'LineWidth', 2, 'FontSize', plotParsg.fSize, 'XColor', plotParsg.fgColour, 'YColor', plotParsg.fgColour, 'Color', plotParsg.bgColour) 

    
    %% Non-16 segment plot choice
    
    if (NCompartments ~= 16)
        
        hProgress4 = subplot(2,2,2); hold on; box on
        
        for i = 1:NCompartments
            plot(i, max(labfg(:,i,iG)), 'o', 'Color', cSegments(i,:),...
                 'LineWidth', plotParsg.lWidth, 'MarkerSize', 10)
        end
        
        xlabel('Segment (#)')
        ylabel('Elastic stretch (-)')
        set(gca, 'LineWidth', 2, 'FontSize', plotParsg.fSize, 'XColor', plotParsg.fgColour, 'YColor', plotParsg.fgColour, 'Color', plotParsg.bgColour)
  
    else
        hProgress4 = [];
              
    end

    %% Fg11

    hProgress2 = subplot(2,2,3); hold on; box on
    for i = 1:NCompartments
        plot(tG(iG) , squeeze(Fg(1,1,1:iG,i)), ".", 'Color', cSegments(i,:),...
             'LineWidth', plotParsg.lWidth, 'MarkerSize', 20)
    end

    xlim(plotParsg.tLim)
    % ylim(plotParsg.FgLim)

    xlabel('Time (days)')
    ylabel('F_{g,11} (-)', 'Interpreter', 'tex')

    set(gca, 'LineWidth', 2, 'FontSize', plotParsg.fSize, 'XColor', plotParsg.fgColour, 'YColor', plotParsg.fgColour, 'Color', plotParsg.bgColour) 


    %% Fg33

    hProgress3 = subplot(2,2,4); hold on; box on
    for i = 1:NCompartments
        plot(tG(iG) , squeeze(Fg(3,3,1:iG,i)), ".", 'Color', cSegments(i,:),...
            'LineWidth', plotParsg.lWidth, 'MarkerSize', 20)
    end

    xlim(plotParsg.tLim)
    % ylim([plotParsg.FgLim(1) plotParsg.FgLim(2)-0.2])

    xlabel('Time (days)')
    ylabel('F_{g,33} (-)', 'Interpreter', 'tex')

%     axes('XColor', [0 0 0])
    
    set(gca, 'LineWidth', 2, 'FontSize', plotParsg.fSize, 'XColor', plotParsg.fgColour, 'YColor', plotParsg.fgColour, 'Color', plotParsg.bgColour)    
    
else
    
    %% Update figures
    
    % P-V loop
    plot(hProgress1, V(:,iG), P(:,iG), lStyle{iG}, 'Color', cMap(iG,:), 'LineWidth', plotParsg.lWidth)
    
    % Fg11
    for i = 1:NCompartments
        plot(hProgress2, tG(iG) , squeeze(Fg(1,1,iG,i)), ".", 'Color', cSegments(i,:),...
            'LineWidth', plotParsg.lWidth, 'MarkerSize', 20)
    end
    
    for i = 1:NCompartments
        plot(hProgress3, tG(iG) , squeeze(Fg(3,3,iG,i)), ".", 'Color', cSegments(i,:),...
            'LineWidth', plotParsg.lWidth, 'MarkerSize', 20)
    end
    
    if (NCompartments == 1)
        plot(hProgress4, tG(iG) , max(V(:,iG)) - min(V(:,iG)), ".", 'Color', cSegments,...
            'LineWidth', plotParsg.lWidth, 'MarkerSize', 20)
    elseif (NCompartments ~= 16)
        for i = 1:NCompartments
            plot(hProgress4, i, max(labfg(:,i,iG)), '.', 'Color', cSegments(i,:),...
                 'LineWidth', plotParsg.lWidth, 'MarkerSize', 15)
        end
    end
    
    hProgress = [];
    
end     % End if plot updates

if iG == 2

    %% Bullseyes if 16-segment model

    if NCompartments == 16
        subplot(2,2,2);

        im = [BSegments.cdata BActivation.cdata];

        imshow(im);

        %%
        annotation('textbox', [0.6 0.82 .1 0.10], 'String',...
               'Segments',...
               'FontSize', plotParsg.fSize-2, 'HorizontalAlignment', 'center',...
               'LineStyle', 'none', 'Color', plotParsg.fgColour);

        annotation('textbox', [0.77 0.82 .1 0.10], 'String',...
               'Activation time difference (ms)',...
               'FontSize', plotParsg.fSize-2, 'HorizontalAlignment', 'center',...
               'LineStyle', 'none', 'Color', plotParsg.fgColour);
    else
       
        subplot(2,2,2);
        for i = 1:NCompartments
            plot(i, max(labfg(:,i,iG)), '*', 'Color', cSegments(i,:),...
                 'LineWidth', plotParsg.lWidth, 'MarkerSize', 10)
        end
        
    end    
end

%% Progress bar

annotation('rectangle',[0.02    0.25    0.03    0.4],...
           'LineWidth', 2, 'Color', plotParsg.fgColour)

annotation('rectangle',[0.02    0.25    0.03    0.4*iG/Ng],...
           'LineWidth', 2, 'Color', plotParsg.fgColour, 'FaceColor', plotParsg.fgColour)

annotation('textbox', [0.02 0.15 0.03 0.10], 'String',...
           strcat(num2str(iG), '/', num2str(Ng)),...
           'FontSize', plotParsg.fSize-2, 'HorizontalAlignment', 'center',...
           'LineStyle', 'none', 'Color', plotParsg.fgColour, 'BackGroundColor', plotParsg.bgColour);

drawnow
   

%% Store image at the end of growth

if iG == Ng
    set(gcf, 'InvertHardcopy', 'off')
    saveas(gcf, fullfile(plotParsg.figDir, 'progressReport.png'))
end