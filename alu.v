module alu#(parameter M=32)(input [M-1:0]a,input [M-1:0]b,input [2:0]f,output reg [M-1:0]y,output reg overflow,output zero);
	wire [M-1:0] s,bout;
	
	assign bout = f[2] ? ~b : b;
	assign s = a + bout + f[2];
	assign zero = s==0;
	always @(*)begin
		case(f[1:0])
		2'b00:y = a & bout;
		2'b01:y = a | bout;
		2'b10:y = s;
		2'b11:y = s[M-1];
		endcase
	end
	
	always @(*)begin
		case(f[2])
		1'b0:overflow = a[M-1] & b[M-1] & ~s[M-1] | ~a[M-1] & ~b[M-1] & s[M-1];
		1'b1:overflow = ~a[M-1] & b[M-1] & s[M-1] | a[M-1] & ~b[M-1] & ~s[M-1];
		default:overflow = 1'b0;
		endcase
	end
endmodule

module alu_tb;

	parameter M=32;
	
	reg [M-1:0] a,b;
	reg [2:0] f;
	wire [M-1:0] y;
	wire overflow;
	
	alu #(M)DUT(.a(a),.b(b),.f(f),.y(y),.overflow(overflow));
	
	initial
	begin
		a = 1;b = 2;f = 3'b010;#1;//+
		$display("a+b = %d,overflow = %d",y,overflow);#1;
		
		a = 1;b = 2;f = 3'b110;#1;//-
		$display("a-b = %d,overflow = %d",y,overflow);#1;
		
		a = 1;b = 2;f = 3'b111;#1;//slt
		$display("a slt b = %d,overflow = %d",y,overflow);#1;
		
		a = 3;b = 2;f = 3'b111;#1;//slt
		$display("a slt b = %d,overflow = %d",y,overflow);#1;
		
		a = 2147483647;b = 2;f = 3'b010;#1;//+
		$display("a+b = %d,overflow = %d",y,overflow);#1;
	end

endmodule