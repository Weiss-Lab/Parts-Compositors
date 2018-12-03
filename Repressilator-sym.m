%% DO NOT EDIT THIS BLOCK
urlwrite('http://keku.mit.edu/posb/part_composition_setup.m', ...
         'part_composition_setup.m');
rehash;
part_composition_setup('v2pre');
%% /DO NOT EDIT THIS BLOCK

%{

Oscillator simulation a la Stricker et al. Nature 2008

%}


%% Name your system

repressilator = BioSystem();


% Define and add your constants
%% Define your constants
max_time = 500;
tspan = [0 max_time];

plac_copy = 50; % copy number for plac promoter (# of molec/cell)
pr_copy = 50;   % copy number for lambda promoter
ptet_copy = 50; % copy number for ptet promoter

% Hill coefficients
repressilator.AddConstant(Const('n_LacI', 2.2));
repressilator.AddConstant(Const('n_cI', 2.2));
repressilator.AddConstant(Const('n_TetR', 2.2));

% on rate for repressor-promoter binding [1/(molec^n*min)]
repressilator.AddConstant(Const('k_on_plac', 10));
% off rate for repressor-promoter binding [1/min]
repressilator.AddConstant(Const('k_off_plac', 1));

% on rate for repressor-promoter binding
repressilator.AddConstant(Const('k_on_pr', 10));
% off rate for repressor-promoter binding
repressilator.AddConstant(Const('k_off_pr', 1));

% on rate for repressor-promoter binding
repressilator.AddConstant(Const('k_on_ptet', 10));
% off rate for repressor-promoter binding
repressilator.AddConstant(Const('k_off_ptet', 1));

% transcription rate for unbound promoter [1/min]
repressilator.AddConstant(Const('k_ts_plac', 100));
repressilator.AddConstant(Const('k_ts_pr', 100));
repressilator.AddConstant(Const('k_ts_ptet', 100));

% transcription rate for bound promoter
repressilator.AddConstant(Const('k_ts_low_plac', 0.0005));
repressilator.AddConstant(Const('k_ts_low_pr', 0.0005));
repressilator.AddConstant(Const('k_ts_low_ptet', 0.0005));

% degradation rate for transcript [1/min]
repressilator.AddConstant(Const('k_deg_mLacI', 10));
repressilator.AddConstant(Const('k_deg_mcI', 10));
repressilator.AddConstant(Const('k_deg_mTetR', 10));

% translation rate [1/min]
repressilator.AddConstant(Const('k_tl_mLacI', 5));
repressilator.AddConstant(Const('k_tl_mcI', 5));
repressilator.AddConstant(Const('k_tl_mTetR', 5));

% degradation rate for repressor [1/min]
repressilator.AddConstant(Const('k_deg_LacI', 0.1));
repressilator.AddConstant(Const('k_deg_cI', 0.1));
repressilator.AddConstant(Const('k_deg_TetR', 0.1));

%% Initialize your compositors, set initial conc for each species
% Format: speciesName = Compositor('speciesName', initial conc);

plac = Compositor('plac', plac_copy * 0.99); % initilize free plac conc
pr = Compositor('pr', pr_copy);
ptet = Compositor('ptet', ptet_copy);

plac_nLacI = Compositor('plac_nLacI', plac_copy * 0.01); % initialize bound plac conc
pr_ncI = Compositor('pr_ncI', 0);
ptet_nTetR = Compositor('ptet_nTetR', 0);

mLacI = Compositor('mLacI', 0); % initialize LacI mRNA conc
mcI = Compositor('mcI', 0);
mTetR = Compositor('mTetR', 0);

LacI = Compositor('LacI', 0); % initilize LacI conc
cI = Compositor('cI', 0);
TetR = Compositor('TetR', 0);


%% Add compositors to your system
% Format: systemName.AddCompositor('speciesName')

repressilator.AddCompositor(plac);
repressilator.AddCompositor(pr);
repressilator.AddCompositor(ptet);
repressilator.AddCompositor(plac_nLacI);
repressilator.AddCompositor(pr_ncI);
repressilator.AddCompositor(ptet_nTetR);
repressilator.AddCompositor(mLacI);
repressilator.AddCompositor(mcI);
repressilator.AddCompositor(mTetR);
repressilator.AddCompositor(LacI);
repressilator.AddCompositor(cI);
repressilator.AddCompositor(TetR);


%% Define your parts
% Format: partName = Part('partName', [ compositor matrix ],[ rate matrix ])
%   compositor matrix defines the order of species for the part
%   rate matrix must be in the same arrangement as compositor matrix
%   rate matrix format is [ Rate('expr1') Rate('expr1') ...] 

% plac sub-parts
Part1f = Part('plac + nLacI -> plac_nLacI', [plac; LacI; plac_nLacI], ...
    [ ...
        Rate('- k_on_plac * plac * LacI ^ n_LacI')
        Rate('- n_LacI * k_on_plac * plac * LacI ^ n_LacI')
        Rate('k_on_plac * plac * LacI ^ n_LacI') ...
    ]);

Part1r = Part('plac_nLacI -> plac + nLacI', [plac; LacI; plac_nLacI], ...
    [ ...
        Rate('k_off_plac * plac_nLacI')
        Rate('n_LacI * k_off_plac * plac_nLacI')
        Rate('- k_off_plac * plac_nLacI') ...
    ]);

Part2 = Part('plac -> mTetR + plac', [plac; mTetR], ...
    [ ...
        Rate('0')
        Rate('k_ts_plac * plac') ...
    ]);

Part3 = Part('plac_nLacI -> mTetR + plac_nLacI', [plac_nLacI; mTetR], ...
    [ ...
        Rate('0')
        Rate('k_ts_low_plac * plac_nLacI') ...
    ]);

Part4 = Part('mTetR -> 0', [mTetR], ...
    [ ...
        Rate('- k_deg_mTetR * mTetR') ...
    ]);

Part5 = Part('mTetR -> TetR + mTetR', [mTetR; TetR], ...
    [ ...
        Rate('0')
        Rate('k_tl_mTetR * mTetR') ...
    ]);

Part6 = Part('TetR -> 0', [TetR], ...
    [ ...
        Rate('- k_deg_TetR * TetR') ...
    ]);

% pr sub-parts
Part7f = Part('pr + ncI -> pr_cI', [pr; cI; pr_ncI], ...
    [ ...
        Rate('- k_on_pr * pr * cI ^ n_cI')
        Rate('- n_cI * k_on_pr * pr * cI ^ n_cI')
        Rate('k_on_pr * pr * cI ^ n_cI') ...
    ]);

Part7r = Part('pr_cI -> pr + ncI', [pr; cI; pr_ncI], ...
    [ ...
        Rate('k_off_pr * pr_ncI')
        Rate('n_cI * k_off_pr * pr_ncI')
        Rate('- k_off_pr * pr_ncI') ...
    ]);

Part8 = Part('pr -> mLacI + pr', [pr; mLacI], ...
    [ ...
        Rate('0')
        Rate('k_ts_pr * pr') ...
    ]);

Part9 = Part('pr_ncI -> mLacI + plr_ncI', [pr_ncI; mLacI], ...
    [ ...
        Rate('0')
        Rate('k_ts_low_pr * pr_ncI') ...
    ]);

Part10 = Part('mLacI -> 0', [mLacI], ...
    [ ...
        Rate('- k_deg_mLacI * mLacI') ...
    ]);

Part11 = Part('mLacI -> LacI + mLacI', [mLacI; LacI], ...
    [ ...
        Rate('0')
        Rate('k_tl_mLacI * mLacI') ...
    ]);

Part12 = Part('LacI -> 0', [LacI], ...
    [ ...
        Rate('- k_deg_LacI * LacI') ...
    ]);


% ptet sub-parts
Part13f = Part('ptet + nTetR -> ptet_nTetR', [ptet; TetR; ptet_nTetR], ...
    [ ...
        Rate('- k_on_ptet * ptet * TetR ^ n_TetR')
        Rate('- n_TetR * k_on_ptet * ptet * TetR ^ n_TetR')
        Rate('k_on_ptet * ptet * TetR ^ n_TetR') ...
    ]);

Part13r = Part('ptet_nTetR -> ptet + nTetR', [ptet; TetR; ptet_nTetR], ...
    [ ...
        Rate('k_off_ptet * ptet_nTetR')
        Rate('n_TetR * k_off_ptet * ptet_nTetR')
        Rate('- k_off_ptet * ptet_nTetR') ...
    ]);

Part14 = Part('ptet -> mcI + ptet', [ptet; mcI], ...
    [ ...
        Rate('0')
        Rate('k_ts_ptet * ptet') ...
    ]);

Part15 = Part('ptet_nTetR -> mcI + ptet_nTetR', [ptet_nTetR; mcI], ...
    [ ...
        Rate('0')
        Rate('k_ts_low_ptet * ptet_nTetR') ...
    ]);

Part16 = Part('mcI -> 0', [mcI], ...
    [ ...
        Rate('- k_deg_mcI * mcI') ...
    ]);

Part17 = Part('mcI -> cI + mcI', [mcI; cI], ...
    [ ...
        Rate('0')
        Rate('k_tl_mcI * mcI') ...
    ]);

Part18 = Part('cI -> 0', [cI], ...
    [ ...
        Rate('- k_deg_cI * cI') ...
    ]);



%% Add parts to your system
% Format: systemName.AddPart(partName);
repressilator.AddPart(Part1f);
repressilator.AddPart(Part1r);
repressilator.AddPart(Part2);
repressilator.AddPart(Part3);
repressilator.AddPart(Part4);
repressilator.AddPart(Part5);
repressilator.AddPart(Part6);
repressilator.AddPart(Part7f);
repressilator.AddPart(Part7r);
repressilator.AddPart(Part8);
repressilator.AddPart(Part9);
repressilator.AddPart(Part10);
repressilator.AddPart(Part11);
repressilator.AddPart(Part12);
repressilator.AddPart(Part13f);
repressilator.AddPart(Part13r);
repressilator.AddPart(Part14);
repressilator.AddPart(Part15);
repressilator.AddPart(Part16);
repressilator.AddPart(Part17);
repressilator.AddPart(Part18);

%% Run simulation for your time span
% Format: [time, outputs] = systemName.run(timeSpan)
[T, Y] = repressilator.run(tspan);

%% Plot your results (there are a lot of options for doing this)


figure(1)

subplot(2, 2, 1)
plot(T, Y(:, 10), T, Y(:, 11), T, Y(:, 12))
legend('LacI', 'cI', 'TetR')
xlabel('Time')
ylabel('Conc')

subplot(2, 2, 2)
plot(T, Y(:, 7), T, Y(:, 8), T, Y(:, 9))
legend('mLacI', 'mcI', 'mTetR')
xlabel('Time')
ylabel('Conc')

subplot(2, 2, 3)
plot(T, Y(:, 4), T, Y(:, 5), T, Y(:, 6))
axis([0 max_time 48 50])
legend('plac-nLacI', 'pr-ncI', 'ptet-nTetR')
xlabel('Time')
ylabel('Conc (molec/cell)')

subplot(2, 2, 4)
plot(T, Y(:, 1), T, Y(:, 2), T, Y(:, 3))
axis([0 max_time 0 2])
legend('plac','pr','ptet')
xlabel('Time')
ylabel('Conc (molec/cell)')
