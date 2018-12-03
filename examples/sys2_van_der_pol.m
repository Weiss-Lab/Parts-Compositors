%% this block fetches the framework: do not edit
urlwrite('http://web.mit.edu/20.305/www/part_composition_setup.m', ...
    'part_composition_setup.m');
rehash;
part_composition_setup('v5');
%% the system is constructed & simulated in the block below: feel free to edit

sys2 = BioSystem();

x = sys2.AddCompositor('x', 1);
y = sys2.AddCompositor('y', 0.5);

sys2.AddConstant('mu', 5);

% see https://en.wikipedia.org/wiki/Van_der_Pol_oscillator
sys2.AddPart(Part('Van der Pol wibbly-wobbly-timey-wimey (oscillator)', ...
    [x y], ...
    [ Rate('y') ... % x
      Rate('mu * (1 - x^2) * y - x'), ... % y
    ]));

f = figure();
hold all; % plot() will use same figure, different colors
time_interval = [0 80];
for mu = [0 5 25]
    sys2.ChangeConstantValue('mu', mu) % alter the value of mu
    [T, Y] = sys2.run(time_interval); % and rerun the simulation
    plot(T, Y(:, sys2.CompositorIndex('x')))
end
legend('\mu = 0', '\mu = 5', '\mu = 25')
xlabel('Time')
ylabel('Value of x')
title('Van der Pol oscillator for various parameters \mu')
saveas(f, 'sys2.pdf');
