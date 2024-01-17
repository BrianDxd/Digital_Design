module multiplier (
    input logic signed [7:0] a,
    input logic signed [7:0] b,
    input logic signed_a,
    input logic signed_b,
    input logic int_a,
    input logic int_b,
    output logic signed [7:0] y
  );

  logic signed [17:0] mult_result;
  logic signed [8:0] a_temp, b_temp, y_w;
  logic [2:0] multiplier_mode;

  logic int_by_int, q_by_q, int_by_q;

  logic sign_result;
  logic signed_output;

  //these signals are used to determine how multiplication will be interpreted
  assign int_by_int = (int_a && int_b);
  assign int_by_q = ((int_a & ~int_b) || (~int_a && int_b)); //int_a,b = 0 means Q format
  assign q_by_q = (~int_a && ~int_b);
  assign multiplier_mode = {int_by_int, int_by_q, q_by_q};

  assign a_temp = (signed_a) ? {a[7], a} : {1'b0, a}; //sign extension
  assign b_temp = (signed_b) ? {b[7], b} : {1'b0, b};

  assign mult_result = a_temp * b_temp;
  assign sign_result = a_temp[8] ^ b_temp[8]; //used to make sure the output is within range
  assign signed_output = (signed_a || signed_b);

  assign y = (mult_result == 0) ? 8'd0 : y_w[8:1];

  always_comb
  begin
    y_w = 0;
    case(multiplier_mode)
      3'b100:
      begin // int by int
        case({sign_result,signed_output})
          2'b00:
            y_w[8:1] = (mult_result[17:8] == {10{1'b0}}) ? mult_result[7:0] : 8'b1111_1111; //as long as top 10 bits are zero it is within range
          2'b01:
            y_w[8:1] = (mult_result[17:7] == {11{1'b0}}) ? mult_result[7:0] : 8'b0111_1111; //top 11 bits (the sign bit is also zero) must be zero to be in range
          2'b10:
            y_w[8:1] = 9'b0001_0001; //this can never happen, the sign result cannot be one if the output isnt signed.
          2'b11:
            y_w[8:1] = (mult_result[17:7] == {11{1'b1}}) ? mult_result[7:0] : 8'b1000_0000; //top 11 bits must be one to be in range
        endcase
      end
      3'b010:
      begin // int by q
        case({sign_result,signed_output})
          2'b00:
            y_w[8:1] = (mult_result[17:8] == {10{1'b0}}) ? mult_result[7:0] : 8'b1111_1111;
          2'b01:
            y_w[8:1] = (mult_result[17:7] == {11{1'b0}}) ? mult_result[7:0] : 8'b0111_1111;
          2'b10:
            y_w[8:1] = 9'b0001_0001; //this can never happen
          2'b11:
            y_w[8:1] = (mult_result[17:7] == {11{1'b1}}) ? mult_result[7:0] : 8'b1000_0000;
        endcase
      end
      3'b001:
      begin //q by q
        case({sign_result,signed_output})
          2'b00:
            y_w = (mult_result[17:15] == {3{1'b0}}) ? mult_result[14:6] + 1 : 9'b1_1111_1111; //[14:7] is the answer, [6] is used to round. Here the top 3 bits must be zero. The top 4 bits are all sign bits.
          2'b01:
            y_w = (mult_result[17:14] == {4{1'b0}}) ? mult_result[14:6] + 1 : 9'b0_1111_1111; //top 3 bits must be zero, which is the same as the sign bit in this case
          2'b10:
            y_w = 9'b1_0001_0001; //this can never happen
          2'b11:
            y_w = (mult_result[17:14] == {4{1'b1}}) ? mult_result[14:6] + 1 : 9'b1_0000_0000; //top 3 bits must be 1, same as the sign bit
        endcase
      end
    endcase
  end
endmodule :
multiplier
