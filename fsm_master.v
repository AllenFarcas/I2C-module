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

   localparam IDLE = 'd1;

   //Registrii de control
   localparam REG_READ = 8'10101010;
   localparam REG_WRITE = 8'01010101;
   localparam REG_RESET = 8'11001100; // valoarea de reset

   //Registrii de scriere
   localparam REG_WR1 = 8'01010111;
   localparam REG_WR2 = 8'11101010;

   //Adresa Slave
   localparam SLAVE_ADDRESS = 7'b1011010;

   reg [3:0]  current_state;
   reg [3:0]  next_state;

   reg 	      sp_enable_ff;
   reg 	      sp_rst_ff;
   reg 	      sp_start_stop_ff;
   reg 	      sp_sda_out_ff;
   reg 	      sp_ending_ff;
   reg 	      sp_scl_out_ff;
   reg 	      first_start_ff;
   
   reg 	      sp_enable_d;
   reg 	      sp_rst_d;
   reg 	      sp_start_stop_d;
   reg 	      sp_sda_out_d;
   reg 	      sp_ending_d;
   reg 	      sp_scl_out_d;
   reg 	      first_start_d;
   
   
   wire       scl_intern;
   
   //Instantiate modules
   start_stop_generator s_p
     (
      .enable(sp_enable_ff),
      .scl_in(scl_intern),
      .rst_(sp_rst_ff),
      .start_stop(sp_start_stop_ff),
      .sda_out(sp_sda_out_ff),
      .ending(sp_ending_ff),
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
		      first_start_d = 1'd1 // this is the first start signal generated
		      next_state = START; //send the start signal
		   end // else: !if(reset_register == REG_RESET)
	      end // if (!fsm_select_)
	    else
	      begin
		 next_state = IDLE;
	      end // else: !if(!fsm_select_)

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
		 sp_enable_d = 1'd1; // generate the start for the next operation
		 if(control_reg == REG_READ)
		   begin
		      next_state = READ;
		   end
		 else
		   begin
		      if(control_reg == REG_WRITE)
			begin
			   next_state = WRITE;
			end
		      else
			begin
			   next_state = START; // daca nu primeste nicio comanda valida, asteapta
			end
		   end // else: !if(control_reg == REG_READ)
	      end // else: !if(first_start_ff)

	  SEND_SLAVE_ADDRESS :
	    if(bit_count_ff == 3'd7)
	      begin
		 bit_count_d = 3'd0;
		 next_state = ACK_RECEIVE;
		 
	      end
	    else
	      begin
		 bit_count_d = bit_count_ff + 1;
		 sda_out_d = SLAVE_ADDRESS[bit_count_ff];
		 next_state = SEND_SLAVE_ADDRESS;
		 
	      end
	       
	  endcase
     end
   
endmodule
