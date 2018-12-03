function C = Compositor(name, initial_value)
	C.name = name;
	C.value = initial_value;
	C.r = [ '0' ];
	
	%C = class(C, "Compositor");
end
