module shift_register_param #
  (
   parameter reg_width = 16, //register's width
   parameter reset_value = 'b0 //reset value
   )(
     input 			clk,
     input 			rst_, //asynchronous
     input 			shift_in, //shift in
     output reg [reg_width-1:0] shift_reg_out
     );

   always @ (posedge clk or negedge rst_)
     if (!rst_) 
       shift_reg_out <= reset_value;
     else 
       shift_reg_out <= {shift_in, shift_reg_out[3:1]};
endmodule 
