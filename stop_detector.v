module stop_detector
  (
   input  scl,
   input  enable,
   input  sda,
   input  clk,
   output stop
   );
   
   reg 	  low_high_detect_out, low_high_detect_d, sda_ff;

   always @ (posedge clk)
     begin
	low_high_detect_out <= low_high_detect_d;
	sda_ff <= sda;
     end

   always @ (*)
     begin
	if(scl & enable)
	  begin
	     low_high_detect_d = (sda ^ sda_ff) & sda;
	  end
     end

   assign stop = low_high_detect_out;
   
endmodule
