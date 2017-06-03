module fsm_slave
  (
   input      rst_,
   input      clk,
   input      sda_in,
   input      scl_in,
   input      fsm_select_,
   output reg write_read,
   output reg sda_out
   );

   localparam IDLE = 4'd0;
   localparam START = 4'd1;
   localparam READ_FIRST = 4'd2;
   localparam ADDRESS_COMPARATOR = 4'd3;
   localparam WRITE = 4'd4;
   localparam READ = 4'd5;
   localparam ACKNOWLEDGE = 4'd6;
   localparam ACK_READ = 4'd7;
   localparam ACK_CHECK = 4'd8;
   localparam STOP = 4'd9;
   
   //Slave address
   localparam SLAVE_ADDRESS = 7'b1011010;

   //Write register
   localparam WRITE_REG = 8'b00101010;
   
   
   reg [3:0]  current_state;
   reg [3:0]  next_state; 

   reg 	      sda_out_d;
   reg 	      sda_select_d;
   reg 	      write_read_d;

   reg 	      select_start_d;
   reg 	      select_stop_d;
   reg 	      ack_d;
   reg [2:0]  bit_count_d;
   reg [7:0]  first_bits_d;
   reg [7:0]  byte_d;
   
   
   
   wire       start_bit;
   wire       stop_bit;
   reg 	      select_start_ff;
   reg 	      select_stop_ff;
   reg 	      ack_ff;
   reg [2:0]  bit_count_ff;
   reg [7:0]  first_bits_ff;
   reg [7:0]  byte_ff;
   reg 	      start_bit_d;
   reg 	      stop_bit_d;
   
   
   start_detector startbit
     (
      .scl(scl_in),
      .enable(select_start_ff),
      .sda(sda_in),
      .clk(clk),
      .start(start_bit)
      );

   stop_detector stopbit
     (
      .scl(scl_in),
      .enable(select_stop_ff),
      .sda(sda_in),
      .clk(clk),
      .stop(stop_bit)
      );
   
   always @ (*)
     begin
	case (current_state) //dependent on the present state
	  IDLE :
	    if(fsm_select_)
	      begin
		 stop_bit_d = 1'd0;
                 start_bit_d = 1'd0;
		 select_start_d = 1'd1;
		 ack_d = 1'd0;
		 bit_count_d = 3'd0;
		 byte_d = 8'dz;
		 first_bits_d = 8'dz;
		 next_state = START;
	      end
	    else
	      begin
		 next_state = IDLE;
	      end
	  
	  START :
	    if(start_bit_d)
	      begin
		 ack_d = 1'd0;
		 select_start_d = 1'd0;
		 next_state = READ_FIRST;
	      end
	    else
	      begin
		 next_state = START;
	      end

	  READ_FIRST :
	    if(bit_count_ff == 3'd7)
	      begin
		 first_bits_d[bit_count_ff] = sda_in;
		 ack_d = first_bits_d[bit_count_ff] || ack_ff;
		 write_read_d = 1'd0;
		 bit_count_d = 1'd0;
		 next_state = ACKNOWLEDGE;
	      end
	    else
	      begin
		 start_bit_d = 1'd0;
		 first_bits_d[bit_count_ff] = sda_in;
		 bit_count_d = bit_count_ff + 1;
		 ack_d = first_bits_d[bit_count_ff] || ack_ff;
		 next_state = READ_FIRST;
	      end

	  ACKNOWLEDGE :
	    if (ack_ff == 1'd1)
	      begin
		 sda_out_d = 1'd0;
		 ack_d = 1'd0;
		 next_state = ADDRESS_COMPARATOR;
	      end
	    else
	      begin
		 sda_out_d = 1'd1;
		 write_read_d = 1'd1;
		 next_state = IDLE;
	      end // else: !if(ack == 1'd1)
	  
	  ADDRESS_COMPARATOR :
	    if(first_bits_ff[7:1] == SLAVE_ADDRESS)
	      begin
		 if(first_bits_ff[0])
		   begin
		      write_read_d = 1'd1;
		      bit_count_d = 1'd0;
		      next_state = READ;
		   end
		 else
		   begin
		      write_read_d = 1'd0;
		      bit_count_d = 1'd0;
		      next_state = WRITE;
		   end
	      end // if (first_bits_ff[7:1] == SLAVE_ADDRESS)
	    else
	      begin
		 write_read_d = 1'd1;
		 bit_count_d = 1'd0;
		 next_state = IDLE;
	      end // else: !if(first_bits_ff[7:1] == SLAVE_ADDRESS)
	  
	  READ :
	    if (bit_count_ff == 3'd7)
	      begin
		 ack_d = byte_d[bit_count_ff] || ack_ff;
		 byte_d[bit_count_ff] = sda_in;
		 write_read_d = 1'd0;
		 bit_count_d = 1'd0;
		 next_state = ACK_READ;
	      end
	    else
	      begin
		 byte_d[bit_count_ff] = sda_in;
		 bit_count_d = bit_count_ff + 1;
		 ack_d = byte_d[bit_count_ff] || ack_ff;
		 next_state = READ;
	      end // else: !if(bit_count_ff == 1'd7)

	  ACK_READ :
	    if(ack_ff == 1'd1)
	      begin
		 sda_out_d = 1'd0;
		 select_stop_d = 1'd1;
		 next_state = STOP;
	      end
	    else
	      begin
		 sda_out_d = 1'd1;
		 write_read_d = 1'd1;
		 ack_d = 1'd0;
		 next_state = IDLE;
	      end // else: !if(ack_ff == 1'd1)

	  WRITE :
	    if (bit_count_ff == 3'd7)
	      begin
		 write_read_d = 1'd1;
		 bit_count_d = 1'd0;
		 next_state = ACK_CHECK;
	      end
	    else
	      begin
		 sda_out_d = WRITE_REG[bit_count_ff];
		 bit_count_d = bit_count_ff + 1;
		 next_state = WRITE;
	      end // else: !if(bit_count_ff == 1'd7)

	  ACK_CHECK :
	    if(sda_in)
	      begin
		 write_read_d = 1'd0;
		 next_state = WRITE;
	      end
	    else
	      begin
		 select_stop_d = 1'd1;
		 next_state = STOP;
	      end

	  STOP :
	    if(stop_bit_d)
	      begin
		 select_stop_d = 1'd0;
		 next_state = IDLE;
	      end
	    else
	      begin
		 select_stop_d = 1'd0;
		 select_start_d = 1'd1;
		 next_state = START;
	      end
	endcase
     end // always @ (*)
   
   always @ (posedge scl_in)
     begin
	if(!rst_)
	  begin
	     bit_count_d <= 3'd0;
	     write_read_d <= 1'd1;
	     first_bits_d <= 8'bz;
	     byte_d <= 8'bz;
	     select_start_d <= 1'd0;
	     select_stop_d <= 1'd0;
	     ack_d <= 1'd0;
	     current_state <= IDLE;
	  end
	else
	  begin
	     bit_count_ff <= bit_count_d;
	     write_read <= write_read_d;
	     select_start_ff <= select_start_d;
	     select_stop_ff <= select_stop_d;
   	     first_bits_ff <= first_bits_d;
	     byte_ff <= byte_d;
	     ack_ff <= ack_d;
	     sda_out <= sda_out_d;
	     current_state <= next_state;
	  end
     end // always @ (posedge scl_in, negedge rst_)

   always @ (posedge clk)
     begin
	if(start_bit)
	  start_bit_d <= 1'd1;
	if(stop_bit)
	  stop_bit_d <= 1'd1;
     end
endmodule
