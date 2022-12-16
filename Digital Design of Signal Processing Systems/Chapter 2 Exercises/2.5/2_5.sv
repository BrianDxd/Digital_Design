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

module device_under_test
(
    input logic [15:0] data,
    input logic [2:0] write_sel, rd_sel_1, rd_sel_2,
    input logic [1:0] alu_sel,
    input logic input_sel, rst_na, clk,
    output logic [15:0] out_1, out_2,
    output logic overflow, underflow
);

//reg file
logic [15:0] Reg_file [0:7];

//wires
logic [15:0] mux_out_1, mux_out_2, mux_out_3;
logic [15:0] ALU_out;
integer i;

always_ff @(posedge clk, negedge rst_na) begin
    if (~rst_na) begin
        for (i = 0; i < 8; i = i + 1) begin
            Reg_file[i] <= 0;
        end
    end
    else begin
        Reg_file[write_sel] <= mux_out_1;
    end
end

assign mux_out_1 = (input_sel) ? ALU_out : data;
assign mux_out_2 = Reg_file[rd_sel_2];
assign mux_out_3 = Reg_file[rd_sel_1];
assign out_1 = mux_out_2;
assign out_2 = mux_out_3;

ALU u1(.A(mux_out_2), .B(mux_out_3), .sel(alu_sel), .C(ALU_out), .overflow(overflow), .underflow(underflow));
endmodule