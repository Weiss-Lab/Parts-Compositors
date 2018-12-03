function self = AddRate(self, new_rate)
	new_rate_rep = regexprep(new_rate.s, 'val\((?<exp>\w+)\)', ...
		'self.compositors(self.map_compositors(''$<exp>'')).v');
	new_rate_rep = regexprep(new_rate_rep, 'const\((?<exp>\w+)\)', ...
		'self.constants(self.map_constants(''$<exp>'')).v');
	self.r = [self.r ' + (' new_rate_rep ')'];
end
