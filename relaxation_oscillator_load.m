%%
urlwrite('http://web.mit.edu/20.305/www/part_composition_setup.m', ...
    'part_composition_setup.m');
rehash;
part_composition_setup('v3');
%%

sys_relaxation_oscillator = BioSystem();

A = sys_relaxation_oscillator.AddCompositor('A', 0.0769166764574148);
m_A = sys_relaxation_oscillator.AddCompositor('m_A', 0.000718843252681972);
B = sys_relaxation_oscillator.AddCompositor('B', 5.99961334451348);
m_B = sys_relaxation_oscillator.AddCompositor('m_B', 0.0591495456516779);
p = sys_relaxation_oscillator.AddCompositor('p', 4.10285808401772);
pA = sys_relaxation_oscillator.AddCompositor('pA', 0);

sys_relaxation_oscillator.AddConstant('k_txn', 5);
sys_relaxation_oscillator.AddConstant('k_tln', 5);
sys_relaxation_oscillator.AddConstant('k_mdeg', 0.5);
sys_relaxation_oscillator.AddConstant('k_pdeg', 0.05);
sys_relaxation_oscillator.AddConstant('K_A', 1);
sys_relaxation_oscillator.AddConstant('K_B', 2);
sys_relaxation_oscillator.AddConstant('n_A', 2);
sys_relaxation_oscillator.AddConstant('n_B', 4);

sys_relaxation_oscillator.AddConstant('k_on', 50);
sys_relaxation_oscillator.AddConstant('k_off', 50);

sys_relaxation_oscillator.AddPart(Part('Transcription of A', [m_A], ...
    [ Rate('k_txn * A^n_A / (K_A^n_A + A^n_A) * K_B^n_B / (K_B^n_B + B^n_B)') ]));

sys_relaxation_oscillator.AddPart(Part('Transcription of B', [m_B], ...
    [ Rate('k_txn * A^n_A / (K_A^n_A + A^n_A)') ]));

sys_relaxation_oscillator.AddPart(Part('Translation of A', [A], ...
    [ Rate('k_tln * m_A') ]));
sys_relaxation_oscillator.AddPart(Part('Translation of B', [B], ...
    [ Rate('k_tln * m_B') ]));

sys_relaxation_oscillator.AddPart(Part('Degradation of A', [A], ...
    [ Rate('- k_pdeg * A') ]));
sys_relaxation_oscillator.AddPart(Part('Degradation of m_A', [m_A], ...
    [ Rate('- k_mdeg * m_A') ]));
sys_relaxation_oscillator.AddPart(Part('Degradation of B', [B], ...
    [ Rate('- k_pdeg * B') ]));
sys_relaxation_oscillator.AddPart(Part('Degradation of m_B', [m_B], ...
    [ Rate('- k_mdeg * m_B') ]));

sys_relaxation_oscillator.AddPart(Part('loading of A', [A p pA], ...
    [ Rate('- n_A * k_on * A ^ n_A * p + n_A * k_off * pA'), ... % A
      Rate('- k_on * A ^ n_A * p + k_off * pA'), ... % p
      Rate('k_on * A ^ n_A * p - k_off * pA'), ... % pA
    ]));

figure();
legend('off'); legend('on');
hold all;

for p_tot=[3 4 5]
    p_tot
    sys_relaxation_oscillator.ChangeInitialValue('p', p_tot);
    sys_relaxation_oscillator.ChangeInitialValue('pA', 0);
    [T, Y] = sys_relaxation_oscillator.run([0 5000]);
    plot(T, Y(:,sys_relaxation_oscillator.map_compositors('B')), ...
         'DisplayName', sprintf('p_{tot} = %g', p_tot));
end

legend(gca, 'show')
xlabel('Time');
ylabel('Concentration');