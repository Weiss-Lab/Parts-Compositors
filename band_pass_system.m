%% DO NOT EDIT THIS BLOCK
urlwrite('http://web.mit.edu/20.305/www/part_composition_setup.m', ...
         'part_composition_setup.m');
rehash;
part_composition_setup('v3');
%% /DO NOT EDIT THIS BLOCK

% this system has a hybrid promoter controlled by an activator and a
% repressor

sys_hybrid_bandpass = BioSystem();

% define constants

sys_hybrid_bandpass.AddConstant(Const('k_txn', 1));
sys_hybrid_bandpass.AddConstant(Const('k_tln', 1));
sys_hybrid_bandpass.AddConstant(Const('k_mdeg', 0.1));
sys_hybrid_bandpass.AddConstant(Const('k_pdeg', 0.01));
sys_hybrid_bandpass.AddConstant(Const('K_a', 10));
sys_hybrid_bandpass.AddConstant(Const('n_a', 10));
sys_hybrid_bandpass.AddConstant(Const('K_r', 20));
sys_hybrid_bandpass.AddConstant(Const('n_r', 10));


activator_repressor = sys_hybrid_bandpass.AddCompositor('A', 0);
%repressor = sys_hybrid_bandpass.AddCompositor('R', 1);
output = sys_hybrid_bandpass.AddCompositor('out', 500);
%inducer = sys_hybrid_bandpass.AddCompositor('Ind', 0);

%sys_hybrid_bandpass.AddPart(Part('A induction / production / degradation', ...
%    [ activator_repressor inducer ], ...
%    [ Rate('k_tln * (k_txn / k_mdeg) * (Ind^2 / (Ind^2 + 10^2)) - k_pdeg * A'), ...
%      Rate('0') ]));

sys_hybrid_bandpass.AddPart(Part('A bandpass component', ...
    [ activator_repressor output ], ...
    [ Rate('0'), ...
      %Rate('0'), ...
      Rate('k_tln * (k_txn / k_mdeg) * ( A^n_a / (A^n_a + K_a^n_a)) * ( K_r^n_r / (A^n_r + K_r^n_r)) - k_pdeg * out')
    ]));

%% run pulse row
num_pulses = 9;
pulses = repmat(Pulse(0, 'A', 0), 1, num_pulses);
start_time = 0;
end_time = 1;
tau = 0.1
for i = 0:num_pulses
    %start_time
    %end_time
    p = Pulse(start_time * tau, 'A', 15)
    pulses(2 * i + 1) = p;
    p = Pulse(end_time * tau, 'A', 0)
    pulses(2 * i + 2) = p;
    start_time = end_time + 2^i;
    end_time = start_time + 2^(i + 1);
end

%% run pulse of particular period
K_a = 10;
K_r = 20;
n = 10;

sys_hybrid_bandpass.ChangeConstant('K_a', K_a);
sys_hybrid_bandpass.ChangeConstant('K_r', K_r);
sys_hybrid_bandpass.ChangeConstant('n_a', n);
sys_hybrid_bandpass.ChangeConstant('n_r', n);

num_pulses = 300;
period = 10;
pulses = repmat(Pulse(0, 'A', 0), 1, num_pulses);
start_time = 0;
end_time = period;
for i = 0:num_pulses
    p = Pulse(start_time, 'A', 30)
    pulses(2 * i + 1) = p;
    p = Pulse(end_time, 'A', 0);
    pulses(2 * i + 2) = p;
    start_time = end_time + period;
    end_time = start_time + period;
end

%%
sys_hybrid_bandpass.reset_state_variables();
[T, Y] = sys_hybrid_bandpass.run_pulses(pulses)

hold all;
plot(T, Y(:, 1))
plot(T, Y(:, 2))
plot(T, Y(:, 3))
legend('A', 'output')

%% plot particular K_a, K_r, n
K_a = 10;
K_r = 20;
n = 30;
datapoints = 100;
min_input = 1;
max_input = 100;
sys_hybrid_bandpass.ChangeConstant('K_a', K_a);
sys_hybrid_bandpass.ChangeConstant('K_r', K_r);
sys_hybrid_bandpass.ChangeConstant('n_a', n);
sys_hybrid_bandpass.ChangeConstant('n_r', n);
[inputs, outputs] = transfer_function(sys_hybrid_bandpass, 'A', 'out', min_input, max_input, datapoints);
semilogx(inputs, outputs);
hold all;

%% show what happens when you change K_a, K_r
min_input = 1;
max_input = 10000;
datapoints = 75;
sys_hybrid_bandpass.ChangeConstant('K_r', 100);
for K_a = [5 50 100 200]
    sys_hybrid_bandpass.ChangeConstant('K_a', K_a);
    [inputs, outputs] = transfer_function(sys_hybrid_bandpass, 'A', 'out', min_input, max_input, datapoints);
    semilogx(inputs, outputs);
    hold all;
end
sys_hybrid_bandpass.ChangeConstant('K_a', 100);
for K_r = [5 50 100 200]
    sys_hybrid_bandpass.ChangeConstant('K_r', K_r);
    [inputs, outputs] = transfer_function(sys_hybrid_bandpass, 'A', 'out', min_input, max_input, datapoints);
    semilogx(inputs, outputs);
    hold all;
end

legend('a 5', 'a 50', 'a 100', 'a 200', 'r 5', 'r 50', 'r 100', 'r 200')

% solve the system:
%[T, Y] = sys_hybrid_bandpass.run([ 0 1000 ]);

% plot:
%hold all;
%plot(T, Y(:,1));
%plot(T, Y(:,2));
%plot(T, Y(:,3));
%legend('A', 'R', 'out');
%xlabel('Time (s)');
%ylabel('Concentration (nM)');