function lab = getStretch(V, V0, labPre)

% Calculate stretch
lab = (V./V0).^(1/3)*labPre;