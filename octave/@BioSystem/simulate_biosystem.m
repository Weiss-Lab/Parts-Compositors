function [T, Y] = simulate_biosystem(self, tspan)
	% debug: print all compositor rates
	disp(self.compositors)
	for j = 1:length(self.compositors)
		disp(self.compositors(j).r)
		self.compositors(j).r
	end

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
	
	[T, Y] = lsode(@(t, y) sys_ode(self, t, y), tspan, y0); # ode23s
end
