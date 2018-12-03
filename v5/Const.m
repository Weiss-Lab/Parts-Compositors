%
% Const class. A Const is some constant in a system.
%
classdef Const < handle
    
    properties
        name
        sym % symbol object
        value = 0; % value (typically some rate constant or K_d)
    end
    
    methods
        function const = Const(name, value)
            assert(~strcmp(name, 'gamma'), ...
                'Don''t name your constants gamma, it''s a reserved keyword');
            const.name = name;
            const.sym = sym(name);
            const.value = value;
        end
    end
    
end
