module comparator#(parameter N = 8)(input[N-1:0] a,b,output eq,neq,lt,lte,gt,gte);
	assign eq = (a == b);
	assign neq = (a != b);
	assign lt = (a<b);
	assign lte = (a<=b);
	assign gt = (a > b);
	assign gte = ( a >= b);
endmodule


module comparator_tb;
	parameter N = 32;
	reg[N-1:0] a,b;
	wire eq,neq,lt,lte,gt,gte;
	
	comparator #(N)DUT(.a(a),.b(b),.eq(eq),.neq(neq),.lt(lt),.lte(lte),.gt(gt),.gte(gte));
	
	initial
	begin
		a = 1;b=1;#10;
		a = 2;b=1;#10;
		a = 1;b=3;#10;
	end
	
endmodule