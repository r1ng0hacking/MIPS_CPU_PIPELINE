module adder #(parameter N=8)(input [N-1:0]a,b,input cin,output [N-1:0]s,output cout);
	assign {cout,s} = a + b + cin;
endmodule


module adder_tb;
	parameter N =32;
	reg[N-1:0] a,b;
	reg cin;
	wire[N-1:0] s;
	wire cout;
	
	adder #(N)DUT(.a(a),.b(b),.cin(cin),.s(s),.cout(cout));

	initial
	begin
		a = 10;b=20;cin = 1;			//cout = 0;s = 31
		#10;
		a = 30;b=40;cin = 0;			//cout = 0;s = 70
		#10;
		a = 2147483648;b = 2147483648;cin = 0;//cout = 1,s = 0
		#10;
		a = 2147483648;b = 2147483648;cin = 1;//cout = 1,s = 1
	end
	
endmodule