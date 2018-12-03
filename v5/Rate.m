%
% Rate class. A Rate is a string representation of a rate law involving
% compositors, constants, and potentially other functions (including of time).
%

classdef Rate < handle

    properties
        string % actual rate equation stored as a string
    end

    methods
        function rate = Rate(rate_string)
            rate.string = rate_string;
        end
    end
end
