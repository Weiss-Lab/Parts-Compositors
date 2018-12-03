%
% Pulse class. A Pulse tells says that at time $time we should set value of the
% compositor named $compositor_name to $value in our simulation.
%

classdef Pulse < handle

    properties
        time
        compositor_name
        value
    end

    methods
        function pulse = Pulse(time, compositor_name, value)
            pulse.time = time;
            pulse.compositor_name = compositor_name;
            pulse.value = value;
        end
    end

end
