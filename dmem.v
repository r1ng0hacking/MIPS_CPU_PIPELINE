module dmem#(parameter M=32,N=6)(input clk,input we,input [M-1:0]addr,input [M-1:0] wd,output [M-1:0]rd);

	reg [M-1:0]ram[2**N-1:0];
	
	assign rd = ram[addr[M-1:2]];//world aligend
	
	initial
		$readmemh("F:/Code/MIPS_CPU/dmemfile.dat",ram);
	
	always @(posedge clk)begin
		if(we)begin
			ram[addr[M-1:2]] <= wd;
		end
	end

endmodule


module dmem_tb;

	parameter M=32,N=6;
	reg [M-1:0] addr;
	wire [M-1:0] rd;
	
	dmem #(M,N)DUT(.addr(addr),.rd(rd));
	
	initial begin
		addr = 0;#1;
		$display("%h",rd);
		
		addr = 4;#1;
		$display("%h",rd);
		
		addr = 8;#1;
		$display("%h",rd);
	end

endmodule