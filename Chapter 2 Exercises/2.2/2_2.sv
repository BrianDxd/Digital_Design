module ALU
  (
    input logic signed [15:0] A,B,
    input logic [1:0] sel,
    output logic signed [15:0] C,
    output logic overflow,
    output logic underflow
  );

  logic signed [15:0] a_plus_b;
  logic signed [15:0] a_minus_b;
  logic signed [15:0] a_and_b;
  logic signed [15:0] a_or_b;
  logic overflow_add, underflow_add, overflow_minus;
  logic extra_bit_add, extra_bit_minus;
  always_comb begin
    C = '0;
    overflow = 0;
    underflow = 0;
    case(sel)
      2'b00: begin 
        C = a_plus_b;
        overflow = overflow_add;
        underflow = underflow_add;
      end
      2'b01: begin
        C = a_minus_b;
        overflow = overflow_minus;
      end
      2'b10: C = a_and_b;
      2'b11: C = a_or_b;
    endcase
  end
  
  //logic for addition
  
  always_comb
    begin
      {extra_bit_add, a_plus_b} = {A[15], A} + {B[15], B};
      overflow_add = ({extra_bit_add, a_plus_b[15]} == 2'b01);
      underflow_add = ({extra_bit_add, a_plus_b[15]} == 2'b10);
    end
  
  //logic for subtraction
  
  always_comb
    begin
      {extra_bit_minus, a_minus_b} = {A[15], A} - {B[15], B};
      overflow_minus = ({extra_bit_minus, a_minus_b[15]} == 2'b01);
    end
  
  assign a_and_b = A&B;
  assign a_or_b = A|B;
endmodule