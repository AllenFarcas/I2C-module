module register_pipo_param #
  (
   parameter reg_width = 16,	//register's width
   parameter reset_value = 'b0	//reset value
   )(
     input 			clk, 
     input 			rst_, //asynchronous reset; active low
     input [reg_width-1:0] 	reg_in, 
     input 			load, 
     input 			clear, //synchronous reset; active high
     output reg [reg_width-1:0] reg_out
     );

   always @ (posedge clk, negedge rst_)
     if (!rst_)
       reg_out <= reset_value;
     else if (clear)
       reg_out <= reset_value;
     else if (load)
       reg_out <= reg_in;
endmodule 