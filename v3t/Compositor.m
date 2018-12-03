%
% Compositor class 
%
classdef Compositor < handle
    
    properties
        name
        s           % symbol object
        iv = 0      % initial value (concentration); could be changed
        orig_iv = 0 % initial value set at initialization; cannot be changed
        r = ['0']   % rate of change as computed by BioSystem before simulation
                    % this is just a string representing a symbolic expression
        ratef       % a symbolic function
        
    end
    
    methods
        function C = Compositor(CompositorName, InitialValue)
            C.name    = CompositorName;
            C.s       = sym(CompositorName);
            C.iv      = InitialValue;
            C.orig_iv = InitialValue;
        end
        
        %
        % AddRate
        %
        function self = AddRate(self, new_rate)
            self.r = [self.r ' + (' new_rate.string ')'];
        end
    end
    
end
