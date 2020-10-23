module counter#(parameter N = 8)(input clk,input reset,output reg[N-1:0] q);
	always @(posedge clk)
	begin
		if(reset)
			q<=0;
		else
			q<=q+1;
	end
endmodule

module counter_tb;

	parameter N = 32;
	reg clk;
	reg reset;
	wire [N-1:0] q;
	
	always
	begin
	clk = 1;#1;
	clk = 0;#1;
	end
	
	counter #(N)DUT(.clk(clk),.reset(reset),.q(q));
	
	initial
	begin
	reset = 1; #5;reset = 0;
	#50 reset = 1;#5;reset = 0;
	end
	
	always @(posedge clk)
	begin
		$display("q:%d,reset:%d",q,reset);
	end
	
endmodule