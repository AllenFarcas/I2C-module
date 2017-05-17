module register_piso_param #
  (
   parameter reg_width = 8, //register's width
   parameter reset_value = 'b0
   )(
     input 		   clk,
     input 		   rst_,
     input [reg_width-1:0] reg_in,
     input 		   load,
     input 		   clear,
     output reg 	   reg_out
     );

   always @ (posedge clk, negedge rest_)
     if(!rst_)
       reg_out <= reset_value;
     else if (clear)
       reg_out <= reset_value;
     else if(load)
       begin
	  reg_out <= reg_in[reg_width-1];
	  reg_in <= {reg_in[reg_width-2:0],1'b0};
       end

endmodule