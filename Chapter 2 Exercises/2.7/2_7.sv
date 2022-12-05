module c1
(
    input logic [15:0] in,
    input logic clk, rst_na, sel_1_2, sel_3,
    output logic [15:0] out
);

//registers
logic [15:0] reg_a,reg_b,reg_out;

//wires
logic [15:0] mux_out_1, mux_out_2, mux_out_3;
logic [15:0] sum_out, sub_out;

always_ff @(posedge clk, negedge rst_na) begin
    if (~rst_na) begin
        reg_a <= 0;
        reg_b <= 0;
        reg_out <= 0;
    end
    else begin
        reg_a <= in;
        reg_b <= out;
        reg_out <= mux_out_3;
    end
end

assign mux_out_1 = (sel_1_2) ? reg_a : reg_b;
assign mux_out_2 = (sel_1_2) ? reg_b : reg_a;
assign mux_out_3 = (sel_3) ? sum_out : sub_out;
assign sum_out = mux_out_1 + mux_out_2;
assign sub_out = mux_out_1 - mux_out_2;
assign out = reg_out;
endmodule