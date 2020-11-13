function [sig,siga,sigp,dsigdlabf,Lsc,C] = getStressTriSeg(labf,Lsc,C,t, TriSeg)

    % Active stress adopted from Walmsley et al., PLoS Comp Biol 2015    

    %%  Load input parameters
    LsRef = TriSeg.LsRef;       % [um]       Sarcomere reference length
    Lseiso = TriSeg.Lseiso;     % [um]        Isometrically stresses series elastic element
    Lsc0 = TriSeg.Lsc0;         % [um]        Contractile element length
    vMax = TriSeg.vMax*1e3;     % [um/ms]      Sarcomere shortening velocity
    k1 = TriSeg.k1;             % [MPa]         Passive properties
    k3 = TriSeg.k3;             % [MPa]
    k4 = TriSeg.k4;             % [-]
    SfAct = TriSeg.SfAct;       % [MPa]         Maximum active stress
    TR = TriSeg.TR;             % [-]           Rise time
    TD = TriSeg.TD;             % [-]           Decay time
    TAct = TriSeg.TAct;         % [ms]          Base total time of activation
    
    
    %% Kinematics
    
    % Sarcomere and contractile element length 
    Ls = labf*LsRef;
    
    % Contractile element length
    Lsc = max(Lsc,1.0001*Lsc0);     % Prevent Lsc from going beyond reference length
    LscNorm  = max(Lsc./Lsc0-1,0.0001) ; % normalized contractile element length
    
    % Normalized series elastic element
    LseNorm = (Ls-Lsc)./Lseiso;
    
    
    %% Time constants
    
    % Shift time to have t = 0 at tActivation
    ta = (t - TriSeg.tActivation);             % [ms]

    % Constants related to timing are mainly based on experimental findings
    tA = (0.65+1.0570*LscNorm)*TAct; % activation time lengthens with sarcomere length
    tR = TR*TAct        ; % rise time
    tD = TD.*TAct./(0.5.*(0.65+1.0570.*LscNorm)); % decay time (default 0.22)   Assume repolarization is not length-dependent
    T  = ta/tR;        
    
    
    %% Active stress

    SfIso    = (C.* LscNorm).*(Lsc0.*SfAct) ;        % Isometric component
    siga     = SfIso.*LseNorm;
    dsigadlabf = (SfIso.*Ls./labf)/Lseiso;

    
    %% Passive stress
    % Exponential function similar to Estrada 2019, J Biomech Eng
    
    sigp = k1.*(labf - 1) + k3.*(exp(k4.*max(labf-1,0)) - 1);
    dsigpdlabf = k1 + k3.*k4.*exp(k4.*max(labf-1,0));
    
    
    %% Total stress
    
    sig = siga + sigp;
    dsigdlabf = dsigpdlabf + dsigadlabf;

    
    %% Update state variables
    
    % Length and time-dependent quantities to update C
    x = min(8,max(0,T));                          % normalized time during rise of activation
    Frise = x.^3 .* exp(-x) .* (8-x).^2 * 0.020; % rise of contraction, 'amount of Ca++ release'
    x =(ta-tA)/tD;                               % normalized time during decay of activation
    gx = 0.5+0.5*sin( sign(x).*min(pi/2,abs(x)) ); %always>0
    FL = tanh(0.75*9.1204*LscNorm.^2);                 % regulates increase of contractility with Ls
    
    % State variable 1: contractile element length
    dLscdt = (LseNorm - 1).*vMax;
    Lsc = Lsc + TriSeg.dt*1e-3*dLscdt;
    
    % State variable 2: mechanical activation (only for non-ischemic patches)
    dCdt = (FL.*Frise ./ tR - C.*gx./tD);%.*(1-TriSeg.Ischemic);
    C = C + TriSeg.dt*dCdt;


end


    