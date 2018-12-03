sys3 = BioSystem();

A = sys3.AddCompositor('A', 10);
B = sys3.AddCompositor('B', 9);

sys3.AddConstant('k_prod', 5);
sys3.AddConstant('k_deg', 0.5);
sys3.AddConstant('K_A', 1);
sys3.AddConstant('K_B', 0.01);

sys3.AddPart(Part('self-activation of A', [A], ...
    [ Rate('0.5 * k_prod * A / (K_A + A)') ]));

sys3.AddPart(Part('cross-activation of B by A', [B], ...
    [ Rate('k_prod * A / (K_A + A)') ]));

sys3.AddPart(Part('cross-repression of A by B', [A], ...
    [ Rate('k_prod * K_B / (K_B + B)') ]));

sys3.AddPart(Part('degradation of A', [A], ...
    [ Rate('- k_deg * A') ]));

sys3.AddPart(Part('degradation of B', [B], ...
    [ Rate('- k_deg * B') ]));

figure();
hold all; % plot() will use same figure, different colors
time_interval = [0 80];
[T, Y] = sys3.run(time_interval);
plot(T, Y)

legend('A', 'B')
xlabel('Time')
ylabel('Concentration')
