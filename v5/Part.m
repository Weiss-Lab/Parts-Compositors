%
% Part class. A part is a process, changing the values of compositors according
% to some rate laws.
%

classdef Part

    properties
        name
        compositors % a vector of Compositors
        rates % a vector of Rates, showing the rate law for each Compositor
    end

    methods
        function part = Part(name, compositors, rates)
            part.name = name;
            part.compositors = compositors;
            part.rates = rates;
        end
    end

end
