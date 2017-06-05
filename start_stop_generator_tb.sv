`timescale 1ns/1ps

module start_generator_tb;

   
   // define system frequency in MHz
`define FREQ 50
`define PER 1000/`FREQ

   reg tb_enable;
   reg tb_scl_in;
   reg tb_rst_;
   reg tb_sda_out;
   reg tb_scl_out;
   reg tb_ending;
   reg tb_start_stop;

   start_generator start
     (
      .enable(tb_enable),
      .scl_in(tb_scl_in),
      .rst_(tb_rst_),
      .start_stop(tb_start_stop),
      .ending(tb_ending),
      .sda_out(tb_sda_out),
      .scl_out(tb_scl_out)
      );
   
   initial
     begin
	tb_enable = 1'b1;
	#(`PER*500) tb_enable = 1'b0;
     end

   initial
     begin
	tb_start_stop = 1'd1;
	#(`PER*120) tb_start_stop = 1'd0;
     end
   
   initial
     begin
	tb_rst_ = 1'd0;
	#(`PER*5) tb_rst_ = 1'd1;
	#(`PER*100) tb_rst_ = 1'd0;
	#(`PER*50) tb_rst_ = 1'd1;
     end

   initial
     begin
	tb_scl_in = 1'd1;
	forever
	  begin 
	     #(`PER*25) tb_scl_in = !tb_scl_in;
	  end
     end

endmodule
