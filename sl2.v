module sl2#(parameter M = 32)(input [M-1:0]a,output [M-1:0]y);//shift left 2
	assign y = {a[M-3:0],2'b00};
endmodule


module sl2_tb;

	parameter M=32;
	reg [M-1:0]a;
	wire [M-1:0]y;
	
	sl2 #(M)DUT(.a(a),.y(y));
	
	initial
	begin
		a = 4;#1;
		$display("%d",y);#1;
		
		a = 8;#1;
		$display("%d",y);#1;
		
		a = 32;#1;
		$display("%d",y);#1;
	end

endmodule