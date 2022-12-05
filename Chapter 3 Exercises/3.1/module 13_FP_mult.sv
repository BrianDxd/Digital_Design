//tested for normalized inputs only, can produce denormalized outputs.

module FP_mult_13
(
    input logic [12:0] A,B,
    input logic start, rst_n, clk,
    output logic [12:0] Y,
    output logic overflow, underflow
);

typedef enum {S0, S1, S2, S3, S4, S5} state_type;

state_type state_reg, state_;

logic [17:0] A_mult_B;
logic [8:0] A_imp1, B_imp1, A_mult_B_trunc, A_mult_B_trunc2, A_mult_B_trunc3, A_mult_B_trunc4;
logic [7:0] A_mant, B_mant, Y_mant;
logic [4:0] AB_exp_sum, Y_exp_temp;
logic [3:0] A_exp, B_exp, Y_exp;
logic A_sign, B_sign, Y_sign, LT_seven;

always_ff @(posedge clk) begin //1
    if (~rst_n) begin
        state_reg = S0;
        Y = 0;
        overflow = 0;
        underflow = 0;
    end
    else begin //2
    Y_exp = 0;
    Y_mant = 0;
    case(state_reg)
    S0: begin
        if (start) begin
            AB_exp_sum = A_exp + B_exp;
            $display(AB_exp_sum);
            if (AB_exp_sum < 7 ) begin
                Y_exp_temp <= (~(AB_exp_sum - 7) + 1);
                LT_seven <= 1;
            end
            else begin
                Y_exp_temp <= AB_exp_sum - 7;
                LT_seven <= 0;
            end
            state_reg <= S1;
        end
    end
    S1: begin
        A_imp1 = (A_exp != 0) ? {1'b1, A_mant} : {1'b0, A_mant};
        B_imp1 = (B_exp != 0) ? {1'b1, B_mant} : {1'b0, B_mant};
        A_mult_B <= A_imp1 * B_imp1;
        Y_sign <= A_sign ^ B_sign;
        state_reg <= S2;
    end
    S2: begin
        case(A_mult_B[17:16])
        2'b11: begin
            Y_exp_temp <= (LT_seven) ? (Y_exp_temp - 1) : Y_exp_temp + 1;
            A_mult_B_trunc <= A_mult_B[16:8] + 1;
            state_reg <= (Y_exp_temp > 14 && Y_sign) ? S5 : (Y_exp_temp > 14 && ~Y_sign) ? S4 : S3;
        end
        2'b10: begin
            Y_exp_temp <= (LT_seven) ? (Y_exp_temp - 1) : Y_exp_temp + 1;
            A_mult_B_trunc <= A_mult_B[16:8] + 1;
            state_reg <= (Y_exp_temp > 14 && Y_sign) ? S5 : (Y_exp_temp > 14 && ~Y_sign) ? S4 : S3;
        end
        2'b01: begin
            Y_exp_temp <= Y_exp_temp;
            A_mult_B_trunc <= A_mult_B[15:7] + 1;
            state_reg <= (Y_exp_temp > 14 && Y_sign) ? S5 : (Y_exp_temp > 14 && ~Y_sign) ? S4 : S3;
        end
        2'b00: begin
            Y_exp_temp <= (LT_seven) ? Y_exp_temp + 1 : Y_exp_temp - 1;
            A_mult_B <= A_mult_B << 1;
            state_reg <= S2;
        end
        endcase
    end
    S3: begin
        if (LT_seven) begin
            A_mult_B_trunc2 = (Y_exp_temp[0]) ? {1'b0, A_mult_B_trunc[8:1]} : A_mult_B_trunc;
            A_mult_B_trunc3 = (Y_exp_temp[1]) ? {2'b00, A_mult_B_trunc2[8:2]} : A_mult_B_trunc2;
            A_mult_B_trunc4 = (Y_exp_temp[2]) ? {4'b0000, A_mult_B_trunc3[8:4]} : A_mult_B_trunc3;
            Y_mant = A_mult_B_trunc4[8:1];
            Y_exp = 0;
            Y = {Y_sign, Y_exp, Y_mant};
            underflow = 1;
            state_reg <= S0;
        end
        else begin
            if (Y_exp_temp > 14)
            state_reg <= (Y_sign) ? S5 : S4;
            else begin
                Y_exp = Y_exp_temp;
                Y_mant = A_mult_B_trunc[8:1];
                Y = {Y_sign, Y_exp, Y_mant};
                underflow = (Y_exp == 0) ? 1 : 0;
                state_reg <= S0;
            end
        end
    end
    S4: begin
        overflow = 1;
        Y = 13'b0111100000000;
        state_reg = S0;
    end
    S5: begin
        overflow = 1;
        Y = 13'b1111100000000;
        state_reg = S0;
    end
    endcase
    end
end

assign A_sign = A[12];
assign B_sign = B[12];
assign A_exp = A[11:8];
assign B_exp = B[11:8];
assign A_mant = A[7:0];
assign B_mant = B[7:0];
endmodule