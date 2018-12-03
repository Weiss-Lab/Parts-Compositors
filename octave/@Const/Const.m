function Co = Const(name, value)
	Co.name = name;
	Co.value = value;
	
	%Co = class(Co, "Const");
end
