module processor;
reg [31:0] pc; //32-bit prograom counter
reg clk; //clock
reg [7:0] datmem[0:31],mem[0:31]; //32-size data and instruction memory (8 bit(1 byte) for each location)
wire [31:0] 
dataa,	//Read data 1 output of Register File
datab,	//Read data 2 output of Register File
out2,		//Output of mux with ALUSrc control-mult2
out3,		//Output of mux with MemToReg control-mult3
out4,		//Output of mux with (Branch&ALUZero) control-mult4
out5,		// output of mux write data
out6,		//output of mux pc or jalr
out7,		//output of mux pc or jmor ==>>(LAST wire for pc)

out9,
sum,		//ALU result
extad,	 //Output of sign-extend unit
adder1out,	//Output of adder which adds PC and 4-add1
adder2out,	//Output of adder which adds PC+4 and 2 shifted sign-extend result-add2
sextad;	//Output of shift left 2 unit

wire [5:0] inst31_26;	//31-26 bits of instruction
wire [4:0] 
inst25_21,	//25-21 bits of instruction
inst10_6,	//10-6 bits of instruction
inst20_16,	//20-16 bits of instruction
inst15_11,	//15-11 bits of instruction
out8,		//output for write data jmor register $31
out1;		//Write data input of Register File

wire [15:0] inst15_0;	//15-0 bits of instruction
wire [25:0] inst25_0;
wire [31:0] instruc,	//current instruction
dpack;	//Read data output of memory (data read from memory)
wire [31:0] newPcAfterBaln;
wire [2:0] gout;	//Output of ALU control unit
wire goutJalrS; // jalr mux signal
wire goutJmorS; // jmor mux signal

wire nout;
wire zout,	//Zero output of ALU

blezCon,
pcsrc,	//Output of AND gate with Branch and ZeroOut inputs
blezOrzout,
blezAndGate,
balnGate,
writeLink,
jmorSOrJalrS,
//Control signals
regdest,alusrc,memtoreg,regwrite,memread,memwrite,branch,aluop1,aluop0,aluopandi,aluopBlez,aluopBaln;

//32-size register file (32 bit(1 word) for each register)
reg [31:0] registerfile[0:31];
///STATUS REGİSTER
//reg statusRegister[0:3];

integer i;

// datamemory connections

always @(posedge clk)
//write data to memory
if (memwrite)
begin 
//sum stores address,datab stores the value to be written
datmem[sum[4:0]+3]=datab[7:0];
datmem[sum[4:0]+2]=datab[15:8];
datmem[sum[4:0]+1]=datab[23:16];
datmem[sum[4:0]]=datab[31:24];
end

//instruction memory
//4-byte instruction
 assign instruc={mem[pc[4:0]],mem[pc[4:0]+1],mem[pc[4:0]+2],mem[pc[4:0]+3]};
 assign inst31_26=instruc[31:26];
 assign inst25_21=instruc[25:21];
 assign inst20_16=instruc[20:16];
 assign inst15_11=instruc[15:11];
 assign inst15_0=instruc[15:0];
 assign inst10_6=instruc[10:6];
 assign inst25_0=instruc[25:0]; // for jump instruction

/*reg [1:0] statusNout;
assign statusNout=2'b01;*/


 wire [27:0] shift2Jump;
shift_26_to_28 shiftJumpto28(shift2Jump,inst25_0); // now jump label target is 28bit
assign newPcAfterBaln={adder1out[31:28],shift2Jump[27:0]}; // this is new pc value after baln operation
// registers

assign dataa=registerfile[inst25_21];//Read register 1
assign datab=registerfile[inst20_16];//Read register 2
always @(posedge clk)
 registerfile[out8]= regwrite ? out5:registerfile[out8];//Write data to register

 //statusRegister[0]=zout; //içine bit assign etmem lazım 2bit
 //statusRegister[statusNout]=regwrite ? nout:nout;
//read data from memory, sum stores address
assign dpack={datmem[sum[5:0]],datmem[sum[5:0]+1],datmem[sum[5:0]+2],datmem[sum[5:0]+3]};

