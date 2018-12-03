function self = AddCompositor(self, new_compositor)
	self.compositors = [ self.compositors; new_compositor ];
	self.map_compositors.(new_compositor.name) = numel(self.compositors);
end
