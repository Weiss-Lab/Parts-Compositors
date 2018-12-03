%% DO NOT EDIT THIS BLOCK
urlwrite('http://web.mit.edu/~20.305/www/part_composition_setup.m', ...
         'part_composition_setup.m');
rehash;
part_composition_setup('v2pre');
%% /DO NOT EDIT THIS BLOCK

% TODO: incomplete, check out the tristable_vectorfield_plots.py file
% instead

tristable_sys = BioSystem();

% define constants
tristable_sys.AddConstant(Const('k_txn', 1)); % transcription
tristable_sys.AddConstant(Const('k_tln', 1)); % translation
tristable_sys.AddConstant(Const('k_mdeg', 0.1)); % mRNA degradation &amp; dilution
tristable_sys.AddConstant(Const('k_pdeg', 0.01)); % protein degradation &amp; dilution
tristable_sys.AddConstant(Const('K_a', 1)); % dissociation contant for activation
tristable_sys.AddConstant(Const('K_r', 1)); % ... for repression
tristable_sys.AddConstant(Const('n_a', 2)); % Hill coefficient for activation
tristable_sys.AddConstant(Const('n_r', 2)); % ... for repression

% define compositors: these are the species in the system
% the second parameter is the initial concentration
% add compositors to the BioSystem object
A = tristable_sys.AddCompositor('A', 10);
B = tristable_sys.AddCompositor('B', 11);

% define and add parts
% parts are reactions that contribute to the d/dt of any compositor

tristable_sys.AddPart(Part('Expression of A', ...
            [ A ], ...
            [ Rate('k_tln * (k_txn / k_mdeg) * (A^n_a / (A^n_a + K_a^n_a)) * (K_r^n_r / (B^n_r + K_r^n_r))- k_pdeg * A') ]));

tristable_sys.AddPart(Part('Expression of B', ...
            [ B ], ...
            [ Rate('k_tln * (k_txn / k_mdeg) * (B^n_a / (B^n_a + K_a^n_a)) * (K_r^n_r / (A^n_r + K_r^n_r))- k_pdeg * B') ]));

% solve the system:
[T, Y] = tristable_sys.run([ 0 1000 ]);

% plot:
plot(T, Y(:, 1), T, Y(:, 2));
xlabel('Time (s)');
ylabel('Concentration (nM)');