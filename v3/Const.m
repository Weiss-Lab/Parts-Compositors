%
% Const class 
%
classdef Const < handle
    
    properties
        name
        s         % symbol object
        v = 0;    % value (typically some rate constant or K_d)
    end
    
    methods
        function Co = Const(ConstName, Value)
            assert(~strcmp(ConstName, 'gamma'), ...
                'Don''t name your constants gamma, it''s a reserved keyword');
            Co.name  = ConstName;
            Co.s     = sym(ConstName);
            Co.v     = Value;
        end
    end
    
end
