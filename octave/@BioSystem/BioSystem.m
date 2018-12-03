function B = BioSystem()
	B.map_compositors = struct();
	B.map_constants = struct();
	B.parts = [];
	B.compositors = [];
	B.constants = [];
	
	B = class(B, "BioSystem");
end
