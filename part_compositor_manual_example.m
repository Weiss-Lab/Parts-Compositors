%% this block fetches the framework: do not edit
urlwrite('http://web.mit.edu/20.305/www/part_composition_setup.m', ...
    'part_composition_setup.m');
rehash;
part_composition_setup('v5');
%% the system is constructed & simulated in the block below: feel free to edit

sys = BioSystem();
% create and add constants and compositors
sys.AddConstant('k', 0.1);
dAdt = sys.AddCompositor('A', 10); % state variable representing the rate of
% change of the concentration of A, which starts initial absolute value
% A(0) = 0
dBdt = sys.AddCompositor('B', 0);
dEdt = sys.AddCompositor('E', 1);

% define and add the part(s)
reaction = Part('A + E -k> B + E', ...
    [dAdt dBdt dEdt], ... % this process involves A, B, E
    [Rate('-k * A * E') Rate('k * A * E') Rate('0')]); % how this process affects A, B, E
sys.AddPart(reaction);

% simulate the system from t = 0 to t = 25
[T, Y] = sys.run([0 25]); % T holds a vector of time and Y is a matrix where
% each row is a vector of the values of the system variables corresponding to
% the compositors (in order of addition) for each moment of time in T

% plot the amount of B vs. time
figure();
plot(T, Y(:, sys.CompositorIndex('B'))); % the second compositor added to the
% system was for B, so CompositorIndex('B') returns 2
xlabel('Time');
ylabel('Concentration of B');
title('Enzymatic conversion of a fixed amount of A to B');


% different simulation: pulse in more A (substrate) at times 100, 200, 300:
[T, Y] = sys.run_pulses([...
    Pulse(0, 'A', 10), ... % initial conditions
    Pulse(100, 'A', 10), ... % spike in some A
    Pulse(200, 'A', 5), ... % spike in a bit less A
    Pulse(300, 'A', 10), ... % spike in more A again
    Pulse(400, '', 0), ... % stop the simulation with this empty compositor
]);

figure(); % create new figure
hold on % plot the following things on the same figure
plot(T, Y(:, sys.CompositorIndex('A')), 'b'); % A in [b]lue
plot(T, Y(:, sys.CompositorIndex('B')), 'g'); % B in [g]reen
legend('A', 'B');
xlabel('Time');
ylabel('Concentration')
title('Enzymatic conversion of pulses of A to B')
