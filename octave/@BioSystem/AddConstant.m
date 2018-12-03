function self = AddConstant(self, new_constant)
	self.constants = [ self.constants; new_constant ];
	self.map_constants.(new_constant.name) = numel(self.constants);
end
