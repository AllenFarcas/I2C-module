module scl_generator
  (
   input      clk,
   input      rst_,
   output reg scl_out
   );

   reg [5:0]  cnt;
   reg 	      scl_out_d;
   reg [5:0]  cnt_d;
   
   always @ (posedge clk, negedge rst_)
     begin
	if(!rst_)
	  begin
	     scl_out <= 1'd1;
	     cnt <= 6'd0;
	  end
	else
	  begin
	     scl_out <= scl_out_d;
	     cnt <= cnt_d;
	  end
     end

   always @ (*)
     begin
	scl_out_d = scl_out;
	cnt_d = cnt + 1;
	if (cnt == 6'd49)
	  begin
	     scl_out_d = ~scl_out;
	     cnt_d = 6'd0;	  
	  end
     end
   
endmodule
