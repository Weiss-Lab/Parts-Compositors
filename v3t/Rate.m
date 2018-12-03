%
% Rate class
%

classdef Rate < handle

    properties
        string  % actual rate stored as a string
    end
    
    methods
        function R = Rate(rate_string)
            R.string = rate_string;
        end
    end
end
