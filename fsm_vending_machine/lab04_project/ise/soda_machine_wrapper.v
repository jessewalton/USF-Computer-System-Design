`timescale 1ns / 1ps

/*
NOTES!!!!!!
quarter_switch, nickel_switch, dime_switch, soda_switch, diet_switch
those all should be tied to the actual hardware with a UCF file




*/




module soda_machine_wrapper(quarter_switch, nickel_switch, dime_switch, soda_switch, diet_switch, soda_given, diet_given, change_count, reset, clk);

// Inputs. The reset input is to be tied to the red RESET button on the FPGA.
//That red button is ***ACTIVE LOW***, so the value is normally 1; pressing it results in 0
input quarter_switch, nickel_switch, dime_switch, soda_switch, diet_switch, reset, clk;

output soda_given, diet_given; // Map each to an LED
output [2:0] change_count; // Map to three LEDs. 

// Wires to connect Soda FSM to the capture module
wire change, give_soda, give_diet;

// Your FSM module - fill in with name of your soda machine top module
soda_machine soda_fsm(	.quarter_switch(quarter_switch),.nickel_switch(nickel_switch),.dime_switch(dime_switch),.soda_switch(soda_switch),.diet_switch(diet_switch),
							.change(change),.give_soda(give_soda),.give_diet(give_diet),
							.reset(~reset), .clk(clk));
							
// FSM Output capture module. 
// ** NOTE ** Our reset line is active-low, but the fsmcap expects active-high. Therefore, we pass
//the inverted reset (~reset) as the reset signal to the fsmcap.
soda_machine_capture fsmcap(	.give_change(change),.give_diet(give_diet),.give_soda(give_soda),
										.soda_given(soda_given),.diet_given(diet_given),.change_count(change_count),
										.reset(~reset),.clk(clk));

endmodule

module soda_machine_capture(give_change, give_diet, give_soda, reset, change_count, soda_given, diet_given, clk);

input give_change, give_diet, give_soda, reset, clk;

// Outputs the number of nickels returned as change.
output reg [2:0] change_count;
output reg soda_given;
output reg diet_given;

// Asynchronous, preemptive, active-high reset.

always @(negedge clk or posedge reset)
begin
	if(reset) begin
		change_count = 0;
		soda_given = 0;
		diet_given = 0;
	end else begin
		if(give_change) change_count = change_count + 1;
		else if(give_soda) begin 
			soda_given = 1;
			change_count = 0;
			diet_given = 0;
		end else if(give_diet) begin
			diet_given = 1;
			change_count = 0;
			soda_given = 0;
		end
	end
end

endmodule
