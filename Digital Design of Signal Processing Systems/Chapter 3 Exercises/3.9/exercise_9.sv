module iir_filter
  (
    input logic signed [7:0] d_in,
    input logic clk_i,
    input logic rst_i,
    input logic en_i,
    output logic signed [7:0] result_o,
    output logic valid_o,
    output logic busy_o
  );

  typedef enum {S0,S1,S2,S3} state_type;

  state_type state;

  localparam b0 = 9'b1_1000_0010; // -0.9821(approximate)

  logic signed [17:0] mult_result;
  logic signed [9:0] y_temp;
  logic signed [8:0] mult_final;
  logic signed [7:0] d_in_r;
  logic signed [7:0] y_curr, y_prev;
  logic sign_result_mult;
  logic out_of_range_possible;
  logic sign_addition;
  logic valid_r;

  assign busy_o = (state == S1 || state == S2 || state == S3);
  assign valid_o = valid_r;
  assign y_prev = y_curr;
  assign result_o = y_curr;

  always_ff @(posedge clk_i)
  begin
    if (rst_i)
    begin
      y_curr <= 0;
      valid_r <= 0;
    end
    else
    begin
      case(state)
        S0:
        begin
          if (en_i && !busy_o)
          begin
            d_in_r <= d_in;
            mult_result <= y_prev * $signed(b0);
            sign_result_mult <= (!y_prev) ? 0 : y_prev[7] ^ b0[7]; //calculate sign to check for overflow later
            valid_r <= 1'b0;
            state <= S1;
          end
        end
        S1:
        begin
          mult_final <= (mult_result[17:14] == {4{sign_result_mult}}) ? mult_result[14:6] + 1 : (sign_result_mult && !mult_result[14]) ? 9'b1_0000_0000 : 9'b0_1111_1111; //overflow checking
          state <= S2;
        end
        S2:
        begin
          y_temp <= mult_final[8:1] + d_in_r; //mult_final [8:1] is sign bit plus 7 fractional, mult_final[0] is a rounding bit
          out_of_range_possible <= (mult_final[8] == d_in_r[7]) ? 1 : 0; //in addition, can only over/underflow if sign bits are the same
          sign_addition <= mult_final[8];
          state <= S3;
        end
        S3:
        begin
          y_curr <= (out_of_range_possible && sign_addition && y_temp[9:8] != 2'b11) ? 8'b1000_0000 : (out_of_range_possible && !sign_addition && y_temp[9:8] != 2'b00) ? 8'b0111_1111 : y_temp[7:0]; //final output
          valid_r <= 1'b1;
          state <= S0;
        end
      endcase
    end
  end
endmodule
