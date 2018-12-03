function Pu = Pulse(time, compositor_name, value)
	Pu.time = time;
	Pu.compositor_name = compositor_name;
	Pu.value = value;
	
	%Pu = class(Pu, "Pulse");
end
