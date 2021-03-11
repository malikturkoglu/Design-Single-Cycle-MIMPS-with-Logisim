module alucont(aluopBlez,aluopandi,aluop1,aluop0,f5,f4,f3,f2,f1,f0,gout,goutJmor,goutJalr);//Figure 4.12 
input aluopBlez,aluopandi,aluop1,aluop0,f5,f4,f3,f2,f1,f0;
output [2:0] gout;
output goutJmor;
output goutJalr;
reg [2:0] gout;
reg goutJmor;
reg goutJalr;
always @(aluopBlez or aluopandi or aluop1 or aluop0 or f5 or f4 or f3 or f2 or f1 or f0)
begin
if(~(aluop1|aluop0))  gout=3'b010;
if(1)  goutJmor=1'b0;
if(1)  goutJalr=1'b0;
if(aluop0)gout=3'b110;
if(aluopandi)gout=3'b000; // eğer aluop2=1 ise andi demek ve aluya 000 sinyalini gönderirim
if(aluopBlez)gout=3'b011;
if(aluop1)//R-type
begin
	if (f5&~(f4)&~(f3)&~(f2)&~(f1)&~(f0))gout=3'b010; 	//function code=0000,ALU control=010 (add)
	if (f5&~(f4)&f3&~(f2)&f1&~(f0))gout=3'b111;	//function code=1x1x,ALU control=111 (set on less than)
	if (f5&~(f4)&~(f3)&~(f2)&f1&~(f0))gout=3'b110;	//function code=0x10,ALU control=110 (sub)
	if (~f5&(f4)&~(f3)&(f2)&f1&(f0))gout=3'b001;	//function code=x1x1,ALU control=001 (or)
	if (f5&~(f4)&~(f3)&f2&~(f1)&f0)gout=3'b001;	//jmor output = or ile aynı -- 100101
	if (f5&~(f4)&~(f3)&f2&~(f1)&f0)goutJmor=1'b1;
	if (~(f5)&~(f4)&f3&~(f2)&~(f1)&f0)goutJalr=1'b1;	//jalr output 001001 ---
	if (f5&~(f4)&~(f3)&f2&~(f1)&~(f0))gout=3'b000;	//function code=x1x0,ALU control=000 (and)
	if (~(f5)&~(f4)&~(f3)&~(f2)&f1&~(f0))gout=3'b100;	//funciton code 000010 (srl)
	
end
end
endmodule
