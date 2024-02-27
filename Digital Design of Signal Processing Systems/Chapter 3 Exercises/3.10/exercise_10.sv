//xn = q1.7
//yn = q2.6
//zn = q0.8
//wn = xn*yn + yn*zn + xn + yn + zn
//   = q3.13 + q2.14 + q1.7 + q2.6 + q0.8 = (q5.14) sign bit included in integer part
//   = 0        1      0     1    0 = 2
//   = 2       -2     -1    -2    0 = -3
//s1 xn*yn = out1, yn*zn = out2, xn+yn = out3
//s2 out1 + out2 = out4, out3 + zn = out5
//s3 out4 + out5
//s4 check overflow, output
module wn
  (
    input logic signed [7:0] x_i,
    input logic signed [7:0] y_i,
    input logic [7:0] z_i,
    input logic en_i,
    input logic clk_i,
    input logic rst_i,
    output logic signed [18:0] w_o,
    output logic valid_o
  );

  logic signed [18:0] w_temp;
  logic signed [18:0] xy_yz_add;
  logic signed [15:0] xy_mult;
  logic signed [16:0] yz_mult;
  logic signed [11:0] xy_z_add;
  logic        [11:0] z_reg_delay;
  logic signed [10:0] xy_add;
  logic signed [7:0] x_reg;
  logic signed [7:0] y_reg;
  logic        [7:0] z_reg;
  logic signed [3:0] valid_o_reg;
  logic first_input;

  assign valid_o = valid_o_reg[3];
  assign w_o = w_temp;

  always_ff @(posedge clk_i)
  begin
    if (rst_i)
      valid_o_reg <= 0;
    else
      valid_o_reg <= {valid_o_reg[2:0], en_i};
  end

  always_ff @(posedge clk_i)
  begin
    if (en_i)
    begin
      x_reg <= x_i;
      y_reg <= y_i;
      z_reg <= z_i;
    end
  end

  always_ff @(posedge clk_i)
  begin
    //S1
    xy_mult <= x_reg * y_reg; //q3.13
    yz_mult <= $signed({y_reg}) * $signed({1'd0, z_reg}); //q2.14 with extra sign bit
    xy_add <= {{2{x_reg[7]}}, x_reg, 1'd0} + {y_reg[7], y_reg, 2'd0}; //q3.8
    z_reg_delay <= {4'd0, z_reg}; //q4.8

    //S2
    xy_yz_add <= {{2{xy_mult[15]}}, xy_mult, 1'd0} + {{3{yz_mult[15]}}, yz_mult[15:0]}; //q5.14\
    xy_z_add <= {xy_add[10], xy_add} + z_reg_delay; //q4.8

    //S3
    w_temp <= xy_yz_add + {xy_z_add[11], xy_z_add, 6'd0}; //q5.14
  end
endmodule