//multiplexers
//mux with RegDst control
mult2_to_1_5  mult1(out1, instruc[20:16],instruc[15:11],regdest);

//mux with ALUSrc control
mult2_to_1_32 mult2(out2, datab,extad,alusrc);

//mux with MemToReg control
mult2_to_1_32 mult3(out3, sum,dpack,memtoreg);

//mux with (Branch&ALUZero) control
mult2_to_1_32 mult4(out4, adder1out,adder2out,pcsrc);

//this mux for baln output
mult2_to_1_32 mult9(out9,out4,newPcAfterBaln,balnGate);/////////////////////////////////////////////////////////////////////////////////////

//mux with (jmorSOrJalrS) control
mult2_to_1_32 mult5(out5,out3,adder1out,jmorSOrJalrS);

//mux with JalrSPC control -- branch muxtan sonraki mux for pc
mult2_to_1_32 mult6(out6,out9,dataa,goutJalrS);

//mux with JmorsPC control -- kırmızı mux en son bu sonra program countera gidiyor
mult2_to_1_32 mult7(out7,out6,dpack,goutJmorS);


///goutJmorS ve aluopBaln or gate ile bağla 
assign writeLink = goutJmorS || aluopBaln; 


wire [4:0] allOneReg;
assign allOneReg=5'b11111;

//BU MUX JMOR ICIN LINK ADDRESSI $31'e ATMAK İÇİN 
mult2_to_1_5 mult8(out8,out1,allOneReg,writeLink);


// load pc
always @(posedge clk)
pc=out7; // to prgram counter

// alu, adder and control logic connections

//ALU unit
alu32 alu1(instruc[10:6],sum,dataa,datab,out2,zout,blezCon,gout,nout,aluopBaln);

//adder which adds PC and 4
adder add1(pc,32'h4,adder1out);

//adder which adds PC+4 and 2 shifted sign-extend result
adder add2(adder1out,sextad,adder2out);

//Control unit
control cont(instruc[31:26],regdest,alusrc,memtoreg,regwrite,memread,memwrite,branch,
aluop1,aluop0,aluopandi,aluopBlez,aluopBaln);

//Sign extend unit
signext sext(instruc[15:0],extad);

//ALU control unit
alucont acont(aluopBlez,aluopandi,aluop1,aluop0,instruc[5],instruc[4],instruc[3],instruc[2], instruc[1], instruc[0] ,gout,goutJmorS,goutJalrS);

//Shift-left 2 unit
shift shift2(sextad,extad);

//AND gate
assign balnGate= nout && aluopBaln ; 


//AND gate
assign blezAndGate= aluopBlez && blezCon; 
//AND gate


assign blezOrzout= blezAndGate || zout; 
//Or gate for JalrS and JmorS

assign pcsrc=branch && blezOrzout; 
//Or gate for JalrS and JmorS

assign jmorSOrJalrS= goutJalrS || goutJmorS || aluopBaln; // bu signal sol alt write data register muxın select biti

//initialize datamemory,instruction memory and registers
//read initial data from files given in hex
initial
begin
$readmemh("initDm.dat",datmem); //read Data Memory
$readmemh("initIM.dat",mem);//read Instruction Memory
$readmemh("initReg.dat",registerfile);//read Register File

	for(i=0; i<31; i=i+1)
	$display("Instruction Memory[%0d]= %h  ",i,mem[i],"Data Memory[%0d]= %h   ",i,datmem[i],
	"Register[%0d]= %h",i,registerfile[i]);
end

initial
begin
pc=0;
#400 $finish;
	
end
initial
begin
clk=0;
//40 time unit for each cycle
forever #20  clk=~clk;
end
initial 
begin
  $monitor($time,"PC %h",pc,"  SUM %h",sum,"   INST %h",instruc[31:0],
"   REGISTER %h %h %h %h ",registerfile[4],registerfile[5], registerfile[6],registerfile[1] );
end
endmodule

