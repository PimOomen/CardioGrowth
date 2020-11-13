% Initialize patch properties and time storage arrays of TriSeg structure

function TriSeg = TriSegInit(TriSeg,t,Volumes, ConSol)
  
TriSeg.switch = true;

% Total number of patches across all walls
NPatchesTot = sum(TriSeg.NPatches);

% Number of time steps
Nt = length(t);

% Walls
TriSeg.rm = zeros(Nt,3);
TriSeg.xm = zeros(Nt,3);
TriSeg.Amw = zeros(Nt,3);
TriSeg.labfw = zeros(Nt,3);

% Cavity
TriSeg.P = zeros(Nt,2);

% Patches
TriSeg.Am = zeros(Nt,NPatchesTot);
TriSeg.H = zeros(Nt,NPatchesTot);
TriSeg.labf = zeros(Nt,NPatchesTot);
TriSeg.Ls = repmat(TriSeg.LsRef, [Nt NPatchesTot]); 
TriSeg.sig = zeros(Nt,NPatchesTot);
TriSeg.siga = zeros(Nt,NPatchesTot);
TriSeg.sigp = zeros(Nt,NPatchesTot);

% Ischemia, scale with degree of ischemia, so for fully ischemic patch
% active stress equals zero
TriSeg.SfAct = TriSeg.SfAct.*(1-TriSeg.Ischemic);

TriSeg.LseNorm = zeros(Nt,NPatchesTot);

% Time step
TriSeg.dt = 1e3*mean(diff(t));

TriSeg.NPatchesTot = NPatchesTot;

%% Initial TriSeg solver estimates and state variables

% Guess...
TriSeg.VS = 0.2*mean(Volumes(1,[2 5]))*1e2;                 % [cm^3 -> mm^2]
TriSeg.YS = mean((3/4*Volumes(1,[2 5])/pi).^(1/3))*1e1;     % [cm -> mm]
TriSeg.Ct = repmat(TriSeg.Crest,[Nt NPatchesTot]);
TriSeg.Lsct = repmat(TriSeg.LsRef-TriSeg.Lseiso,[Nt NPatchesTot]);

% ... or load previous simulation values if existing
if isfield(ConSol, 'C')
    if (size(ConSol.C,2) == NPatchesTot)
        TriSeg.VS = ConSol.VS;
        TriSeg.YS = ConSol.YS;
        TriSeg.Ct(Nt,1:NPatchesTot) = ConSol.C;
        TriSeg.Lsct(Nt,1:NPatchesTot) = ConSol.Lsc;
    end
end

