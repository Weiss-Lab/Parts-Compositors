function [inputs, outputs] = transfer_function(sys, ...
                                               input_compositor_name, ...
                                               output_compositor_name, ...
                                               min_input, max_input, ...
                                               varargin)
    % optional variables are:
    % - the number of datapoints to generate (default: 10)
    % - how long to run each simulation for (default: 1000 time units)
    numvarargs = length(varargin);
    if numvarargs > 2
       error('transfer_function got too many optional arguments') 
    end
    optargs = {10 1000};  % default parameters (datapoints, max_t)
    optargs(1:numvarargs) = varargin;
    [datapoints, max_t] = optargs{:};
    
    in_compositor_ix = sys.map_compositors(input_compositor_name);
    out_compositor_ix = sys.map_compositors(output_compositor_name);
    inputs = logspace(log10(min_input), log10(max_input), datapoints);
    outputs = 1:length(inputs);  % pre-allocate output vector
    for i = 1:length(inputs)
        sys.reset_state_variables();
        sys.compositors(in_compositor_ix).iv = inputs(i);
        [~, Y] = sys.run([ 0 max_t ]);
        outputs(i) = Y(end, out_compositor_ix);
    end
end