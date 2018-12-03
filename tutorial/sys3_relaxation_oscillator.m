sys3 = BioSystem();

A = sys3.AddCompositor('A', 10); mA = sys3.AddCompositor('mA', 1);
B = sys3.AddCompositor('B', 10); mB = sys3.AddCompositor('mB', 1);

sys3.AddConstant('k_tx', 5); sys3.AddConstant('k_tl', 5);
sys3.AddConstant('k_mdeg', 0.5); sys3.AddConstant('k_pdeg', 0.05);
sys3.AddConstant('K_A', 1); sys3.AddConstant('K_B', 2);
sys3.AddConstant('n', 2);

sys3.AddPart(Part('Transcription of A', [mA], ...
    [ Rate('k_tx * A^n / (K_A^n + A^n) * K_B^n / (K_B^n + B^n)') ]));

sys3.AddPart(Part('Transcription of B', [mB], ...
    [ Rate('k_tx * A^n / (K_A^n + A^n)') ]));

sys3.AddPart(Part('Translation of A', [A], ...
    [ Rate('k_tl * mA') ]));
sys3.AddPart(Part('Translation of B', [B], ...
    [ Rate('k_tl * mB') ]));

sys3.AddPart(Part('Degradation of A', [A], ...
    [ Rate('- k_pdeg * A') ]));
sys3.AddPart(Part('Degradation of mA', [mA], ...
    [ Rate('- k_mdeg * mA') ]));
sys3.AddPart(Part('Degradation of B', [B], ...
    [ Rate('- k_pdeg * B') ]));
sys3.AddPart(Part('Degradation of mB', [mB], ...
    [ Rate('- k_mdeg * mB') ]));

figure();
[T, Y] = sys3.run([0 2000]);
plot(T, Y);
legend('A', 'm_A', 'B', 'm_B');
xlabel('Time');
ylabel('Concentration');
