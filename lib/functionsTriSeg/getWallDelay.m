function [WMD, SD] = getWallDelay(TriSeg,t)

% Get wall motion delay (WMD, time between inward motion of septal and 
% lateral wall) and shortening delay (SD)

t = t*1e3;      % [s -> ms]

%% Get time of first inward motion

% Get wall position, invert Lfw to have all inward motion being negative
xm = TriSeg.xm.*[-1 1 1];

dxmdt = zeros(size(TriSeg.xm));
iWM = zeros(1,3);
for i = 1:3
    dxmdt(:,i) = gradient(xm(:,i),t);
    % Find time points
    iWM(i) = find(dxmdt(:,i) < -0.2*max(dxmdt(:)), 1, 'first');
end

WMD = t(iWM(1)) - t(iWM(3));


%% Get shortening delay

lab = TriSeg.labfw;
dlabdt = zeros(size(lab));
iSD = zeros(1,3);
for i = 1:3
    dlabdt(:,i) = gradient(lab(:,i),t);
    % Find time points
    iSD(i) = find(dlabdt(:,i) < -0.2*max(dlabdt), 1, 'first');
end

SD = t(iSD(1)) - t(iSD(3));


%% Plot

c = lines; c = c([2 1 3],:);

% figure; hold on
% for i = 1:3
%     plot(t, xm(:,i), 'LineWidth', 3, 'Color', c(i,:))
%     plot(t(iWM(i)), xm(iWM(i),i), 'o', 'MarkerSize', 10, 'LineWidth', 3, 'Color', c(i,:))
% end
% set(gca, 'LineWidth', 3, 'FontSize', 18)
% xlabel('Time ms')
% ylabel('Wall motion (mm)')
% 
% figure; hold on
% for i = 1:3
%     plot(t, lab(:,i), 'LineWidth', 3, 'Color', c(i,:))
%     plot(t(iSD(i)), lab(iSD(i),i), 'o', 'MarkerSize', 10, 'LineWidth', 3, 'Color', c(i,:))
% end
% set(gca, 'LineWidth', 3, 'FontSize', 18)
% xlabel('Time ms')
% ylabel('Wall stretch (mm)')