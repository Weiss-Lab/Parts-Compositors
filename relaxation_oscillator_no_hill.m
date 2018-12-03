sys_relaxation_oscillator = BioSystem();

A = sys_relaxation_oscillator.AddCompositor('A', 100);
pA = sys_relaxation_oscillator.AddCompositor('pA', 0.01);
pA_A = sys_relaxation_oscillator.AddCompositor('pA_A', 0);
pA_B = sys_relaxation_oscillator.AddCompositor('pA_B', 0);
pA_AB = sys_relaxation_oscillator.AddCompositor('pA_AB', 0);
mA = sys_relaxation_oscillator.AddCompositor('mA', 1);
B = sys_relaxation_oscillator.AddCompositor('B', 0);
mB = sys_relaxation_oscillator.AddCompositor('mB', 0);
pB = sys_relaxation_oscillator.AddCompositor('pB', 0.01);
pB_A = sys_relaxation_oscillator.AddCompositor('pB_A', 0);

sys_relaxation_oscillator.AddConstant('n_A', 2);
sys_relaxation_oscillator.AddConstant('n_B', 4);
sys_relaxation_oscillator.AddConstant('k_txn', 1);
% transcription rate multipliers
sys_relaxation_oscillator.AddConstant('a_0', 0);   % no TFs bound
sys_relaxation_oscillator.AddConstant('a_A', 1);      % A bound
sys_relaxation_oscillator.AddConstant('a_B', 0);   % B bound
sys_relaxation_oscillator.AddConstant('a_AB', 0);  % A and B bound

sys_relaxation_oscillator.AddConstant('k_tln', 1);
sys_relaxation_oscillator.AddConstant('k_mdeg', 1);
sys_relaxation_oscillator.AddConstant('k_pdeg', 1);

% forward and reverse rates for A-promoter and B-promoter binding
sys_relaxation_oscillator.AddConstant('k_af', 10);
sys_relaxation_oscillator.AddConstant('k_ar', 10);
sys_relaxation_oscillator.AddConstant('k_bf', 10);
sys_relaxation_oscillator.AddConstant('k_br', 10);

sys_relaxation_oscillator.AddPart(Part('mA: transcription & degradation', ...
    [mA], ...
    [ Rate('250 * k_txn * (a_0 * pA + a_A * pA_A + a_B * pA_B + a_AB * pA_AB) - k_mdeg * mA') ]));

sys_relaxation_oscillator.AddPart(Part('mB: transcription & degradation', ...
    [mB], ...
    [ Rate('30 * k_txn * (a_0 * pB + a_A * pB_A) - k_mdeg * mB') ]));

sys_relaxation_oscillator.AddPart(Part('A-promoter(s) binding', ...
    [ A pA pA_A pA_AB pB pB_A ], ...
    [ Rate('-n_A * k_af * A^n_A * (pA + pB + pA_B) + n_A * k_ar * (pA_A + pB_A + pA_AB)'), ... % A
      Rate('-k_af * A^n_A * pA + k_ar * pA_A'), ... % pA
      Rate('k_af * A^n_A * pA - k_ar * pA_A'), ... % pA_A
      Rate('k_af * A^n_A * pA_B - k_ar * pA_AB'), ... % pA_AB
      Rate('-k_af * A^n_A * pB + k_ar * pB_A'), ... % pB
      Rate('k_af * A^n_A * pB - k_ar * pB_A'), ... % pB_A
    ]));

sys_relaxation_oscillator.AddPart(Part('B-promoter binding', ...
    [ B pA pA_B pA_A pA_AB ], ...
    [ Rate('-n_B * k_bf * B^n_B * (pA + pA_A) + n_B * k_br * (pA_B + pA_AB)') , ... % B
      Rate('-k_bf * B^n_B * pA + k_br * pA_B') , ... % pA
      Rate('k_bf * B^n_B * pA - k_br * pA_B') , ... % pA_B
      Rate('-k_bf * B^n_B * pA_A + k_br * pA_AB') , ... % pA_A
      Rate('k_bf * B^n_B * pA_A - k_br * pA_AB') , ... % pA_AB
    ]));

sys_relaxation_oscillator.AddPart(Part('A: translation & degradation', ...
    [A], ...
    [ Rate('k_tln * mA - k_pdeg * A') ]));

sys_relaxation_oscillator.AddPart(Part('B: translation & degradation', ...
    [B], ...
    [ Rate('k_tln * mB - 0.5 * k_pdeg * B') ]));

%min_input = 0.01;
%max_input = 50;
%datapoints = 10;
%[inputs, outputs] = transfer_function(sys_relaxation_oscillator, 'A', 'A', min_input, max_input, datapoints);
%semilogx(inputs, outputs);
%hold all;


figure();
[T, Y] = sys_relaxation_oscillator.run([0 1500]);
plot(T, Y);
legend('A', 'pA', 'pA_A', 'pA_B', 'pA_{AB}', 'mA', 'B', 'mB', 'pB', 'pB_A');
xlabel('Time');
ylabel('Concentration');