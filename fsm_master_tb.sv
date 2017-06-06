`timescale 1ns/1ps

module fsm_master_tb;

   // define system frequency in MHz
`define FREQ 50
`define PER 1000/`FREQ

   reg tb_rst_;
   reg tb_clk;
   reg tb_sda_in;
   reg [7:0] tb_reset_register;
   reg [7:0] tb_control_reg;
   wire	     tb_scl_out;
   wire	     tb_sda_out;
   wire	     tb_sda_select;
   reg 	     tb_fsm_select_;
   

   fsm_master master
     (
      .rst_(tb_rst_),
      .clk(tb_clk),
      .sda_in(tb_sda_in),
      .fsm_select_(tb_fsm_select_),
      .reset_register(tb_reset_register),
      .control_reg(tb_control_reg),
      .scl_out(tb_scl_out),
      .sda_out(tb_sda_out),
      .sda_select(tb_sda_select)
      );

   initial
     begin
	tb_clk = 1'b0;
	forever begin
	   #(`PER) tb_clk = !tb_clk;
	end
     end

   initial
     begin
	tb_rst_ = 1'd0;
	#(`PER*2) tb_rst_ = 1'd1;
     end

   initial
     begin
	tb_fsm_select_ = 1'd0;
     end

   initial
     begin
	tb_sda_in = 1'b0;
	forever begin
		#(`PER*150) tb_sda_in = 1'b1;
		#(`PER*120) tb_sda_in = 1'b0;
		#(`PER*140) tb_sda_in = 1'b1;
		#(`PER*120) tb_sda_in = 1'b0;
		#(`PER*150) tb_sda_in = 1'b0;
		#(`PER*350) tb_sda_in = 1'b1;
		#(`PER*130) tb_sda_in = 1'b0;
		#(`PER*230) tb_sda_in = 1'b1;
		#(`PER*130) tb_sda_in = 1'b0;
	end
     end

   initial
     begin
	tb_reset_register = 8'b11001100;
	#(`PER*500) tb_reset_register = 8'd0;
     end

   initial
     begin
	tb_control_reg = 8'b01010101;
     end
   
endmodule
