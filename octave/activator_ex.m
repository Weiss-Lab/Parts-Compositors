% activation example:
% Activator + DNA -k_f-> Activator:DNA
% Activator:DNA -k_r-> Activator + DNA
% Activator:DNA -k_txn-> Activator:DNA + mRNA
% mRNA -k_tln-> mRNA + protein
% mRNA -delta->
% protein -gamma->
%
% what are we assuming about the activator?
%source("biosystem.m");
%source("helpers.m");
%source("@BioSystem/biosystem.m")
sys_activator = BioSystem();

% define useful constants
AddConstant(sys_activator, Const('k_txn', 1));
AddConstant(sys_activator, Const('k_tln', 1));
AddConstant(sys_activator, Const('delta', 0.1)); % mRNA degradation / dilution
AddConstant(sys_activator, Const('gamma', 0.01)); % protein degradation / dilution
AddConstant(sys_activator, Const('k_f', 100)); % rate of Activator binding to DNA
AddConstant(sys_activator, Const('k_r', 0.01)); % rate of Activator unbinding from DNA

% compositors are species in your system!
Activator = Compositor('Act', 10);
ActivatorDNA = Compositor('ActDNA', 0);
DNA = Compositor('DNA', 10);
mRNA = Compositor('mRNA', 0);
protein = Compositor('P', 0);


AddCompositor(sys_activator, Activator);
AddCompositor(sys_activator, ActivatorDNA);
AddCompositor(sys_activator, DNA);
AddCompositor(sys_activator, mRNA);
AddCompositor(sys_activator, protein);

% parts are reactions that contribute to the d/dt of any compositor
Pf = ...
    Part('activator binding', ...
            [ Activator DNA ActivatorDNA ], ...
            [ Rate('-val(Act) * val(DNA) * const(k_f)'), ...
            Rate('-val(Act) * val(DNA) * const(k_f)'), ...
            Rate('val(Act) * val(DNA) * const(k_f)')]);
AddPart(sys_activator, Pf);
Pr = ...
    Part('activator unbinding', ...
            [ Activator DNA ActivatorDNA ], ...
            [ Rate('val(ActDNA) * const(k_r)'), ...
            Rate('val(ActDNA) * const(k_r)'), ...
            Rate('-val(ActDNA) * const(k_r)')]);
AddPart(sys_activator, Pr);
P1 = ...
	Part('transcription', ...
			[DNA mRNA], ...
			[Rate('0'), ...
			Rate('val(ActDNA) * const(k_txn)')]);
AddPart(sys_activator, P1);
P2 = ...
	Part('translation', ...
			[mRNA protein], ...
			[Rate('0'), ...
            % val(mRNA) = k_txn / delta * val(DNA)
			Rate('val(mRNA) * const(k_tln)')]);
AddPart(sys_activator, P2);
P3 = ...
	Part('mRNA degradation', ...
			[mRNA], ...
			[Rate('-val(mRNA) * const(delta)')]);
AddPart(sys_activator, P3);
P4 = ...
	Part('Protein degradation', ...
			[protein], ...
			[Rate('-val(P) * const(gamma)')]);
AddPart(sys_activator, P4);


% solve the system:
[T, Y] = simulate_biosystem(sys_activator, [ 0 1000 ])
print_system(sys_activator)
% plot:
%num_compositors = size(Y,2);
%for i=1:num_compositors
%	subplot(num_compositors, 1, i);
%	plot(T, Y(:,i));
%	xlabel('Time');
%	ylabel(strcat('[', sys_activator.compositors(i).name, ']'), 'Rotation', 0);
%end
