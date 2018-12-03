%
% Const class 
%
classdef Const < handle
    
    properties
        name
        v = 0;    % value (typically some rate constant or K_d)
    end
    
    methods
        function Co = Const(ConstName, Value)
            Co.name  = ConstName;
            Co.v     = Value;
        end
    end
    
end
