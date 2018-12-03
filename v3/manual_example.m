urlwrite('http://web.mit.edu/20.305/www/part_composition_setup.m', ...
    'part_composition_setup.m');
rehash;
part_composition_setup('v3');



sys = BioSystem();
% create and add compositors and constants
A = Compositor('A', 10);
B = Compositor('B', 0);
E = Compositor('E', 1);
sys.AddCompositor(A); sys.AddCompositor(B); sys.AddCompositor(E);
sys.AddConstant(Const('k', 0.1));

% define and add the part(s)
reaction = Part('A + E -k> B + E', [A B E], ...
    [Rate('-k * A * E') Rate('k * A * E') Rate('0')]);
sys.AddPart(reaction);

% simulate the system from t = 0 to t = 25
[T Y] = sys.run([0 25]);

% plot the amount of B vs. time
figure();
plot(T, Y(:, 2)); % we added B as the second compositor to the system
xlabel('Time');
ylabel('Concentration of B');


% pulse in more A (substrate) at times 100, 200, 300:
[T, Y] = sys.run_pulses([...
    Pulse(0, 'A', 10), ... % initial conditions
    Pulse(100, 'A', 10), ... % spike in some A
    Pulse(200, 'A', 5), ... % spike in a bit less A
    Pulse(300, 'A', 10), ... % spike in more A again
    Pulse(400, '', 0), ... % stop the simulation at time 400 with this dummy, empty compositor
]);

figure();
hold on
plot(T, Y(:, 1), 'b'); % A
plot(T, Y(:, 2), 'g'); % B
xlabel('Time');
ylabel('Concentration')
