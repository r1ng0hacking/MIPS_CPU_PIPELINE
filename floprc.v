module floprc#(parameter M=8)(input clk,input reset,input clear,
										input [M-1:0]d,output reg [M-1:0] q);
	always @(posedge clk,posedge reset)
	begin
		if(reset)		q <=  0;
		else if(clear) q <=  0;
		else 				q <=  d;
	end
endmodule

module floprc_tb;

	parameter M=8;
	reg clk,reset,clear;
	reg [M-1:0]d;
	wire [M-1:0]q;
	
	floprc #(M)DUT(.clk(clk),.reset(reset),.clear(clear),.d(d),.q(q));
	
	initial begin
		d = 0;
	end
	
	initial begin
		clk = 1;#1;
		clk = 0;#1;
	end
	
	initial
	begin
		d = 80;
		$display("d:%d q:%d",d,q);
	end

endmodule