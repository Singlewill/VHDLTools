/*
 * 	Filename		:	rst_sync.v
 *	Author   		: 	Kalo
 *	Description	:	Asynchronously reset, and release synchronously
 *	Called by	 	: 	Top module
 * */

`timescale 1ns / 1ps


module RST_SYNC (Clk,			// clk input 
		 		 Rst_async,		//async reset signal input
		 		 Rst_sync		//sync reset signal outout
				);


//PORT declarations
input 	Clk;
input 	Rst_async;
output 	Rst_sync;


//variable declarations
reg reg_L1;	//对复位输入信号Rst_async一级锁存
reg reg_L2; //对复位输入信号Rst_async二级锁存


always@(posedge Clk or negedge Rst_async)
begin
	if (!Rst_async)
	begin
		reg_L1 <= 1'b0;
		reg_L2 <= 1'b0;
	end
	else 
	begin
		reg_L1 <= 1'b1;
		reg_L2 <= reg_L1;
	end
end

assign Rst_sync = reg_L2;

endmodule
