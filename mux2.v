module mux2#(parameter M=32)(input [M-1:0]d0,input [M-1:0]d1,input sel,output [M-1:0]y);

	assign y = sel ? d1:d0;

endmodule


module mux2_tb;

	parameter M=32;
	
	reg [M-1:0]d0,d1;
	reg sel;
	wire [M-1:0]y;
	
	mux2 #(M)DUT(.d0(d0),.d1(d1),.sel(sel),.y(y));
	
	initial
	begin
		d0 = 0;
		d1 = 1;#1;
		
		sel = 0;#1;
		$display("%d",y);#1;
		
		sel = 1;#1;
		$display("%d",y);#1;
	end

endmodule