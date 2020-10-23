module subtractor#(parameter N=8)(input[N-1:0] a,b,output[N-1:0] y);
	assign y = a - b;
endmodule

module subtractor_tb;
	parameter N=32;
	reg [N-1:0] a,b;
	wire [N-1:0] y;
	
	subtractor #(N)DUT(.a(a),.b(b),.y(y));
	
	initial
	begin
		a = 20;b=10;#10;	//y = 10
		a = 20;b=20;#10;	//y = 0
		a = 0 ;b=1 ;#10;	//y = -1
	end

endmodule