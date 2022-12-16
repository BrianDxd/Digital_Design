module accum
  (
    input logic [31:0] in1, in2,
    input logic clk, rst,
    output logic [39:0] out
  );
  
  //internal signals
  logic [39:0] acc0, acc1;
  
  always_ff @(posedge clk)
    begin
      if (rst) begin
        acc0 <= '0;
        acc1 <= '0;
      end
      else begin
        acc0 <= acc1 + in1;
        acc1 <= acc0 + in2;
        out <= acc0 + acc1;
      end
    end
endmodule     