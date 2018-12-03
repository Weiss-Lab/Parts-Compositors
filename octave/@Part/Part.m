function P = Part(n, c, r)
	P.name			= n;
	P.compositors	= c;
	P.rates			= r;
	
	%P = class(P, "Part");
end
