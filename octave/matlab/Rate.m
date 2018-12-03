%
% Rate class
%

classdef Rate < handle

    properties
        s  % actual rate stored as a string
    end
    
    methods
        function R = Rate(rate_string)
            R.s = rate_string;
        end
    end
end