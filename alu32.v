module alu32(shamt,sum,a,datab,b,zout,blezCon,gin,nout,aluopBaln);//ALU operation according to the ALU control line values
output [31:0] sum;
input aluopBaln;
input [31:0] a,b,datab;
input [4:0] shamt;
input [2:0] gin;//ALU control line
reg [31:0] sum;
reg [31:0] less;
output zout,blezCon,nout;
reg zout,blezCon,nout;
always @(a or b or gin)
begin
	case(gin)
	3'b010: sum=a+b; 		//ALU control line=010, ADD
	3'b110: sum=a+1+(~b);	//ALU control line=110, SUB
	3'b111: begin less=a+1+(~b);	//ALU control line=111, set on less than
			if (less[31]) sum=1;	
			else sum=0;
		  end
	3'b000: sum=a & b;	//ALU control line=000, AND
	3'b011: sum=a+b; //// 
			
	
	3'b001: sum=a|b;		//ALU control line=001, OR
	3'b100: sum=datab>>shamt; // ALU control line=100, SRL
	default: sum=31'bx;	
	endcase
zout=~(|sum);
if(~aluopBaln)nout=sum[31];
blezCon=a[31] || ~(|a);
end
endmodule
