%
% Pulse class 
%
classdef Pulse < handle
    
    properties
        time
        compositor_name
        value
    end
    
    methods
        function Pu = Pulse(time, compositor_name, value)
            Pu.time = time;
            Pu.compositor_name = compositor_name;
            Pu.value = value;
        end
    end
    
end
