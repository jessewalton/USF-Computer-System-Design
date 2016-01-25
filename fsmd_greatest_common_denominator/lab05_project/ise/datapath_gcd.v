`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:28:54 02/10/2015 
// Design Name: 
// Module Name:    datapath_gcd 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module datapath_gcd(x_sel, y_sel, x_ld, y_ld, x_in, y_in, d_ld, x_neq_y, x_lt_y, d_out, clk, reset);
	input [3:0] x_in, y_in;
	input x_sel, y_sel, x_ld, y_ld, d_ld;
	input clk, reset;
	output [3:0] d_out;
	output x_lt_y, x_neq_y;
	
	wire [3:0] x_val, y_val, x_mux, y_mux, x_sub_y, y_sub_x;
	
	
	fourbitneq my_neq(x_val, y_val, x_neq_y);
	fourbitlt my_lt(x_val, y_val, x_lt_y);
	
	fourbitmux my_x_mux(x_in, x_sub_y, x_sel, x_mux);
	fourbitmux my_y_mux(y_in, y_sub_x, y_sel, y_mux);
	
	fourbitreg my_x_reg(x_mux, x_val, clk, x_ld, reset);
	fourbitreg my_y_reg(y_mux, y_val, clk, y_ld, reset);
	
	fourbitreg my_d_out(x_val, d_out, clk, d_ld, reset);
	
	fourbitsubtract my_x_sub_y(x_val, y_val, x_sub_y);
	fourbitsubtract my_y_sub_x(y_val, x_val, y_sub_x);
	


endmodule


module fourbitreg(ival, oval, clk, load, reset);
	input [3:0] ival;
	input clk, load, reset;
	output reg [3:0] oval;
	always @(negedge clk) begin
		if(reset)
			oval <= 0;
		else if(load)
			oval <= ival;
	end
endmodule

module fourbitmux(lowval, highval, sel, oval);
	input [3:0] lowval, highval;
	input sel;
	output [3:0] oval;
	
	assign oval = sel ? highval : lowval;
endmodule

module fourbitsubtract(minuend, subtrahend, difference);
	input [3:0] minuend, subtrahend;
	output [3:0] difference;
	
	assign difference = minuend - subtrahend;
endmodule

module fourbitneq(a, b, neq);
	input [3:0] a, b;
	output neq;
	assign neq = (a != b);
endmodule

module fourbitlt(a, b, lt);
	input [3:0] a, b;
	output lt;
	assign lt = (a < b);
endmodule

	
