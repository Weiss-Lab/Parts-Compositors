sys2 = BioSystem();

x = sys2.AddCompositor('x', 1);
y = sys2.AddCompositor('y', 0.5);

sys2.AddConstant('mu', 5);

sys2.AddPart(Part('Van der Pol wibbly-wobbly-timey-wimey', [x y], ...
    [ Rate('y') ... % x
      Rate('mu * (1 - x^2) * y - x'), ... % y
    ]));

figure();
hold all; % plot() will use same figure, different colors
time_interval = [0 80];
for mu = [0 5 25]
    sys2.ChangeConstant('mu', mu)
    [T, Y] = sys2.run(time_interval);
    plot(T, Y(:, 1))
end
legend('\mu = 0', '\mu = 5', '\mu = 25')
xlabel('Time')
ylabel('Value')
