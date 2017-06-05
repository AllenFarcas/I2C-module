module fsm_master
  (
   input       rst_,
   input       clk,
   input       sda_in,
   input       fsm_select_,
   input [7:0] reset_register, //Registrul de control cu reset
   input [7:0] control_reg, //registrul de control al scrierii/ citirii
   output reg  scl_out,
   output reg  sda_out,
   output reg  sda_select
   );

   //State codification
   localparam IDLE = 'd0;
   localparam START = 'd1;
   localparam SEND_SLAVE_ADDRESS = 'd2;
   localparam ACK_RECEIVE = 'd3;
   localparam WRITE = 'd4;
   localparam READ = 'd5;
   localparam SEND_ACK = 'd6;
   localparam STOP = 'd7;
   

   //Registrii de control
   localparam REG_READ = 8'10101010;
   localparam REG_WRITE = 8'01010101;
   localparam REG_RESET = 8'11001100; // valoarea de reset

   //Registrii de scriere
   localparam REG_WR1 = 8'01010111;
   localparam REG_WR2 = 8'11101010;

   //Adresa Slave
   localparam SLAVE_ADDRESS = 7'b1011010;

   reg [3:0]   current_state;
   reg [3:0]   next_state;

   reg 	       sda_out_d;
   
   reg 	       sp_enable_ff;
   reg 	       sp_rst_ff;
   reg 	       sp_start_stop_ff;
   reg 	       sp_sda_out_ff;
   reg 	       sp_scl_out_ff;
   reg 	       first_start_ff;
   reg 	       bit_count_ff; 
   reg 	       send_slave_ff;
   reg 	       sda_in_ff;
   reg 	       ack_ff;
   reg [7:0]   read_byte_ff;
   
   
   reg 	       sp_enable_d;
   reg 	       sp_rst_d;
   reg 	       sp_start_stop_d;
   reg 	       sp_sda_out_d;
   reg 	       sp_scl_out_d;
   reg 	       first_start_d;
   reg 	       bit_count_d;
   reg 	       send_slave_d;
   reg 	       sda_in_d;
   reg 	       ack_d;
   reg [7:0]   read_byte_d;
   
   
   wire        sp_ending;        
   wire        scl_intern;
   
   //Instantiate modules
   start_stop_generator s_p
     (
      .enable(sp_enable_ff),
      .scl_in(scl_intern),
      .rst_(sp_rst_ff),
      .start_stop(sp_start_stop_ff),
      .sda_out(sp_sda_out_ff),
      .ending(sp_ending),
      .scl_out(sp_scl_out_ff)
      );

   scl_generator scl_intern_gen
     (
      .clk(clk),
      .rst_(rst_),
      .enable(!fsm_select_), //scl_generator always active when the Master module is active
      .scl_out(scl_intern)
      );
   
   always @ (*)
     begin
	case (current_state)
	  //============================================================================================================
	  IDLE :
	    if(!fsm_select_)
	      begin
		 if(reset_register == REG_RESET) // if the control register has the reset command
		   begin
		      sp_enable_d = 1'd0; //disable start_stop_generator.v
		      sp_rst_d = 1'd0; // activate reset from start_stop_generator.v   
		   end
		 else
		   begin
		      sp_rst_d = 1'd1; //disable the reset, preparing to launch the start signal
		      first_start_d = 1'd1; // this is the first start signal generated
		      sp_start_stop_d = 1'd1;
		      next_state = START; //send the start signal
		   end // else: !if(reset_register == REG_RESET)
	      end // if (!fsm_select_)
	    else
	      begin
		 next_state = IDLE;
	      end // else: !if(!fsm_select_)
	  //============================================================================================================
	  START :
	    if(first_start_ff) // if this is the first start signal
	      begin
		 sp_enable_d = 1'd1; // enable the generation of the first start
		 first_start_d = 1'd0;
		 sda_select_d = 1'd0; // Writing : sda_out line selected
		 next_state = SEND_SLAVE_ADDRESS;
	      end
	    else // if this is not the first start signal
	      begin
		 if(control_reg == REG_READ)
		   begin
		      sda_select_d = 1'd1; //select sda_in for reading
		      bit_count_d = 1'd0; // reset bit count
		      ack_d = 1'd0; // reset the ack bit
		      next_state = READ;
		   end
		 else
		   begin
		      if(control_reg == REG_WRITE)
			begin
			   sda_select_d = 1'd0; // select sda_out for writing
			   bit_count_d = 1'd0; // reset bit count
			   next_state = WRITE;
			end
		      else
			begin
			   next_state = START; // daca nu primeste nicio comanda valida, asteapta
			end
		   end // else: !if(control_reg == REG_READ)
	      end // else: !if(first_start_ff)
	  //============================================================================================================
	  SEND_SLAVE_ADDRESS :
	    if(bit_count_ff == 3'd7)
	      begin
		 bit_count_d = 3'd0; // reset bit_count value
		 sda_select_d = 1'd1; //selecteaza linia de sda_in pentru a primi ACK
		 send_slave_d = 1'd1; // the ACK_RECEIVE state will know that slave address was sent
		 sda_in_d = sda_in;
		 next_state = ACK_RECEIVE; // asteapta un tact semnalul ACK
	      end
	    else
	      begin
		 bit_count_d = bit_count_ff + 1;
		 sda_out_d = SLAVE_ADDRESS[bit_count_ff];
		 next_state = SEND_SLAVE_ADDRESS; 
	      end
	  //============================================================================================================
	  ACK_RECEIVE :
	    if(send_slave_ff) // if the slave address was sent
	      begin
		 if(sda_in_ff == 1'b0) // if we have ACK
		   begin
		      sda_select_d = 1'd1;
		      next_state = START;
		   end
		 else
		   begin
		      next_state = SEND_SLAVE_ADDRESS;
		   end
	      end // if (send_slave_ff)
	    else
	      begin
		 if(write_op_ff) // if the last operation was writing
		   begin
		      if(sda_in_ff == 1'b0) // if we have ACK
			begin
			   sda_select_d = 1'd1; // the sda_in line selected
			   sp_enable_d = 1'd1;
			   sp_start_stop_d = 1'd0;
			   next_state = STOP;
			end
		      else
			begin
			   next_state = WRITE; // if we don't have ACK, write again
			end
		   end // if (write_op_ff)
		 else
		   begin
		      next_state = IDLE;
		   end // else: !if(write_op_ff)
	      end // else: !if(send_slave_ff)
	  //============================================================================================================
	  WRITE :
	    if (bit_count_ff == 3'd7)
	      begin
		 sda_out_d = REG_WR1[bit_count_ff];
		 write_op_d = 1'd1;
		 send_slave_d = 1'd0;
		 bit_count_d = 1'd0;
		 next_state = ACK_RECEIVE;		 
	      end
	    else
	      begin
		 bit_count_d = bit_count_ff + 1;
		 sda_out_d = REG_WR1[bit_count_ff];
		 next_state = WRITE; 
	      end
	  //============================================================================================================
	  READ : 
 	    if (bit_count_ff == 3'd7)
	      begin
		 read_byte_d[bit_count_ff] = sda_in;
		 ack_d = read_byte_d[bit_count_ff] || ack_ff;
		 sda_select_d = 1'd0; // select sda_out for writing
		 next_state = SEND_ACK;
	      end
	    else
	      begin
		 bit_count_d = bit_count_ff + 1;
		 read_byte_d[bit_count_ff] = sda_in;
		 ack_d = byte_d[bit_count_ff] || ack_ff;
		 next_state = READ;
	      end
	  //============================================================================================================
	  SEND_ACK :
	    if(ack_ff)
	      begin
		 sda_out_d = 1'd0;
		 sda_select_d = 1'd0;
		 sp_start_stop_d = 1'd0;
		 next_state = STOP;
	      end
	    else
	      begin
		 sda_out_d = 1'd1;
		 bit_count_d = 1'd0;
		 ack_d = 1'd0;
		 next_state = READ;
	      end
	  //============================================================================================================
	  STOP :
 	    begin
	       sp_enable_d = 1'd1;
	       sp_start_stop_d = 1'd0;
	       next_state = IDLE;
	    end
	  //============================================================================================================
	  
	endcase // case (current_state)

     end // always @ (*)

   always @ (posedge scl_intern, negedge rst_)
     begin
	if(!rst_)
	  begin
	     scl_out <= scl_intern;   
	  end
	else
	  begin
	     sp_enable_ff <= sp_enable_d;
   	     sp_rst_ff <= sp_rst_d;
   	     sp_start_stop_ff <= sp_start_stop_d;
    	     sp_sda_out_ff <= sp_sda_out_d;
    	     sp_scl_out_ff sp_scl_out_d;
    	     first_start_ff <= first_start_d;
    	     bit_count_ff <= bit_count_d; 
    	     send_slave_ff <= send_slave_d;
    	     sda_in_ff <= sda_in_d;
    	     ack_ff <= ack_d;
	     read_byte_ff <= read_byte_d;
	     scl_out <= scl_intern;
	     current_state <= next_state;     
	  end
     end
endmodule
