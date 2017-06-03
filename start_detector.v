module start_detector
  (
   input  scl,
   input  enable,
   input  sda,
   input  clk,
   output start
   );
   
   reg 	  high_low_detect_out, high_low_detect_d, sda_ff;

   always @ (posedge clk)
     begin
	high_low_detect_out <= high_low_detect_d;
	sda_ff <= sda;
     end

   always @ (*)
     begin
	if(scl & enable)
	  begin
	     high_low_detect_d = (sda ^ sda_ff) & ~sda;
	  end
     end

   assign start = high_low_detect_out;
   
endmodule
