module m1
(
    input logic [31:0] x,
    input logic clk, rst_na,
    output logic [31:0] y
);

//registers
logic [31:0] x1,x2,x3,x4;
logic [31:0] y1,y2;

always_ff @(posedge clk, negedge rst_na) begin
    if (~rst_na) begin
        x1 <= 0;
        x2 <= 0;
        x3 <= 0;
        x4 <= 0;
        y1 <= 0;
        y2 <= 0;
    end
    else begin
        x1 <= x;
        x2 <= x1;
        x3 <= x2;
        x4 <= x3;
        y1 <= y;
        y2 <= y1;
    end
end

assign y = x1 - x2 + x3 + x4 + (y1>>>1) + (y2>>>2);
endmodule