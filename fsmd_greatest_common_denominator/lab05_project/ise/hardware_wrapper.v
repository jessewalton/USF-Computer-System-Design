`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:03:45 02/10/2015 
// Design Name: 
// Module Name:    hardware_wrapper 
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
module hardware_wrapper(clk, btn_reset, btn_start, led_gcd, led_done, switch_x, switch_y);
	input clk, btn_reset, btn_start;
	input [3:0] switch_x, switch_y;
	output led_done;
	output [3:0] led_gcd;
	
	wire reset, clean_start;
	assign reset = !btn_reset;

	debounceIndex debounce_start(reset, clk, btn_start, clean_start);
	
	GCD_TOP my_gcd(clean_start, switch_x, switch_y, reset, led_gcd, led_done, clk);

endmodule
