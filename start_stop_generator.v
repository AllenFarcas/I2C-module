module start_stop_generator
  (
   input      enable,
   input      scl_in,
   input      rst_,
   input      start_stop, // 1 = start, 0 = stop 
   output reg sda_out,
   output reg ending,
   output reg scl_out
   );

   localparam IDLE = 2'd0;
   localparam START = 2'd1;
   localparam STOP = 2'd2;
   
   
   reg [1:0]  current_state;
   reg [1:0]  next_state;
   
   reg 	      sda_out_d;
   reg 	      scl_out_d;
   reg 	      ending_d; 
	      
   always @ (*)
     begin
	case(current_state)

	  IDLE :
	    if(enable & !ending)
	      begin
		 if(start_stop)
		   begin
		      sda_out_d = 1'd1;
		      scl_out_d = 1'd1;
		      ending_d = 1'd0;
		      next_state = START;
		   end
		 else
		   begin
		      sda_out_d = 1'd0;
		      scl_out_d = 1'd1;
		      ending_d = 1'd0;
		      next_state = STOP;
		   end
	      end
	    else
	      begin
		 ending_d = 1'd0;
		 next_state = IDLE;
	      end

	  START :
	    if(enable & !ending)
	      begin
		 sda_out_d = 1'd0;
		 scl_out_d = 1'd1;
		 ending_d = 1'd1;
	      end
	    else
	      begin
		 ending_d = 1'd0;
		 next_state = IDLE;
	      end

	  STOP :
	    if(enable & !ending)
	      begin
		 sda_out_d = 1'd1;
		 scl_out_d = 1'd1;
		 ending_d = 1'd1;
	      end
	    else
	      begin
		 ending_d = 1'd0;
		 next_state = IDLE;
	      end
	  
	endcase // case (current_state)
     end // always @ (*)

   always @ (posedge scl_in)
     begin
	if(!rst_)
	  begin
	     sda_out_d <= 1'd1;
	     scl_out_d <=1'd1;
	     ending_d <= 1'd0;
	     current_state <= IDLE;
	  end
	else
	  begin
	     sda_out <= sda_out_d;
	     scl_out <= scl_out_d;
	     ending <= ending_d;
	     current_state <= next_state;
	  end // else: !if(!rst_)
     end // always @ (posedge sda_in)
   
endmodule // start_generator
