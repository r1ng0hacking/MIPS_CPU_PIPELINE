module flopenrc#(parameter M=8)(input clk,input reset,input clear,input en,
										input [M-1:0]d,output reg [M-1:0] q);
	always @(posedge clk,posedge reset)begin
		if(reset) 		q <= 0;
		else if(clear) q <= 0;
		else if(en) 	q <= d;
	end
endmodule

module flopenrc_tb;

	parameter M=8;
	reg clk,reset,clear,en;
	reg [M-1:0]d;
	wire [M-1:0]q;
	
	flopenrc #(M)DUT(.clk(clk),.reset(reset),.clear(clear),.en(en),.d(d),.q(q));
	
	initial begin
		en = 0;
		d = 10;
		clk = 1;#1;
		clk = 0;#1;
		$display("%d",q);
		
		en = 1;
		d = 20;
		clk = 1;#1;
		clk = 0;#1;
		$display("%d",q);
	end

endmodule