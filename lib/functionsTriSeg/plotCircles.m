 function [pGeo, L] = plotCircles(it,rm,xm,pGeo,cMap)

    %% Plot TriSeg geometry

    xLim = [-100 100];
    yLim = [-100 100];
    
    L = zeros(1,3);

    plot(xLim, [0 0], 'LineStyle', '--', 'LineWidth', 3, 'Color', 'k')
    plot([0 0], yLim, 'LineStyle', '--', 'LineWidth', 3, 'Color', 'k')

    % Draw reference lines
    xlim(xLim)
    ylim(yLim)

    axis equal
    set(gca, 'XDir','reverse', 'LineWidth', 3, 'FontSize', 18)


    alpha = 0:0.001:2*pi;

    for i = 1:3

        xp = rm(i)*cos(alpha);
        yp = rm(i)*sin(alpha);

        if rm(i) > 0
            iKill = ((xm(i)-rm(i)-xp)<0);
        elseif rm(i) <= 0
            iKill = ((xm(i)-rm(i)-xp)>=0);
        end

        x = xm(i)-rm(i)-xp(~iKill);
        y = yp(~iKill);
        if isempty(x)
            x = [0 0];
            y = [-1 1];
        end    
        pGeo(i) = plot(x, y, 'LineWidth', 30, 'Color', cMap(i,:));
        

        % Calculate cord length
        L(i) = sum(sqrt(diff(x).^2+diff(y).^2));
        
    end

    xticks([-100 -50 0 50 100])
    yticks([-100 -50 0 50 100])
    
    drawnow 
    
end
