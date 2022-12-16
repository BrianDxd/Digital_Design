module accumulators
(
    input logic [3:0] data,
    input logic clk,rst_a
);

//internal registers
logic [7:0] acc1,acc2,acc3;

always_ff @(posedge clk, posedge rst_a) begin
    if (rst_a) begin
        acc1 <= 0;
        acc2 <= 0;
        acc3 <= 0;
    end
    else begin
        acc1 <= acc1 + data;
        acc2 <= acc1 + acc2;
        acc3 <= acc1 + acc2 + acc3;
    end
end
endmodule