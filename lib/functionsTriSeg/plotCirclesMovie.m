 function plotCirclesMovie(rm,xm,wth,cMap,TriSeg,ef)

    %% Plot TriSeg geometry

    xLim = [-100 100];
    yLim = [-100 100];
    
    Lw = zeros(1,3);

    plot(xLim, [0 0], 'LineStyle', '--', 'LineWidth', 3, 'Color', 'k')
    plot([0 0], yLim, 'LineStyle', '--', 'LineWidth', 3, 'Color', 'k')

    % Draw reference lines
    xlim(xLim)
    ylim(yLim)

    axis equal
    set(gca, 'XDir','reverse', 'LineWidth', 3, 'FontSize', 18)



    alpha = 0:0.001:2*pi;

    for iW = 1:3

        % 
        xp = rm(iW)*cos(alpha);                         yp = rm(iW)*sin(alpha);
        
        % Convex
        if rm(iW) > 0
            iKill = ((xm(iW)-rm(iW)-xp)<0);
        % Concave
        elseif rm(iW) <= 0
            iKill = ((xm(iW)-rm(iW)-xp)>=0);
        end

        x = xm(iW)-rm(iW)-xp(~iKill);                      
        y = yp(~iKill); 
                             
        if isempty(x)
            x = [0 0];
            y = [-1 1];
        end 
        
        %% Wall thickness for incompressibility
        
        [theta,rho] = cart2pol(xp,yp);
        [xe,ye] = pol2cart(theta,(1-wth(iW))*rho);
        [xp,yp] = pol2cart(theta,(1+wth(iW))*rho);
        
        xe = xm(iW)-rm(iW)-xe(~iKill);        ye = ye(~iKill); 
        xp = xm(iW)-rm(iW)-xp(~iKill);        yp = yp(~iKill); 
        
        
        %%  Segment into patches
        
        patches = TriSeg.patches;
        iPatch = find(patches == iW);
        Lw(iW) = sum(sqrt(diff(x).^2+diff(y).^2));
        
        % Fraction of wall length that each patch takes up
        Ls = TriSeg.LsRef.*exp(ef);
        Lp = Ls(iPatch);
        frac = Lp/sum(Lp);
        
        
        %% Plot circle segment
        NL = length(x);
        for iP = 1:length(iPatch)
            if iP == 1
                iStart = 1;
            else
                iStart = ceil(sum(frac(1:(iP-1)))*NL)+1;
            end
            iEnd = floor(sum(frac(1:iP))*NL);
            
%             pGeo(i) = plot(x(iStart:iEnd), y(iStart:iEnd), 'LineWidth', 20, 'Color', cMap(i,:));
%             pGeo(i+3) = plot(xe(iStart:iEnd), ye(iStart:iEnd), 'LineWidth', 20, 'Color', cMap(i,:));
%             pGeo(i+6) = plot(xp(iStart:iEnd), yp(iStart:iEnd), 'LineWidth', 20, 'Color', cMap(i,:));
            
            patch([xe(iStart:iEnd) flip(xp(iStart:iEnd))],...
                   [ye(iStart:iEnd) flip(yp(iStart:iEnd))],...
                   cMap(iW,:), 'LineWidth', 3)
        end

        
    end
%             pGeo(i) = plot(x, y, 'LineWidth', 20, 'Color', cMap(i,:));

    xticks([-100 -50 0 50 100])
    yticks([-100 -50 0 50 100])
    
    drawnow 

    
