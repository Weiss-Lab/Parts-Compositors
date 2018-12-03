%
% class BioSystem
%
classdef BioSystem < handle
    
    properties
        parts       = [];   % parts in this BioSystem
        compositors = [];   % compositors in this BioSystem
        constants   = [];   % constants defined in this BioSystem
        map_constants;      % a mapping between constant name and its value
        map_compositors;    % a mapping between compositor name and actual compositor
    end
    
    methods
        function B = BioSystem()
            % class constructor
            
            % initialize compositor, constant maps
            B.map_compositors = containers.Map;
            B.map_constants = containers.Map;
        end
        
        function self = AddCompositor(self, new_compositor)
            self.compositors = [self.compositors; new_compositor];
            self.map_compositors(new_compositor.name) = numel(self.compositors);
        end
        
        function self = AddPart(self, new_part)
            self.parts = [self.parts; new_part];
        end
        
        function self = AddConstant(self, new_constant)
            self.constants = [ self.constants; new_constant ];
            self.map_constants(new_constant.name) = numel(self.constants);
        end
        
        %
        % run simulation
        %
        function [T, Y] = run(self, tspan)
            % initial values
            y0 = [];
            for i = 1:length(self.compositors)
                y0 = [y0 self.compositors(i).v];
            end                    
            
            % determine rates for all compositors
            for i = 1:length(self.parts)
                p = self.parts(i);
                for k = 1:length(p.compositors)
                    p.compositors(k).AddRate(p.rates(k));
                end
            end
            
            % debug: print all compositor rates
            for j=1:length(self.compositors)
                %disp(self.compositors(j).r)
            end
            
            [T,Y] = ode23s(@self.sys_ode,tspan,y0);
            
        end
       
        %
        % ODE of system
        %
        function dy = sys_ode(self, t, y)
            dy = zeros(length(y), 1);
            % first, store new values in system compositors
            for i = 1:length(y)
                self.compositors(i).v = y(i);
            end
            
            % next, evaluate dy for each compositor
            for i = 1:length(y)
                dy(i) = eval(self.compositors(i).r);
            end            
        end
        
        % Run simulation with a given series of "inputs", i.e. run a
        % simulation where the amount of some species changes abruptly at
        % some point(s) in time.
        % The only argument the user provides is a matrix of the time
        % series of the input Pulses where each entry in the matrix is a
        % Pulse(time, compositor, amount), indicating that the
        % Compositor with name 'compositor' will be set to a level of
        % 'amount' at time 'time'. An empty string for the compositor name
        % is allowed -- use this to e.g. finish the simulation not after
        % changing the levels of the last compositor but after some set
        % time.
        function [T, Y] = run_pulses(self, pulse_series)
            num_pulses = numel(pulse_series);
            T = [];
            Y = [];
            
            prev_start = 0;
            
            for i = 1:num_pulses-1 % last pulse is not actually simulated
                pulse = pulse_series(i);
                % find appropriate compositor & set it's value
                if ~isempty(pulse.compositor_name)
                    self.compositors(self.map_compositors(pulse.compositor_name)).v = pulse.value;
                end
               
                % run simulation until the next pulse, i.e. from 0 for the
                % amount of time between this and the next pulse
                [ T_sim, Y_sim ] = self.run([ 0 pulse_series(i + 1).time - pulse.time ]);
                T = [ T; T_sim + prev_start ];
                Y = [ Y; Y_sim ];
                prev_start = pulse.time;
            end
        end
    end
end