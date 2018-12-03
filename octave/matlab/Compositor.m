%
% Compositor class 
%
classdef Compositor < handle
    
    properties
        name
        v = 0;    % value (typically concentration)
        r = ['0'] % rate of change as computed by BioSystem before simulation
        
    end
    
    methods
        function C = Compositor(CompositorName, InitialValue)
            C.name  = CompositorName;
            C.v     = InitialValue;
        end
        
        %
        % AddRate
        %
        function self = AddRate(self, new_rate)
            % when adding the rate, replace each val(X) with self.val(X)
            new_rate_rep = regexprep(new_rate.s, 'val\((?<exp>\w+)\)', ...
                'self.compositors(self.map_compositors(''$<exp>'')).v');
            new_rate_rep = regexprep(new_rate_rep, 'const\((?<exp>\w+)\)', ...
                'self.constants(self.map_constants(''$<exp>'')).v');
            self.r = [self.r ' + (' new_rate_rep ')'];
        end
    end
    
end