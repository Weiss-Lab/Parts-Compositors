%% this block fetches the framework: do not edit
urlwrite('http://web.mit.edu/20.305/www/part_composition_setup.m', ...
    'part_composition_setup.m');
rehash;
part_composition_setup('v5');
%% the system is constructed & simulated in the block below: feel free to edit

sys1 = BioSystem();

% create compositors, set initial state
E1 = sys1.AddCompositor('E1', 10); % units implied
M1 = sys1.AddCompositor('M1', 10);
M2 = sys1.AddCompositor('M2', 0);

sys1.AddConstant('k_cat', 10); % units implied
sys1.AddConstant('K_m', 5);

P1 = Part('M1-(E1)->M2', [M1 E1 M2], ...
          [ Rate('- k_cat * E1 * (M1 / (K_m + M1))') ... % M1
            Rate('0'), ... % E1
            Rate('  k_cat * E1 * (M1 / (K_m + M1))') ... % M2
          ]);
 
sys1.AddPart(P1);

[T, Y] = sys1.run([0 3]); % units implied
f = figure();
plot(T, Y);
legend('E_1', 'M_1', 'M_2');
xlabel('Time (s)'); % here we decided to interpret the units of time as seconds
ylabel('Concentration (nM)'); % and nanomolar for concentration
axis([0 3 -0.5 10.5]);
title({'Enzymatic reaction modeling with Michaelis-Menten', ...
       'like saturating kinetics'});
saveas(f, 'sys1.pdf');
