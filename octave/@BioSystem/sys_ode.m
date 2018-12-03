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
