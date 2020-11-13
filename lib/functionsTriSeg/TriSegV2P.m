function TriSeg = TriSegV2P(TriSeg, VLVRV, t, inc)

    % Solve TriSeg balance of forces and calculate ventricular pressures,
    % adopted from Walmsley et al., PLOS COmp Biol 2015, and Lumens et al.,
    % Annals of Biomed Eng 2009.
    % Total LV and RV volume is already known from RK4

    %% Get state variables and previous solver results
    
    Lsc = TriSeg.Lsc;
    C = TriSeg.C;
    VS = TriSeg.VS;
    YS = TriSeg.YS;
    
    % Convert units to mm and ms (to work in MPa/ 
    VLVRV = VLVRV*1e3;      % [mL to mm^3]
    t = t*1e3;              % [s -> ms]


    %% MultiPatch stiffness and unloaded area
    
    % Kinematics for Ls = Lsc
    labf = TriSeg.Lsc./TriSeg.LsRef;
    
    % Stress and stress derivative
    [sig,~,~,dsigdlabf,~,~] = getStressTriSeg(labf,Lsc,C,t,TriSeg);
    
    Am = (labf).^2.*TriSeg.AmRef;        % Eq 9
    Tm = sig.*TriSeg.Vwv./(2.*Am);                         % Eq 11
         
    % Patch stiffness and estimated unloaded area   
    DADT = 4.*Am.^2./TriSeg.Vwv./(dsigdlabf.*labf - 2.*sig);      % Eq 13
%     DADT = 4.*Am.^2./TriSeg.Vwv./max(dsigdef - 2.*sig,ef);      % Eq 13   why like this in the CircAdapt code?
    Am0 = Am - Tm.*DADT;                          % Eq 14
    
    % Wall stiffness and unloaded area, sum of all patches in each wall
    Amw0 = zeros(1,3);       Amw = zeros(1,3);       DADTw = zeros(1,3);
    for i = 1:3
        Amw0(i) = sum(Am0(TriSeg.patches==i));         % Eq 6
        Amw(i) = sum(Am(TriSeg.patches==i));         % Eq 6
        DADTw(i) = sum(DADT(TriSeg.patches==i));       % Eq 7
    end
    
    
    %% Local Newton iterations to solve balance of tension
    
    % Enclosed midwall volumes of L and R walls if they would be perfect
    % spheres, prevent ventricular suction
    VmL =  max(VLVRV(1) + 0.5*(TriSeg.Vwvw(1) + TriSeg.Vwvw(3)), 0);
    VmR =  max(VLVRV(2) + 0.5*(TriSeg.Vwvw(2) + TriSeg.Vwvw(3)), 0);    
    
    % Initialize Newton scheme
%     errMax = TriSeg.relativeError*abs(mean(Tmw0));
    errMax = 1e-6;
    err = 10*errMax;
    iter = 0;
%     dV = 0.01*mean([VmL VmR]);         dY = 0.02.*abs(TriSeg.YS).^(1/3);   % 10% slower, abs to prevent dY going complex for YS<0
     dV = 1e3;                         dY = 0.05;       % [1mL / 0.05 mm]
    % Initial estimate of tensions
    [Tx,Ty,~,~,~,~] = Txy(VmL,VmR,VS,YS, Amw0,DADTw);

    while ((err > errMax) && (iter < 10))
        
        % Perturb solution
        [TxV,TyV,~,~,~,~] = Txy(VmL,VmR,VS+dV,YS, Amw0,DADTw);
        [TxY,TyY,~,~,~,~] = Txy(VmL,VmR,VS,YS+dY, Amw0,DADTw);

        % Inverse Jacobian matrix and determinant
        dTxdV = (TxV - Tx)./dV;                  dTydV = (TyV - Ty)./dV;
        dTxdY = (TxY - Tx)./dY;                  dTydY = (TyY - Ty)./dY;
        DetJ = dTxdV.*dTydY-dTxdY.*dTydV;
        
        % Update solution
        if (DetJ < 1e-20)   % If perturbation does not lead to change, local minumum already found, prevents dividing by 0
            dV = 0;                             dY = 0;         
        else
            dV = (-dTydY.*Tx+dTxdY.*Ty)./DetJ;   dY = (+dTydV.*Tx-dTxdV.*Ty)./DetJ;  
        end

        % Update parameters
        VS = VS + dV;
        YS = YS + dY;
        
        % Updated estimate
        [Tx,Ty,Tmw,Amw,rm,xm] = Txy(VmL,VmR,VS,YS, Amw0,DADTw);

        % Calculate error
        err = abs(Tx)+abs(Ty);
        iter = iter + 1;
        
        % Convergence criterion satisfied
        if (DetJ < 1e-20)
            err = 0.1*errMax;
        end
    end
    
    
    %% Get true stresses and update state variables
    
    Am = Am0 + Tmw(TriSeg.patches).*DADT;
    labf = sqrt(Am./TriSeg.AmRef);
    labfw = sqrt(Amw./TriSeg.AmRefw);
    Ls = TriSeg.LsRef.*labf;
    
    [sig,siga,sigp,~,Lsc,C] = getStressTriSeg(labf,Lsc,C,t,TriSeg);
    
    
    %% Output to structure
    
    % Transmural pressure for LV and RV
    TriSeg.P(inc,:) = 2.*Tmw(1:2)./abs(rm(1:2))*7.5e3;          % [MPa -> mmHg]       

    % Output solver results
    TriSeg.VS = VS;
    TriSeg.YS = YS;
    
    % Kinematics and dimensions
    TriSeg.labfw(inc,:) = labfw;
    TriSeg.labf(inc,:) = labf;
    TriSeg.Amw(inc,:) = Amw;
    TriSeg.Am(inc,:) = Am;
    TriSeg.Ls(inc,:) = Ls;
    TriSeg.rm(inc,:) = rm;
    TriSeg.xm(inc,:) = xm;
    TriSeg.H(inc,:) = TriSeg.Vwv./Am;
    
    % Stresses
    TriSeg.sig(inc,:) = sig;
    TriSeg.siga(inc,:) = siga;
    TriSeg.sigp(inc,:) = sigp;
    
    %% State variables
    TriSeg.Lsc = Lsc;
    TriSeg.C = C;
    TriSeg.Lsct(inc,:) = Lsc;
    TriSeg.Ct(inc,:) = C;
    TriSeg.LseNorm(inc,:) = (Ls - Lsc)./TriSeg.Lseiso;

end

% Calculate tension and geometry for given Vs and Ys
function [Tx,Ty,Tm,Am,rm,xm] = Txy(VmL,VmR,VS,YS, Am0,DADT)
    
    %% Wall volumes and lengths
    
    % Adjust L and R spherical midwall volumes to satisfy VLV and VRV
    % VL = -VLV + VS;   VR = VRV + VS;  VS = VS_est
    Vm= [VmL VmR VS]* ...
        [-1     0     0
          0     1     0
          1     1     1];
    
    % Estimate xm from Eq. 9 from CircAdapt derivation
    % Solving 3rd order polynomial
    SignVm = sign(Vm); Vm=abs(Vm);
    V = (3/pi)*Vm;
    Q = (V + sqrt(V.^2 + YS.^6)).^(1/3);
    xm = SignVm .* ( Q - YS.^2 ./ Q );

    rm = (xm.^2 + YS.^2)./(2.*xm);   % Eq. 11
    Am = max(pi*(xm.^2 + YS.^2),Am0);         % Eq. 10


    %% Calculate midwall tension in x and y
                                
    Tm = (Am-Am0)./DADT;                    % [N/mm]

    Tx = sum(YS./rm.*Tm);
    Ty = sum((YS.^2-xm.^2)./(xm.^2 + YS.^2).*Tm);
    
end