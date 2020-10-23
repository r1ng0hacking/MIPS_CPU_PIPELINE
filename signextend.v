module signextend#(parameter N=16,M=32)(input [N-1:0]a,output [M-1:0]y);
	assign y = {{(M-N){a[N-1]}},a};
endmodule

module signextend_tb;
	parameter N=16,M=32;
	reg [N-1:0]a;
	wire [M-1:0]y;
	
	signextend #(N,M)DUT(.a(a),.y(y));
	
	initial
	begin
		a = 10;#1;
		$display("a = 10,y = %d",y);#1;
		
		a = 20;#1;
		$display("a = 20,y = %d",y);#1;
		
		a = 32768;#1;
		$display("a = 32768,y = %d",y);#1;
	end
endmodule