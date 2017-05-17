module counter_param # 
  (
   parameter counter_width = 8,	//counter's width
   parameter reset_value = 'b0	//reset value
   )(
     input 			clk,
     input 			rst_, //asynchronous reset; active low
     input 			count_up,
     input 			clear, //synchronous reset; active high
     output [counter_width-1:0] couter_out
     );
   
   wire [counter_width-1:0] 	data;

   assign data = counter_out + { {(counter_width-1){1'b0}}, 1'b1};
   register_pipo_param #
     (
      .reg_width(counter_width),
      .reset_value(reset_value)
      ) counter_reg 
       (
	.clk(clk),
	.rst_(rst_),
	.reg_in(data),
	.load(count_up),
	.clear(clear),
	.reg_out(counter_out)
	);
endmodule