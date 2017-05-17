module register_sipo_param #
  (
   parameter reg_width = 8, // register's width
   parameter reset_value = 'b0
   )(
     input 			clk,
     input			rst_,
     input 			reg_in,
     input 			load,
     input 			clear,
     output reg [reg_width-1:0] reg_out
     );
   always @ (posedge clk, negedge rst_)
     if (!rst_)
       reg_out <= reset_value;
     else if (clear)
       reg_out <= reset_value;
     else if(load)
       reg_out <= {reg_in, reg_out[reg_width-2:1]};
endmodule 
