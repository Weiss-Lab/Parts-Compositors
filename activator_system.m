%% DO NOT EDIT THIS BLOCK
urlwrite('http://keku.mit.edu/posb/part_composition_setup.m', ...
         'part_composition_setup.m');
rehash;
part_composition_setup('v2pre');
%% /DO NOT EDIT THIS BLOCK

% The reactions in thisa system are:
% n * activator + DNA -k_f-> n-activator:DNA
% n-activator:DNA -k_r-> n * activator + DNA
% n-activator:DNA -k_txn-> n-activator:DNA + mRNA
% mRNA -k_tln-> mRNA + P
% mRNA -delta->
% P -gamma->

% define a BioSystem: this object will hold the parts and compositors

sys_activator = BioSystem();

% define constants

sys_activator.AddConstant(Const('k_txn', 1));
sys_activator.AddConstant(Const('k_tln', 1));
sys_activator.AddConstant(Const('delta', 0.1)); % mRNA degradation &amp; dilution
sys_activator.AddConstant(Const('gmma', 0.01)); % P degradation &amp; dilution
% note: we can't use gamma as a constant name in MATLAB
sys_activator.AddConstant(Const('k_f', 1)); % rate of activator binding DNA
sys_activator.AddConstant(Const('k_r', 0.1)); % rate of activator unbinding DNA
sys_activator.AddConstant(Const('n', 2)); % how many activator molecules come together

% define compositors: these are the species in the system
% the second parameter is the initial concentration

activator = Compositor('Act', 10);
nactivatorDNA = Compositor('nActDNA', 0);
DNA = Compositor('DNA', 1);
mRNA = Compositor('mRNA', 0);
P = Compositor('P', 0);

% add compositors to the BioSystem object

sys_activator.AddCompositor(activator);
sys_activator.AddCompositor(nactivatorDNA);
sys_activator.AddCompositor(DNA);
sys_activator.AddCompositor(mRNA);
sys_activator.AddCompositor(P);

% define and add parts
% parts are reactions that contribute to the d/dt of any compositor

Pf = ...
    Part('Activator binding', ...
            [ activator DNA nactivatorDNA ], ...
            [ Rate('-n * Act^n * DNA * k_f'), ...
              Rate('-Act^n * DNA * k_f'), ...
              Rate(' Act^n * DNA * k_f') ]);
sys_activator.AddPart(Pf);

Pr = ...
    Part('Activator unbinding', ...
            [ activator DNA nactivatorDNA ], ...
            [ Rate(' n * nActDNA * k_r'), ...
              Rate(' nActDNA * k_r'), ...
              Rate('-nActDNA * k_r') ]);
sys_activator.AddPart(Pr);

P1 = ...
  Part('Transcription', ...
      [ DNA mRNA ], ...
      [ Rate('0'), ...
        Rate('nActDNA * k_txn') ]);
sys_activator.AddPart(P1);

P2 = ...
  Part('Translation', ...
       [ mRNA P ], ...
       [ Rate('0'), ...
         Rate('mRNA * k_tln') ]);
sys_activator.AddPart(P2);

P3 = ...
  Part('mRNA degradation', ...
       [ mRNA ], ...
       [ Rate('-mRNA * delta') ]);
sys_activator.AddPart(P3);

P4 = ...
  Part('P degradation', ...
       [ P ], ...
       [ Rate('-P * gmma') ]);
sys_activator.AddPart(P4);


% solve the system:
[T, Y] = sys_activator.run([ 0 1000 ]);

% plot:
plot(T, Y(:, 5)); % P was the fifth compositor we added
xlabel('Time (s)');
ylabel('[P] (nM)');

% plot all compositors, useful for debugging:
% num_compositors = size(Y, 2);
% for i = 1:num_compositors
%  subplot(num_compositors, 1, i);
%  plot(T, Y(:, i));
%  xlabel('Time');
%  ylabel(sprintf('[%s]', sys_activator.compositors(i).name), 'Rotation', 0);
% end