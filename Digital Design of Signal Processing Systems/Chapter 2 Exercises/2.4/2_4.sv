module device_under_test
(
    input logic [7:0] in1,in2,in3,in4,
    input logic clk, rst,
    output logic [7:0] out1,out2
);

//internal registers
logic [7:0] R0, R1, R2, R3;

always_ff @(posedge clk) begin
    if (rst) begin 
        R0 <= 0;
        R1 <= 0;
        R2 <= 0;
        R3 <= 0;
    end
    else begin
        R0 <= in1;
        R1 <= in2;
        R2 <= in3;
        R3 <= in4;
    end
end

assign out1 = R0 + R1 + R2 + R3;
assign out2 = R0 & R1 & R2 & R3;
endmodule