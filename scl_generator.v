module scl_generator
  (
   input      clk,
   input      rst_,
   input      enable,
   output reg scl_out
   );

   reg [5:0]  cnt_ff;
   reg 	      scl_out_d;
   reg [5:0]  cnt_d;
   
   always @ (posedge clk, negedge rst_)
     begin
	if(!rst_)
	  begin
	     scl_out <= 1'd1;
	     cnt_ff <= 6'd0;
	  end
	else
	  begin
	     if(enable)
	       begin
		  scl_out <= scl_out_d;
		  cnt_ff <= cnt_d;
	       end
	  end // else: !if(!rst_)
     end // always @ (posedge clk, negedge rst_)

   always @ (*)
     begin
	if(enable)
	  begin
	     cnt_d = cnt_ff + 1;
	     if (cnt == 6'd49)
	       begin
		  scl_out_d = ~scl_out;
		  cnt_d = 6'd0;	  
	       end
	  end
     end // always @ (*)
   
endmodule // scl_generator
