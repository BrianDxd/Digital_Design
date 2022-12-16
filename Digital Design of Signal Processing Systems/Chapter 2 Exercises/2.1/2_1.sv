module m1
  (
    input logic [2:0] in1,in2,
    input logic [1:0] sel,
    input logic clk, rst_n,
    output logic [6:0] out,
    output logic overflow
  );
  
  //intermediate signals
  
  logic [6:0] sum;
  logic [6:0] out_ff;
  logic [3:0] in1_4_bit, in2_4_bit;
  logic [3:0] in1_plus_in2;
  logic [3:0] mux_out;
  
  //multiplexer logic
  always_comb
    begin
      mux_out = '0;
      unique case(sel)
        2'b00: mux_out = in1_4_bit;
        2'b01: mux_out = in2_4_bit;
        2'b10: mux_out = in1_plus_in2;
      endcase
    end
  
  always_ff @(posedge clk,negedge rst_n)
    begin
      if (!rst_n)
        out_ff <= '0; 
      else
        out_ff <= sum;
    end
  
  assign in1_4_bit = {1'b0,in1};
  assign in2_4_bit = {1'b0,in2};
  assign in1_plus_in2 = in1 + in2;
  assign sum = mux_out + out_ff[5:0];
  assign overflow = out_ff[6];
  assign out = out_ff;
  
endmodule