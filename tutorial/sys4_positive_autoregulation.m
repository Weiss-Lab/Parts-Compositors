sys4 = BioSystem();

A = sys4.AddCompositor('A', 10);
mA = sys4.AddCompositor('mA', 1);

sys4.AddConstant('k_tx', 5); sys4.AddConstant('k_tl', 5);
sys4.AddConstant('k_mdeg', 0.5); sys4.AddConstant('k_pdeg', 0.05);
sys4.AddConstant('K_A', 1);
sys4.AddConstant('n', 2);

sys4.AddPart(Part('Transcription of A', [mA], ...
    [ Rate('k_tx * A^n / (K_A^n + A^n)') ]));

sys4.AddPart(Part('Translation of A', [A], ...
    [ Rate('k_tl * mA') ]));

sys4.AddPart(Part('Degradation of A', [A], ...
    [ Rate('- k_pdeg * A') ]));

sys4.AddPart(Part('Degradation of mA', [mA], ...
    [ Rate('- k_mdeg * mA') ]));

figure();
[T, Y] = sys4.run([0 2000]);
plot(T, Y);
legend('A', 'm_A');
xlabel('Time');
ylabel('Concentration');
