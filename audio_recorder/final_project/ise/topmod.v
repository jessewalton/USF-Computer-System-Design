`timescale 1ns / 1ps

module topmod(
    hw_clock100,
    hw_nreset,

    
    // AC97 hardware pins
    ac97_sdata_out, 
    ac97_sdata_in,
    ac97_synch, 
    ac97_bit_clock,
    ac97_reset_b,

    // RAM hardware pins
    hw_ram_rasn, hw_ram_casn,
	hw_ram_wen, hw_ram_ba, hw_ram_udqs_p, hw_ram_udqs_n, hw_ram_ldqs_p, hw_ram_ldqs_n, hw_ram_udm, hw_ram_ldm, hw_ram_ck, hw_ram_ckn, hw_ram_cke, hw_ram_odt,
	hw_ram_ad, hw_ram_dq, hw_rzq_pin, hw_zio_pin,
    
    // Buttons
    hw_but_up, hw_but_down, hw_but_select, hw_but_back,
    
    // LCD hardware
    hw_lcd_dat,
    hw_lcd_rs,
    hw_lcd_rw,
    hw_lcd_e,
    hw_lcd_k,
    
    hw_leds
    
    );
    
    output [7:0] hw_leds;
    //output wire [7:0] hw_leds;
    assign hw_leds = {3'h0, volume} ;
    
    input hw_clock100;
    input hw_nreset;
    wire master_reset;
    assign master_reset = !hw_nreset;
    wire master_clock;
    
    // LCD hardware
    output [3:0] hw_lcd_dat;
    
    output hw_lcd_rs, hw_lcd_rw, hw_lcd_e;
    output hw_lcd_k;
    assign hw_lcd_k = 0;
    
    

    // AC97 hardware
    output ac97_sdata_out;
    input ac97_sdata_in;
    output ac97_synch;
    input ac97_bit_clock;
    output ac97_reset_b;

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
    
    // Buttons
    input hw_but_up, hw_but_down, hw_but_select, hw_but_back;
    wire dbb_up, dbb_down, dbb_select, dbb_back;
    wire debounce_clk;
    assign debounce_clk = master_clock;
    mit_debounce mit_up (
        .reset(master_reset), 
        .clk(debounce_clk), 
        .noisy(hw_but_up), 
        .clean(dbb_up)
    );
    mit_debounce mit_down (
        .reset(master_reset), 
        .clk(debounce_clk), 
        .noisy(hw_but_down), 
        .clean(dbb_down)
    );
    mit_debounce mit_select (
        .reset(master_reset), 
        .clk(debounce_clk), 
        .noisy(hw_but_select), 
        .clean(dbb_select)
    );
    mit_debounce mit_back (
        .reset(master_reset), 
        .clk(debounce_clk), 
        .noisy(hw_but_back), 
        .clean(dbb_back)
    );
    wire [7:0] buttons;
    assign buttons = {4'h0, dbb_select, dbb_back, dbb_down, dbb_up};
    
    
    
    wire fs_ready;
    wire mem_full;
    wire ac97_ready;
    
    // reg [4:0] volume;
    reg [4:0] volume = 28;
    // assign volume = 28;
    
    reg [2:0] fnumber;
    reg [2:0] command;
    wire [7:0] audio_in_data, audio_out_data;
    
    
    
    
    // pBlaze interface
    parameter id_volume = 5;
    parameter id_fnumber = 4;
    parameter id_command = 3;
    parameter id_lcd_dat = 6;
    parameter id_lcd_control = 8;
    
    
    parameter id_buttons = 0;
    parameter id_ready = 7;
    parameter id_memfull = 2;
    
    wire [7:0] pblaze_id;
    wire [7:0] pblaze_out;
    wire [7:0] pblaze_in;
    wire pblaze_wstrobe;
    wire pblaze_rstrobe;
    
    reg [7:0] master_status;
    
    always @ (posedge pblaze_wstrobe) begin
        case(pblaze_id)
            id_volume : volume <= pblaze_out[4:0];
            id_fnumber : fnumber <= pblaze_out[2:0];
            id_command : command <= pblaze_out[2:0];
            //id_lcd_dat : hw_lcd_dat <= pblaze_out[3:0];
            id_lcd_dat : master_status <= pblaze_out;
            //id_lcd_control : {hw_lcd_rs, hw_lcd_rw, hw_lcd_e} <= pblaze_out[2:0];
        endcase
    end
    assign pblaze_in = (pblaze_id == id_buttons) ? buttons : 
                       (pblaze_id == id_ready)   ? {7'h00, fs_ready} : 
                       (pblaze_id == id_memfull) ? {7'h00, mem_full} :
                        /*else*/                   8'h00;
    
    
    wire pblazet_int;
    assign pblazet_int = 0;
    
    // PEEEEKKOOOOOBLAAAAZZEE IT 420 YOLO
    picoblaze yoloswag (
    .port_id(pblaze_id), 
    .read_strobe(pblaze_rstrobe), 
    .in_port(pblaze_in), 
    .write_strobe(pblaze_wstrobe), 
    .out_port(pblaze_out), 
    .interrupt(mem_full), 
    .interrupt_ack(), 
    .reset(master_reset), 
    .clk(master_clock)
    );
    
    
    // pBlaze2 interface
    parameter id_dat = 2;
    parameter id_control = 4;

    parameter id_handshake = 3;
    parameter id_lcdin = 1;

    wire [7:0] pblaze_idt;
    wire [7:0] pblaze_outt;
    wire [7:0] pblaze_int;
    wire pblaze_wstrobet;
    wire pblaze_rstrobet;
    
    
    reg nline = 0;
    reg [7:0] rbdat;
    reg strobe;
    wire lcd_handshake;
    
    //assign strobe = pblaze_wstrobet && (pblaze_idt == id_dat);
    //assign rbdat = pblaze_out;
    
    always @ (negedge master_clock) begin
        if (pblaze_wstrobet) begin
            if (pblaze_idt == id_dat) begin
                rbdat <= pblaze_outt;
                strobe <= 1;
            end
            else begin
                strobe <= 0;
            end
            
            if (pblaze_idt == id_control) begin
                nline <= pblaze_outt[0];
            end
        end
        else begin
            strobe <= 0;
        end
    end
    assign pblaze_int = (pblaze_idt == id_handshake) ? {7'h00, lcd_handshake} : 
                        (pblaze_idt == id_lcdin    ) ? master_status : 
                        /*else*/                    0;
    
    
    
    
    // blaze for lcd
    picoblazet blazelcd (
    .port_id(pblaze_idt), 
    .read_strobe(pblaze_rstrobet), 
    .in_port(pblaze_int), 
    .write_strobe(pblaze_wstrobet), 
    .out_port(pblaze_outt), 
    .interrupt(), 
    .interrupt_ack(), 
    .reset(master_reset), 
    .clk(master_clock)
    );
    
    
    /*
    reg nline = 0;
    reg strobe;
    reg [7:0] rbdat;
    reg [4:0] welcomecount = 15;
    reg [8*15-1:0] welcomemessage = 120'h57656c636f6d6520746f2048454c4c;
    always @(posedge master_clock) begin
        if(welcomecount) begin
            if (strobe) begin
                strobe <= 0;
            end
            else begin
                rbdat <= welcomemessage[8*(welcomecount-1) +:8];
                welcomecount <= welcomecount - 1;
                strobe <= 1;
            end
        end
        else begin
            strobe <= 0;
        end
    end
    */
    
    
        
    
    // Instantiate the MUTHAFUCKIN LCD
    lcd4 mylcd (
    .nline(nline), 
    .rbdat(rbdat), 
    .strobe(strobe), 
    .reset(master_reset), 
    .CLK(master_clock), 
    .hw_lcd_dat(hw_lcd_dat), 
    .hw_lcd_rs(hw_lcd_rs), 
    .hw_lcd_rw(hw_lcd_rw), 
    .hw_lcd_e(hw_lcd_e),
    .handshake(lcd_handshake)
    );
    
    
    
    
    
    // Instantiate the file system
    streaming_file_system mysfs (
    .command(command), 
    .mem_full(mem_full), 
    .fnumber(fnumber), 
    .ready(fs_ready), 
    .data_in(audio_in_data), 
    .data_out(audio_out_data), 
    .sync(ac97_ready), 
    .ram_clock(hw_clock100), 
    .this_reset(master_reset), 
    .clk_out(master_clock), 
    
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
    .hw_zio_pin(hw_zio_pin)
    );
    
    
    wire [7:0] loopback;
    
    // Instantiate the ac97 thingy
    ac97audio myac97 (
    .clock_100mhz(master_clock), 
    .reset(master_reset), 
    .volume(volume), 
    .audio_in_data(audio_in_data), 
    .audio_out_data(audio_out_data), 
    .ready(ac97_ready), 
    .audio_reset_b(ac97_reset_b), 
    .ac97_sdata_out(ac97_sdata_out), 
    .ac97_sdata_in(ac97_sdata_in), 
    .ac97_synch(ac97_synch), 
    .ac97_bit_clock(ac97_bit_clock)
    );
    
    
    reg [24:0] clkdiv1s;
    reg [25:0] thingcount;
    
    /*
    initial begin
        volume <= 28;
        fnumber <= 0;
    end
    
    always @ (posedge master_clock) begin
        if(master_reset) begin
            hw_leds[7:0] <= 8'h00;
            clkdiv1s <= 0;
            thingcount <= 0;
        end
        
        else begin
            hw_leds[7] <= mem_full;
            
            if (!clkdiv1s) begin
                if (thingcount == 0)
                    command <= 0;
                    
                if (thingcount == 1) begin
                    hw_leds[0] <= 1;
                    command <= 3;
                end
                
                if (thingcount == 400) begin
                    hw_leds[0] <= 0;
                    command <= 0;
                end
                
                if (thingcount == 401) begin
                    hw_leds[1] <= 1;
                    command <= 1;
                end 
                if (thingcount == 403) begin
                    hw_leds[1] <= 0;
                    command <= 2;
                end
                if (thingcount == 405) begin
                    hw_leds[1] <= 1;
                    command <= 1;
                end
                
                
                thingcount <= thingcount + 1;
            end
            clkdiv1s <= clkdiv1s + 1;
        end
    end
    */
    
    

endmodule
