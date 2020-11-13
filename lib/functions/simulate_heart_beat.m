function [Volumes, Pressures, Valves, TriSeg]=simulate_heart_beat(...
                Volumes, resistances, capacitances, LVPars, RVPars,...
                t, simPars, solverSettings, plotPars,...
                etLV, etRV, detLV, TriSeg)


% This is where the magic happens, compartmental model core: find steady 
% state for the cardiac cycle. An RK4 formulation is used to forwardly
% compute volumes and pressures throughout the cardiac cycle, and the
% solution is considered converged if the initial volumes appromximate 
% the volumes at the end of the cardiac cycle in all compartments. 
            
            
%% Initiate    
            
% Detemine step sizes
dt = mean(diff(t));

% Extract solver settings
cutoff = solverSettings.cutoff;
iterMax = solverSettings.iterMax;

% Initial estimate: set final volumes equal to initial volumes
Volumes(end,:) = Volumes(1,:);

% Total stressed blood volume is equal to sum of all volume components
SBV = sum(Volumes(1,:)); 

% Initiate RK4 loop
iter = 0;
isTransientState = true;
SteadyState = true;

%% Solver loop

while isTransientState

    
    %% Initialize iteration

    iter = iter + 1;

    % Determining initial volumes from ending volumes in order to 
    % reach steady-state (i.e. volumes at beginning of  cardiac 
    % cycle should be the same as those at the end of the cycle for
    % every compartment if we're at stady state) 
    % Fix "Volume leakage" by ensuring sum is equal to SBV
    Volumes(1,:) = Volumes(end,:).*SBV./sum(Volumes(end,:)); 
            
    % Similar for TriSeg state variables
    if TriSeg.switch
        TriSeg.Ct(1,:) = TriSeg.Ct(end,:);              TriSeg.C = TriSeg.Ct(end,:);                     
        TriSeg.Lsct(1,:) = TriSeg.Lsct(end,:);          TriSeg.Lsc = TriSeg.Lsct(end,:);
    end
    % Calculate initial pressures, and volumes to prevent numerical 
    % error build-up
    [Pressures(1,:), Volumes(1,:), TriSeg] = calculate_pressuresandvolumesinitial(...
                Volumes(1,:), sum(Volumes(1,[2 7:end])), capacitances,... 
                LVPars, RVPars, simPars,TriSeg);

    %% Engine

    % Calculate pressures and volumes in all compartments throughout
    % the cardiac cycle
    for inc=2:length(t)
        
        %% Compute volumes (using RK4) and consequent pressure at the
        % current increment (inc).
        [Volumes(inc,:), Pressures(inc,:), TriSeg] = rk4(Volumes(inc-1,:), Pressures(inc-1,:), t(inc),...
            resistances, capacitances, LVPars, RVPars, dt, inc,...
            etLV, etRV, detLV, TriSeg);

    end
    
    
    %% Calculate if Steady-State has Occured

    absoluteError = abs(Volumes(end,:) - Volumes(1,:));
    outOfRangeLogical = absoluteError > cutoff;
    outOfRangeIndices = find(outOfRangeLogical);
    run1it = iter==1;                         % Ensure at least 1 iteration will occur
    nOutOfRange = numel(outOfRangeIndices) + run1it;
    isTransientState = nOutOfRange >= 1;
    if ~SteadyState
        isTransientState = 0;
    end

    % Start spreading the news
    str = sprintf(['Iter ', num2str(iter), ...
    '. \tErrors: ', num2str(absoluteError)]);

    % Display in command window
    disp(str);

    % Store errors in text file if desired
    if ~plotPars.plotKill
        fid = fopen(fullfile(plotPars.figDir,'solver.log'), 'a');
        fprintf(fid, [str ,'\n']);
        fclose(fid);
    end

    % Emergency brake, if too many iterations have occurred
    if iter > iterMax 
        error('Maximum allowed number of iterations has been reached')
    end
    
    
end         % End of main while loop


% Check if valves are open or closed, based on pressure
% differences
Valves = valve_status(Pressures);


end
