%
% class BioSystem
%
classdef BioSystem < handle

    properties
        parts = []; % parts in this BioSystem
        compositors = []; % compositors in this BioSystem
        constants = []; % constants defined in this BioSystem
        symbols = ['t']; % list of all the Compositor symbols in ths BioSystem
        % by initializing symbols with t we allow t to be a variable that's not
        % a Compositor or Constant
        map_constants; % a mapping between constant name and its index
        map_compositors; % a mapping between compositor name and its index
        rates_determined = false % have we run determine_rates()?
    end

    methods
        function B = BioSystem()
            % class constructor

            % initialize compositor, constant maps
            B.map_compositors = containers.Map;
            B.map_constants = containers.Map;
        end

        % Add a compositor to this system
        % Returns the Compositor object that was added
        function new_compositor = AddCompositor(self, varargin)
            if nargin() == 2  % we were given a Compositor as the input
                new_compositor = varargin{1};
            elseif nargin() == 3  % we were given a name and an initial value
                new_compositor = Compositor(varargin{1}, varargin{2});
            else
                assert(false, 'Incorrect call to AddCompositor')
            end
            self.compositors = [self.compositors; new_compositor];
            self.map_compositors(new_compositor.name) = numel(self.compositors);
            self.symbols = [self.symbols; new_compositor.sym];
        end

        % Returns the index of a compositor in this system. This is index is
        % used in self.compositors, in the output data matrix of a simulation
        % etc
        function index = CompositorIndex(self, name)
            index = self.map_compositors(name);
        end

        % Add a part to the system
        % Returns the current BioSystem
        function self = AddPart(self, new_part)
            self.parts = [self.parts; new_part];
        end

        % Add a constant to the system
        % Returns the Const object that was added
        function new_constant = AddConstant(self, varargin)
            if nargin() == 2  % we were given a Const as the input
                new_constant = varargin{1};
            elseif nargin() == 3  % we were given a name and a value
                new_constant = Const(varargin{1}, varargin{2});
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
                    constant_syms = arrayfun(@(c){c.sym}, self.constants);
                    constant_vals = arrayfun(@(c){c.value}, self.constants);
                    symexpr = subs(str2sym(self.compositors(k).rate), ...
                                constant_syms, ...
                                constant_vals);
                    self.compositors(k).ratef = matlabFunction(...
                        symexpr, 'vars', self.symbols);
                end
                self.rates_determined = true;
                %disp('debug: determined rate functions');

                % debug: print all compositor rates
                %for j = 1:length(self.compositors)
                %    %disp(self.compositors(j).rate)
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
                self.compositors(i).rate = ['0'];
                self.compositors(i).ratef = [];
            end
        end

        %
        % Set a constant to a different value than it was originally defined as
        %
        function [] = ChangeConstantValue(self, name, value)
            self.constants(self.map_constants(name)).value = value;
            self.reset_rates() % calculated rates use the numerical value of
            % a constant for speed, so we must reset them
        end

        %
        % Set a state variables initial value
        %
        function [] = ChangeInitialValue(self, name, value)
            compositor = self.compositors(self.map_compositors(name));
            compositor.SetInitialValue(value);
            compositor.value = value;
        end

        %
        % Reset the state variables to the values set at initialization
        %
        function [] = reset_state_variables(self)
            for i = 1:length(self.compositors)
                self.compositors(i).value = self.compositors(i).init_value;
            end
        end

        %
        % Run simulation from tspan(1) to tspan(2).
        % If we are given an extra parameter, it is passed to ode23s
        % as the 'options' parameter (it should be the result of odeset()).
        % See http://www.mathworks.com/help/matlab/ref/ode23.html and
        % http://www.mathworks.com/help/matlab/ref/odeset.html
        %
        function [T, Y] = run(self, tspan, varargin)
            self.determine_rates() % safe to call multiple times

            % initial values
            y0 = zeros(length(self.compositors), 1);
            for i = 1:length(self.compositors)
                y0(i) = self.compositors(i).value;
            end
            %disp('debug: have set initial values');

            if isempty(varargin)
                [ T, Y ] = ode23s(@self.sys_ode, tspan, y0);
            else
                [ T, Y ] = ode23s(@self.sys_ode, tspan, y0, varargin{1});
            end
            % disp('debug: ran ode23s');
        end

        %
        % ODE of system
        %
        function dy = sys_ode(self, t, y)
            dy = zeros(length(y), 1);

            cellarray = num2cell(y); % hack to unpack the vector. optimize?
            for i = 1:length(self.compositors)
                dy(i) = self.compositors(i).ratef(t, cellarray{:});
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
                        self.map_compositors(pulse.compositor_name)).value = ...
                            pulse.value;
                end
               
                % run simulation until the next pulse, i.e. from 0 for the
                % amount of time between this and the next pulse
                sim_length = pulse_series(i + 1).time - pulse.time;
                [ T_sim, Y_sim ] = self.run(prev_end + [ 0 sim_length ]);

                T = [ T; T_sim(2:end) ];
                Y = [ Y; Y_sim(2:end, :) ];

                prev_start = pulse.time;
                prev_end = prev_start + sim_length;

                % set the values of compositors to be the end values
                % of this pulse
                for i = 1:length(self.compositors)
                    self.compositors(i).value = Y_sim(end, i);
                end
            end

            % restore initial values
            self.reset_state_variables();
        end
        
        %
        % Return the index in T that gives a value just before t (or
        % exactly t)
        %
        function [ ix ] = time_to_index(~, T, t)
            for i = 1:length(T)
                if T(i) >= t
                    break
                end
            end
            if T(i) == t
                ix = i;
            else
                ix = i - 1;
            end
        end
        
        %
        % Given two (x, y) traces, interpolate the less dense one to
        % have values for each x-value in the denser trace.
        % iX1, iY1 form one trace; iX2, iY2 another. The "denser" trace (more
        % datapoints) is used as the basis. Suppose the first is the denser
        % trace. Then for each value of iX1, we find a linear fit of the second
        % trace at that value using the two closest values of iX2.
        % iX1, iX2 are assumed to be ordered and to both start at the same
        % value. Assume iY1, iY2 are columns, iX1, iX2 are rows.
        function [ x1, y1, x2, y2 ] = interpolate_traces(~, iX1, iY1, iX2, iY2)
            if length(iX1) > length(iX2)
                X1 = iX1;
                Y1 = iY1;
                X2 = iX2;
                Y2 = iY2;
                swap = false;
            else
                X1 = iX2;
                Y1 = iY2;
                X2 = iX1;
                Y2 = iY1;
                swap = true;
            end
            interpolated = zeros(length(X1), 1);
            max_j = length(X2);
            j = 1;
            for i = 1:length(X1)
                x1 = X1(i);
                x_diff = abs(x1 - X2(j));
                % find the closest value in X2 to x1
                while abs(x1 - X2(j + 1)) < x_diff && j < max_j - 1
                    % sprintf('%g (abs(%g - %g)) < %g so j++', abs(x1 - X2(j + 1)), x1, X2(j + 1), x_diff)
                    x_diff = min(x_diff, abs(x1 - X2(j + 1)));
                    j = j + 1;
                end
                % sprintf('closest value to X1(%d) = %g is X2(%d) = %g', ...
                %         i, x1, j, X2(j))
                x2 = X2(j);
                % y = Ax + B
                % with two points (a, b) and (c, d), the line between them is given
                % with A = (b - d)/(a - c), B = b - A * a
                if x1 < x2 && j > 1
                    a = X2(j - 1);
                    b = Y2(j - 1);
                    c = X2(j);
                    d = Y2(j);
                else
                    a = X2(j);
                    b = Y2(j);
                    c = X2(j + 1);
                    d = Y2(j + 1);
                end
                if (a - c) == 0
                    A = 0;
                else
                    A = (b - d) / (a - c);
                end
                B = b - A * a;
                interpolated(i) = A * x1 + B;
                % sprintf('interpolated Y2(%d->%d) ~ %g', j, i, interpolated(i))
            end

            if swap
                x1 = X1;
                y1 = interpolated;
                x2 = X1;
                y2 = Y1;
            else
                x1 = X1;
                y1 = Y1;
                x2 = X1;
                y2 = interpolated;
            end
        end
    end
end
