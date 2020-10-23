module ram#(parameter N=6,M=32)(input clk,input we,input [N-1:0]addr,
										  input [M-1:0] din,output [M-1:0]dout);
										  
	reg [M-1:0]mem[2**N-1:0];
	
	always @(posedge clk)
	begin
		if(we)
			mem[addr] = din;
	end
	
	assign dout = mem[addr];
endmodule