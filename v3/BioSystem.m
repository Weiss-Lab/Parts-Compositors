%
% class BioSystem
%
classdef BioSystem < handle
    
    properties
        parts       = []; % parts in this BioSystem
        compositors = []; % compositors in this BioSystem
        constants   = []; % constants defined in this BioSystem
        symbols     = []; % list of all the Compositor symbols in ths BioSystem
        map_constants;    % a mapping between constant name and its index
        map_compositors;  % a mapping between compositor name and its index
        rates_determined = false % have we run determine_rates()?
    end
    
    methods
        function B = BioSystem()
            % class constructor
            
            % initialize compositor, constant maps
            B.map_compositors = containers.Map;
            B.map_constants = containers.Map;
        end
        
        function ret = AddCompositor(self, varargin)
            if nargin() == 2  % we were given a Compositor as the input
                new_compositor = varargin{1};
                ret = self;
                % ^ backwards compatibility and we already have this handle
            elseif nargin() == 3  % we were given a name and an initial value
                new_compositor = Compositor(varargin{1}, varargin{2});
                ret = new_compositor;
            else
                assert(false, 'Incorrect call to AddCompositor')
            end
            self.compositors = [self.compositors; new_compositor];
            self.map_compositors(new_compositor.name) = numel(self.compositors);
            self.symbols = [self.symbols; new_compositor.s];
        end
        
        function self = AddPart(self, new_part)
            self.parts = [self.parts; new_part];
        end
        
        function self = AddConstant(self, varargin)
            if nargin() == 2  % we were given a Const as the input
                new_constant = varargin{1};
                ret = self;
                % ^ backwards compatibility and we already have this handle
            elseif nargin() == 3  % we were given a name and a value
                new_constant = Const(varargin{1}, varargin{2});
                ret = new_constant;
            else
                assert(false, 'Incorrect call to AddConstant')
            end
            self.constants = [ self.constants; new_constant ];
            self.map_constants(new_constant.name) = numel(self.constants);
        end

        %
        % determine rates of all compositors unless we've already done it
        %
        function [] = determine_rates(self)
            if ~self.rates_determined
                % determine rates for all compositors
                for i = 1:length(self.parts)
                    p = self.parts(i);
                    for k = 1:length(p.compositors)
                        p.compositors(k).AddRate(p.rates(k));
                    end
                end
                % find the symbolic rate functions
                for k = 1:length(self.compositors)
                    % find the symbolic expression and substitute constants for
                    % their values
                    constant_syms = arrayfun(@(c){c.s}, self.constants);
                    constant_vals = arrayfun(@(c){c.v}, self.constants);
                    symexpr = subs(sym(self.compositors(k).r), ...
                                constant_syms, ...
                                constant_vals);
                    self.compositors(k).ratef = matlabFunction(...
                        symexpr, 'vars', self.symbols);
                end
                self.rates_determined = true;
                %disp('debug: determined rate functions');
                            
                % debug: print all compositor rates
                %for j = 1:length(self.compositors)
                %    %disp(self.compositors(j).r)
                %end
            end
        end
        
        %
        % reset rates of compositors to be empty such that a call to
        % .determine_rates() can recalculate them. useful for e.g. if you want
        % to change the value of a constant after defining it.
        %
        function [] = reset_rates(self)
            self.rates_determined = false;
            for i = 1:length(self.compositors)
                self.compositors(i).r = ['0'];
                self.compositors(i).ratef = [];
            end
        end
        
        %
        % Set a constant to a different value than it was originally defined as
        %
        function [] = ChangeConstant(self, name, value)
            self.constants(self.map_constants(name)).v = value;
            self.reset_rates() % calculated rates use the numerical value of
            % a constant for speed, so we must reset them
        end
        
        %
        % Set a state variables initial value
        %
        function [] = ChangeInitialValue(self, name, value)
            self.compositors(self.map_compositors(name)).iv = value;
        end
        
        %
        % Reset the state variables to the values set at initialization
        %
        function [] = reset_state_variables(self)
            for i = 1:length(self.compositors)
                self.compositors(i).iv = self.compositors(i).orig_iv;
            end
        end
        
        %
        % run simulation
        %
        function [T, Y] = run(self, tspan)
            self.determine_rates() % safe to call multiple times
            
            % initial values
            y0 = zeros(length(self.compositors), 1);
            for i = 1:length(self.compositors)
                y0(i) = self.compositors(i).iv;
            end
            %disp('debug: have set initial values');
            
            [ T, Y ] = ode23s(@self.sys_ode, tspan, y0);
            %disp('debug: ran ode23s');
        end
       
        %
        % ODE of system
        %
        function dy = sys_ode(self, t, y)
            dy = zeros(length(y), 1);

            cellarray = num2cell(y); % hack to unpack the vector. optimize?
            for i = 1:length(self.compositors)
                dy(i) = self.compositors(i).ratef(cellarray{:});
            end
        end
        
        % Run simulation with a given series of "inputs", i.e. run a
        % simulation where the amount of some species changes abruptly at
        % some point(s) in time.
        % The only argument the user provides is a matrix of the time
        % series of the input Pulses where each entry in the matrix is a
        % Pulse(time, compositor_name, amount), indicating that the
        % Compositor with name 'compositor' will be set to a level of
        % 'amount' at time 'time'. An empty string for the compositor name
        % is allowed -- use this to e.g. finish the simulation after some set
        % time instead of after changing the levels of the last compositor.
        % This 'last pulse' is not technically simulated
        % The 'first pulse' should start at time 0
        % Example:
        % [T, Y] = sys_activator.run_pulses([...
        %   Pulse(0, 'Act', 0), ...
        %   Pulse(50, 'Act', 10), ...
        %   Pulse(200, 'Act', 0), ...
        %   Pulse(400, 'Act', 10), ...
        %   Pulse(600, '', 0) ]);
        % Here the system has Act at 0 for t = 0..50,
        % then Act shoots up to 10 for t = 50 .. 200, is set to 0 for
        % t = 200 .. 400, set to 10 again for t = 400 .. 600. The simulation
        % ends at t = 600
        function [T, Y] = run_pulses(self, pulse_series)
            num_pulses = numel(pulse_series);
            T = [];
            Y = [];
            
            prev_start = 0;
            prev_end = 0;
            
            for i = 1:num_pulses - 1 % last pulse is not actually simulated
                pulse = pulse_series(i);

                % find appropriate compositor & set its initial value
                if ~isempty(pulse.compositor_name)
                    self.compositors(...
                        self.map_compositors(pulse.compositor_name)).iv = ...
                            pulse.value;
                end
               
                % run simulation until the next pulse, i.e. from 0 for the
                % amount of time between this and the next pulse
                sim_length = pulse_series(i + 1).time - pulse.time;
                [ T_sim, Y_sim ] = self.run([ 0 sim_length ]);

                T = [ T; T_sim + prev_end ];
                Y = [ Y; Y_sim ];

                prev_start = pulse.time;
                prev_end = prev_start + sim_length;

                % set the initial values of compositors to be the end values
                % of this pulse
                for i = 1:length(self.compositors)
                    self.compositors(i).iv = Y_sim(end, i);
                end
            end

            % restore initial values
            self.reset_state_variables();
        end
    end
end
