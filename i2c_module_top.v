module i2c_module_top
  (
   inout       sda,
   inout       scl,
   input       clk,
   input       rst_,
   input       select_,
   input [7:0] rst_reg,
   input [7:0] cntrl_reg
   );

   wire  sda_in;
   wire  sda_select_m, sda_select_s;
   wire  sda_select;
   wire  scl_in, scl_out;
   wire  sda_out_s, sda_out_m;
   wire  sda_out;

   assign scl = (!select_) ? scl_out : 'bz; // select_ = 1 -> scl_in is selected, SLAVE is activated
   assign scl_in = scl;

   assign sda = (!sda_select) ? sda_out : 'bz; // sda_select = 1 -> sda_out -> READ
   assign sda_in = sda;                       // sda_select = 0 -> sda_in -> WRITE

   always @ (posedge scl)
     begin
	if(select_)
	  begin
	     sda_select <= sda_select_s;
	     sda_out <= sda_out_s;
	  end
	else
	  begin
	     sda_select <= sda_select_m;
	     sda_out <= sda_out_s;
	  end
     end // always @ (posedge scl)
   
   
   fsm_master master
     (
      .rst_(rst_),
      .clk(clk),
      .sda_out(sda_out_m),
      .sda_in(sda_in),
      .scl_out(scl_out),
      .sda_select(sda_select_m),
      .fsm_select_(!select_),
      .reset_register(rst_reg),
      .control_reg(cntrl_reg)
      );
   
   fsm_slave slave
     (
      .rst_(rst_),
      .clk(clk),
      .sda_out(sda_out_s),
      .sda_in(sda_in),
      .scl_in(scl_in),
      .sda_select(sda_select_s),
      .fsm_select_(select_)
      );
endmodule
