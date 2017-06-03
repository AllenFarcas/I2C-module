`timescale 1ns/1ps

module fsm_slave_tb;
   
   // define system frequency in MHz
`define FREQ 50
`define PER 1000/`FREQ

   reg tb_rst_;
   reg tb_clk;
   reg tb_sda_in;
   reg tb_scl_in;
   reg tb_fsm_select_;
   reg tb_write_read;
   reg tb_sda_out;

   fsm_slave sclav
     (
      .rst_(tb_rst_),
      .clk(tb_clk),
      .sda_in(tb_sda_in),
      .scl_in(tb_scl_in),
      .fsm_select_(tb_fsm_select_),
      .write_read(tb_write_read),
      .sda_out(tb_sda_out)
      );

   initial
     begin
	tb_clk = 1'b0;
	forever begin
	   #(`PER/2) tb_clk = !tb_clk;
	end
     end

   initial
     begin
	tb_rst_ = 1'd0;
	#(`PER*5) tb_rst_ = 1'd1;
     end

   initial
     begin
	 tb_scl_in = 1'd1;
	forever
	begin 
		#(`PER*25) tb_scl_in = !tb_scl_in;
	end
     end

   initial
     begin
	tb_fsm_select_ = 1'd1;
     end

   initial
     begin
	tb_sda_in = 1'd1;
	#(`PER*5) tb_sda_in = 1'd0;
	#(`PER*25) tb_sda_in = 1'd0;
	#(`PER*25) tb_sda_in = 1'd0;
	#(`PER*25) tb_sda_in = 1'd1;
	#(`PER*25) tb_sda_in = 1'd1;
	#(`PER*25) tb_sda_in = 1'd0;
	#(`PER*25) tb_sda_in = 1'd0;
	
	#(`PER*25) tb_sda_in = 1'd1;
	#(`PER*25) tb_sda_in = 1'd0;
	#(`PER*25) tb_sda_in = 1'd1;
	#(`PER*25) tb_sda_in = 1'd1;
	#(`PER*50) tb_sda_in = 1'd1;
	#(`PER*25) tb_sda_in = 1'd0;
	#(`PER*25) tb_sda_in = 1'd0;
	#(`PER*25) tb_sda_in = 1'd1;
	#(`PER*25) tb_sda_in = 1'd1;
	#(`PER*25) tb_sda_in = 1'd0;
	#(`PER*25) tb_sda_in = 1'd0;
	
	#(`PER*25) tb_sda_in = 1'd1;
	#(`PER*25) tb_sda_in = 1'd0;
	#(`PER*25) tb_sda_in = 1'd1;
	#(`PER*25) tb_sda_in = 1'd0;
	#(`PER*25) tb_sda_in = 1'd0;
	#(`PER*25) tb_sda_in = 1'd0;
	#(`PER*25) tb_sda_in = 1'd1;
	#(`PER*25) tb_sda_in = 1'd1;
	#(`PER*25) tb_sda_in = 1'd0;
	#(`PER*25) tb_sda_in = 1'd0;
	
	#(`PER*25) tb_sda_in = 1'd1;
	#(`PER*25) tb_sda_in = 1'd0;
	#(`PER*25) tb_sda_in = 1'd1;
	#(`PER*25) tb_sda_in = 1'd0;
	#(`PER*25) tb_sda_in = 1'd0;
	#(`PER*25) tb_sda_in = 1'd0;
	#(`PER*25) tb_sda_in = 1'd1;
	#(`PER*25) tb_sda_in = 1'd1;
	#(`PER*25) tb_sda_in = 1'd0;
	#(`PER*25) tb_sda_in = 1'd0;
	
	#(`PER*25) tb_sda_in = 1'd1;
	#(`PER*25) tb_sda_in = 1'd0;
	#(`PER*25) tb_sda_in = 1'd1;
	#(`PER*25) tb_sda_in = 1'd0;
	#(`PER*135) tb_sda_in = 1'd0;
	#(`PER*25) tb_sda_in = 1'd1;
     end
   
endmodule
