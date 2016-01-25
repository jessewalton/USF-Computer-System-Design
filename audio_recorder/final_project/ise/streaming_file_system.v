`timescale 1ns / 1ps


module streaming_file_system(
    command, mem_full, fnumber, ready,
    data_in, data_out, sync, 
    ram_clock, 
    this_reset, 
    clk_out,
    
    // RAM hardware pins
    hw_ram_rasn, hw_ram_casn,
	hw_ram_wen, hw_ram_ba, hw_ram_udqs_p, hw_ram_udqs_n, hw_ram_ldqs_p, hw_ram_ldqs_n, hw_ram_udm, hw_ram_ldm, hw_ram_ck, hw_ram_ckn, hw_ram_cke, hw_ram_odt,
	hw_ram_ad, hw_ram_dq, hw_rzq_pin, hw_zio_pin
    
    );
    

    
    parameter MESSAGE_BITS = 3;
    parameter MEM_ADDRESS_BITS = 26;
    
    input [2:0] command;
    output reg mem_full;
    input [2:0] fnumber;
    // input [MEM_ADDRESS_BITS-MESSAGE_BITS-1:0] flen;
    input [7:0] data_in;
    output reg [7:0] data_out;
    input sync;
    input ram_clock;
    input this_reset;
    output reg ready;
    
    output clk_out;

    
    reg [MESSAGE_BITS-1:0] fnumber_addr;
    reg [MEM_ADDRESS_BITS-MESSAGE_BITS-1:0] offset;
    wire [MEM_ADDRESS_BITS-1:0] full_ram_addr;
    assign full_ram_addr = {fnumber_addr, offset};
    
    reg [MEM_ADDRESS_BITS-MESSAGE_BITS-1:0] fsizes [0:7];  // 8 long array of 23 bit numbers
    
    wire [MEM_ADDRESS_BITS-1:0] max_ram_address;
    reg [7:0] ram_data_in;
    wire [7:0] ram_data_out;
    reg ram_read_request;
    reg ram_read_ack;
    wire ram_rdy;
    wire ram_rd_data_pres;
    reg ram_write_enable;
    
    // RAM hardware bullshit
	output hw_ram_rasn;
	output hw_ram_casn;
	output hw_ram_wen;
	output [2:0] hw_ram_ba;
	inout hw_ram_udqs_p;
	inout hw_ram_udqs_n;
	inout hw_ram_ldqs_p;
	inout hw_ram_ldqs_n;
	output hw_ram_udm;
	output hw_ram_ldm;
	output hw_ram_ck;
	output hw_ram_ckn;
	output hw_ram_cke;
	output hw_ram_odt;
	output [12:0] hw_ram_ad;
	inout [15:0] hw_ram_dq;
	inout	hw_rzq_pin;
	inout hw_zio_pin;
    
    // Instantiate the RAM
    ram_interface_wrapper myram (
    .address(full_ram_addr), 
    .data_in(ram_data_in), 
    .write_enable(ram_write_enable), 
    .read_request(ram_read_request), 
    .read_ack(ram_read_ack), 
    .data_out(ram_data_out), 
    .reset(this_reset), 
    .clk(ram_clock), 
    
    .hw_ram_rasn(hw_ram_rasn), 
    .hw_ram_casn(hw_ram_casn), 
    .hw_ram_wen(hw_ram_wen), 
    .hw_ram_ba(hw_ram_ba), 
    .hw_ram_udqs_p(hw_ram_udqs_p), 
    .hw_ram_udqs_n(hw_ram_udqs_n), 
    .hw_ram_ldqs_p(hw_ram_ldqs_p), 
    .hw_ram_ldqs_n(hw_ram_ldqs_n), 
    .hw_ram_udm(hw_ram_udm), 
    .hw_ram_ldm(hw_ram_ldm), 
    .hw_ram_ck(hw_ram_ck), 
    .hw_ram_ckn(hw_ram_ckn), 
    .hw_ram_cke(hw_ram_cke), 
    .hw_ram_odt(hw_ram_odt), 
    .hw_ram_ad(hw_ram_ad), 
    .hw_ram_dq(hw_ram_dq), 
    .hw_rzq_pin(hw_rzq_pin), 
    .hw_zio_pin(hw_zio_pin), 
    
    .clkout(clk_out), 
    .sys_clk(clk_out), 
    .rdy(ram_rdy), 
    .rd_data_pres(ram_rd_data_pres), 
    .max_ram_address()
    );
    
    
    parameter c_play = 1;
    parameter c_pause = 2;
    parameter c_record = 3;
    parameter c_delete = 4;
    parameter c_delete_all = 5;
    
    
   parameter s_wait_command  = 4'b0000;
   parameter s_finish  = 4'b0001;
   parameter s_delete  = 4'b0010;
   parameter s_delete_all  = 4'b0011;
   parameter s_play   = 4'b0100;
   parameter s_play2  = 4'b0101;
   parameter s_play3  = 4'b0110;
   parameter s_record  = 4'b0111;
   parameter s_record2  = 4'b1000;
   parameter s_record3 = 4'b1001;
   
   /*
   parameter state11 = 4'b1010;
   parameter state12 = 4'b1011;
   parameter state13 = 4'b1100;
   parameter state14 = 4'b1101;
   parameter state15 = 4'b1110;
   parameter state16 = 4'b1111;
   */

   (* FSM_ENCODING="SEQUENTIAL", SAFE_IMPLEMENTATION="NO" *) reg [3:0] state = s_finish;

   always@(posedge clk_out)
      if (this_reset) begin
         state <= s_wait_command;
         ram_read_request <= 0;
         ram_read_ack <= 0;
         ram_write_enable <= 0;
         fsizes[0] <= 0;
         fsizes[1] <= 0;
         fsizes[2] <= 0;
         fsizes[3] <= 0;
         fsizes[4] <= 0;
         fsizes[5] <= 0;
         fsizes[6] <= 0;
         fsizes[7] <= 0;
         
         
      end
      else
         (* FULL_CASE, PARALLEL_CASE *) case (state)
            s_wait_command : begin
               if (command == c_play) begin 
                  state <= s_play;
                  offset <= 0;
                  fnumber_addr <= fnumber;
                  ready <= 0;
               end
               
               else if (command == c_record) begin  
                  state <= s_record;
                  fnumber_addr <= fnumber;
                  offset <= 0;
                  ready <= 0;
               end
               
               else if (command == c_delete) begin
                  state <= s_delete;
                  fnumber_addr <= fnumber;
                  ready <= 0;
               end 
               
               else if (command == c_delete_all) begin
                  state <= s_delete_all;
                  fnumber_addr <= fnumber;
                  ready <= 0;
               end 
               
               else begin
                    ready <= 1;
                    ram_read_request <= 0;
                    ram_read_ack <= 0;
               end
               
            end
            
            s_finish : begin
                if (!command) begin
                    mem_full <= 0;
                    ready <= 0;
                    state <= s_wait_command;
                end
            end
                    
            s_delete : begin
                fsizes[fnumber_addr] <= 0;
                state <= s_finish;
            end
            
            s_delete_all : begin
                fsizes[0] <= 0;
                fsizes[1] <= 0;
                fsizes[2] <= 0;
                fsizes[3] <= 0;
                fsizes[4] <= 0;
                fsizes[5] <= 0;
                fsizes[6] <= 0;
                fsizes[7] <= 0;
                state <= s_finish;
            end
            
            s_play : begin 
                ram_read_ack <= 0;
                if (offset == fsizes[fnumber_addr])  // Are we at the end of of the message?
                    state <= s_finish;
          
                else if (!sync)  // wait for sync to drop low again
                    state <= s_play2;
            end
            
            s_play2 : begin
                if (sync && (command == c_play)) begin  // Wait for the frame sync to get the next byte
                    state <= s_play3;
                    ram_read_request <= 1;
                end
                else if (command == c_pause)  // If pause, just stay in this block
                    state <= s_play2;
                else if (command != c_play)  // Something other than play means finish up and return to function select
                    state <= s_finish;
                else
                    state <= s_play2;
            end
            
            s_play3 : begin
                if (!ram_rd_data_pres)  // Wait for RAM te present the data
                    state <= s_play3;
                else begin
                    data_out <= ram_data_out;
                    offset <= offset + 1;
                    ram_read_request <= 0;  // Do I need to deassert this more quickly? 
                    ram_read_ack <= 1; 
                    state <= s_play;
                end
            end
            
            
            s_record : begin
                if (command != c_record) begin  // When we finish recording, write out our file size
                    state <= s_finish;
                    fsizes[fnumber_addr] <= offset;
                end
                    
                else if (sync) begin  // wait for frame sync to grab data and write
                    ram_data_in <= data_in;
                    ram_write_enable <= 1;
                    state <= s_record2;
                end
            end
            
            s_record2 : begin
                ram_write_enable <= 0;
                offset <= offset + 1;
                state <= s_record3;
            end
            
            s_record3 : begin
                if (offset == 0) begin  // praying for rollover - max message length
                    mem_full <= 1;
                    fsizes[fnumber_addr] <= -1;  // please please wrap around
                    state <= s_finish;
                end
                else if (!sync)  // wait for sync to drop
                    state <= s_record;
            end
            
         endcase
    
 endmodule
							