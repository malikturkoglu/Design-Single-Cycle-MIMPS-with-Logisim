module control(in,regdest,alusrc,memtoreg,regwrite,memread,memwrite,branch,aluop1,aluop2,aluopandi,aluopBlez,aluopBaln);
input [5:0] in;
output regdest,alusrc,memtoreg,regwrite,memread,memwrite,branch,aluop1,aluop2,aluopandi,aluopBlez,aluopBaln;
wire rformat,lw,sw,beq,andi,blez,baln;
assign rformat=~|in; // input 000000 ise rformat=1 çünkü rformatta opcode daima 0
assign lw=in[5]& (~in[4])&(~in[3])&(~in[2])&in[1]&in[0];
assign sw=in[5]& (~in[4])&in[3]&(~in[2])&in[1]&in[0];
assign beq=~in[5]& (~in[4])&(~in[3])&in[2]&(~in[1])&(~in[0]);
assign andi=~in[5]& (~in[4])&(in[3])&in[2]&(~in[1])&(~in[0]); //001100 opcode of andi
assign blez=~in[5]& (~in[4])&(~in[3])&in[2]&in[1]&(~in[0]); //000110 opcode of blez
assign baln=~in[5]& in[4]&in[3]&(~in[2])&in[1]&in[0]; //011011 opcode of baln 

assign regdest=rformat;
assign alusrc=lw |sw | andi; // andi 1 ise alusrc=1 olmalı ki imm değeri alsın
assign memtoreg=lw;
assign regwrite=rformat|lw|andi|baln;
assign memread=lw;
assign memwrite=sw;
assign branch=beq | blez;
assign aluop1=rformat;
assign aluop2=beq;
assign aluopandi=andi;
assign aluopBlez=blez;
assign aluopBaln=baln;
endmodule
