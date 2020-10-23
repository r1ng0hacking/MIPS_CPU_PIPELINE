module shiftreg#(parameter N = 8)(input clk,input reset,input sin,input[N-1:0] d,input load,output sout,output reg [N-1:0]q);
	always @(posedge clk,posedge reset)
	begin
		if(reset) begin
			q<=0;
		end
		else if (load) begin
			q<=d;
		end
		else begin
			q <= {q[N-2:0],sin};
		end
	end
	assign sout = q[N-1];
endmodule

module shiftreg_tb;

	parameter N = 32;
	reg clk,reset,sin,load;
	reg [N-1:0]d;
	wire sout;
	wire [N-1:0]q;
	
	always
	begin
		clk = 1;#5;
		clk = 0;#5;
	end
	
	shiftreg #(N)DUT(.clk(clk),.reset(reset),.sin(sin),.d(d),.load(load),.sout(sout),.q(q));
	
	initial
	begin
		reset = 1;#5;reset = 0;#5;
	end
	
	initial
	
	begin
		#10;sin = 1;
		#10;sin = 0;
		#10;sin = 1;
		#10;sin = 1;
		#10;d=1111;load = 1;#5;load = 0;
	end
	
endmodule