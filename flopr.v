module flopr #(parameter M=32)(input clk,input reset,input [M-1:0]d,output reg [M-1:0]q);//resettable flip-flop
	always @(posedge clk,posedge reset)begin
		if(reset)begin
			q<=0;
		end
		else begin
			q<=d;
		end
	end
endmodule

module flopr_tb;

	parameter M=32;
	
	reg clk,reset;
	reg [M-1:0]d;
	wire [M-1:0]q;
	
	flopr #(M)DUT(.clk(clk),
					  .reset(reset),
					  .d(d),
					  .q(q));
					  
	initial begin
	clk = 0;#1;
	d = 10;#1;
	clk = 1;#1;
	$display("q = %d",q);#1;
	clk = 0;#1;
	
	reset = 0;#1;
	reset = 1;#1;
	$display("q = %d",q);#1;
	reset = 0;#1;
	end

endmodule