%
% Compositor class. A Compositor is the total rate of change of a  state
% variable, e.g. the concentration of some chemical species, say dEnzyme/dt
%
classdef Compositor < handle

    properties
        name % the name of the state variable
        sym % symbol object for this compositor
        init_value = 0 % e.g. concentration, immutable except with SetInitialValue
        value = 0 % value, could change during a simulation, e.g. with run_pulses
        rate = ['0'] % rate of change as computed by BioSystem before
                     % simulation this is just a string representing a symbolic
                     % expression
        ratef % a symbolic function representing the rate function
        
    end

    methods
        function compositor = Compositor(name, init_value)
            compositor.name = name;
            compositor.sym = sym(name);
            compositor.init_value = init_value;
            compositor.value = init_value;
        end

        %
        % AddRate
        %
        function self = AddRate(self, new_rate)
            self.rate = [self.rate ' + (' new_rate.string ')'];
        end

        %
        % SetInitialValue
        %
        function self = SetInitialValue(self, init_value)
            self.init_value = init_value;
        end
    end

end
