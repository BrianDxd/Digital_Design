module SSD_2D
(
    input logic clk, rst,
    output logic [6:0] segment,
    output logic digit_sel
);

logic [26:0] counter_1s;
logic [20:0] digit_counter;
logic [7:0] hex_value;
logic [3:0] hex_value_digit;
logic [1:0] digit_sel_en;

assign one_sec_en = (counter_1s == 79999999) ? 1 : 0;
assign hex_value_digit = (digit_sel) ? hex_value[7:4] : hex_value[3:0];
assign digit_sel_en = digit_counter[20:19];

always_ff @(posedge clk, posedge rst) begin
    if (rst) 
    counter_1s <= 0;
    else 
    counter_1s <= (counter_1s == 79999999 ) ? 0 : counter_1s + 1; //1s
end

always_ff @(posedge clk, posedge rst) begin //add 1 to reg every 1 sec
    if (rst)
    hex_value <= 0;
    else
    hex_value <= (hex_value == 255) ? 0 : (one_sec_en) ? hex_value + 1 : hex_value;
end

always_ff @(posedge clk, posedge rst) begin
    if (rst)
    digit_counter <= 0;
    else
    digit_counter <= digit_counter + 1;
end

always_comb begin
    digit_sel = 0;
    case(digit_sel_en)
    2'b01: digit_sel = 0;
    2'b10: digit_sel = 1;
    endcase
end

always_comb begin
    segment = 0;
    case(hex_value_digit)
    4'h0: segment = 7'b1111110;
    4'h1: segment = 7'b0110000;
    4'h2: segment = 7'b1101101;
    4'h3: segment = 7'b1111001;
    4'h4: segment = 7'b0110011;
    4'h5: segment = 7'b1011011;
    4'h6: segment = 7'b1011111;
    4'h7: segment = 7'b1110000;
    4'h8: segment = 7'b1111111;
    4'h9: segment = 7'b1111011;
    4'hA: segment = 7'b1110111;
    4'hB: segment = 7'b0011111;
    4'hC: segment = 7'b1001110;
    4'hD: segment = 7'b0111101;
    4'hE: segment = 7'b1001111;
    4'hF: segment = 7'b1000111;
    endcase
end
endmodule