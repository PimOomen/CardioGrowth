function plotValves(t, AVOpens, AoCloses, MVOpens, MVCloses, YLim)

fill(t([AVOpens AoCloses AoCloses AVOpens]), YLim([1 1 2 2]), [0.9 0.9 0.9], 'EdgeColor', 'None')

plot(repmat(t(AVOpens), [1 2]), YLim, ':k', 'LineWidth', 3)
plot(repmat(t(AoCloses), [1 2]), YLim, ':k', 'LineWidth', 3)
plot(repmat(t(MVCloses), [1 2]), YLim, '--k', 'LineWidth', 3)
plot(repmat(t(MVOpens), [1 2]), YLim, '--k', 'LineWidth', 3)