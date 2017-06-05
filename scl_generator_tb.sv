`timescale 1ns/1ps

module scl_generator_tb;
   // define system frequency in MHz
`define FREQ 50
`define PER 1000/`FREQ
   
   //testbench variables
   reg      tb_clk;
   reg 	    tb_rst_;
   reg 	    tb_enable;
   wire     tb_scl_out;

   //instantiate DUT

  scl_generator test1
    (
     .clk(tb_clk),
     .rst_(tb_rst_),
     .enable(tb_enable),
     .scl_out(tb_scl_out)
     );

   //generate
   initial 
     begin
	tb_clk = 1'b0;
	forever
	  begin
	     #(`PER*2) tb_clk = !tb_clk;
	  end
     end

   initial
     begin
	tb_enable = 1'b0;
	#(`PER*70) tb_enable = 1'b1;
	#(`PER*2000) tb_enable = 1'b0;
     end
   
   // initialize simulation
   initial
     begin
	tb_rst_ = 1'b0;
	#(`PER*7) tb_rst_ = 1'b1;
     end
   
endmodule
