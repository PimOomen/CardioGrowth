function CURE = getCURE(eps0)

%%

[U,S,V] = svd(eps0);
eps0 = U(:,1:1)*S(1:1,1:1)*V(:,1:1)';

% CURE = zeros(length(eps0),1);

% for i = 1:size(eps0,2)

    % Take one column - all columns give the same answer
    col = eps0(:,1);

    % Take Fourier transform and absolute value 
    fcol = abs(fft(col));

    % Calculate the CURE: f0/(f0+f1)
    CURE = fcol(1)/(fcol(1)+fcol(2));

% end