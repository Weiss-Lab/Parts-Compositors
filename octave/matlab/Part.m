%
% Part class
%

classdef Part

    properties
        name
        compositors
        rates
    end
    
    methods
        function P = Part(n, c, r)
            P.name        = n;
            P.compositors = c;
            P.rates       = r;
        end
    end

end