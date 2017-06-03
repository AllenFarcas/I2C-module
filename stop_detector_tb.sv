`timescale 1ns/1ps

module start_detector_tb;
   
   // define system frequency in MHz
`define FREQ 50
`define PER 1000/`FREQ

   reg tb_scl;
   reg tb_enable;
   reg tb_sda;
   reg tb_clk;
   wire tb_stop;

   //instantiate DUT
   stop_detector st
     (
      .scl(tb_scl),
      .enable(tb_enable),
      .sda(tb_sda),
      .clk(tb_clk),
      .stop(tb_stop)
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
	tb_enable = 1'b0;
	#(`PER * 5) tb_enable = 1'b1;
	#(`PER * 50) tb_enable = 1'b0;
     end
   
   initial
     begin
	tb_scl = 1'b1;
	/*#(`PER*7) tb_scl = 1'b0;
	#(`PER*4) tb_scl = 1'b1;
	#(`PER*6) tb_scl = 1'b0;
	#(`PER*5) tb_scl = 1'b1;
	#(`PER*4) tb_scl = 1'b0;
	#(`PER*5) tb_scl = 1'b1;
	#(`PER*7) tb_scl = 1'b0;
	#(`PER*8) tb_scl = 1'b1;
	#(`PER*5) tb_scl = 1'b0;
	#(`PER*9) tb_scl = 1'b1;
*/
     end // initial begin

    initial
     begin
	tb_sda = 1'b1;
	#(`PER*9) tb_sda = 1'b0;
	#(`PER*5) tb_sda = 1'b1;
	#(`PER*8) tb_sda = 1'b0;
	#(`PER*7) tb_sda = 1'b1;
	#(`PER*6) tb_sda = 1'b0;
	#(`PER*4) tb_sda = 1'b1;
	#(`PER*8) tb_sda = 1'b0;
	#(`PER*6) tb_sda = 1'b1;
	#(`PER*9) tb_sda = 1'b0;
	#(`PER*5) tb_sda = 1'b1;
     end
endmodule
