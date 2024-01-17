Answers to Questions

a: 1011_0011 b:1100_0101

(Q1.7)
UxU: 1.3984375 * 1.5390625 = 2.152282715
    (1+2^-2+2^-3+2^-6+2^-7)
UxS: 1.3984375 * -0.4609375 = -0.6445922852 (1.0101101)
SxU: -0.6015625 * 1.5390625= -0.9258422852 (1.0001001)
SxS = -0.6015625 * -0.4609375 = 0.2772827148 (0.0100011)

signed int: -77 * -59 = 4543

Signed Int x Q1.7 = -77 * -0.4609375 = 35.4921875


Explanation (relevant pages: 98-101, 108-110)
    The int values are twos complement numbers.

    The main idea of this problem is the same multiplier can be used to multiply different inputs, that are formatted as any combination of signed and unsigned 
int or Q1.7 numbers, and only the interpretation of those values changes. This is done through the extra sign bit that extends the inputs from 8 bits 
through nine bits. 

    These two nine by nine inputs are then multiplied to give a eightteen bit output.

    In the case of int by int, the bottom seven bits can be taken as the answer, as long as the sign bit of the bottom seven bits mult_result[7] is repeated from 
mult_result[17:8].(page 110) In the case of unsigned int by unsigned int, the mult_result[7] can be 1 or 0, but mult_result[17:8] must be zero. In all cases, this 
means that the multiplication result didn't overflow or underflow, depending on the sign bit. If overflow/underflow has occured, the output is set the largest positive 
or smallest negative number, depending on the output format.

    In the case of Q1.7 by Q1.7, the resulting format of the multplication result can be thought of as Q2.14. The bottom 7 bits are the result of the fraction
part of both numbers multiplied together, this means that they are out of our format range. The next 7 bits are the fraction bits of our result, 
then the next bit is the sign bit. So in the code, mult_result[6:0] represents fractional bits that are outside of our range. 
One is added to mult_result[6] to round off the number. the next 8 bits are the ones that we want, which is mult_result[14:7]. 
This, included with the rounding, is seen as mult_result[14:6] + 1 in the code. The mult_result is represented as such, in the case of signed output, with S standing for sign bit, and X being numbers that are too small to worry about, and F being the result of our answer, and R being the bit we add one to to round.

                                                    SSS_SFFFFFFF_RXXXXXXX

As before, if the output is unsigned, then the 4th S from the left can be a one or zero, but the top 3 S must be 0. 

In the case of Q1.7 by int, this circuit produces a Q format number. In Q1.7, the MSB represents the whole number. One can say that the int must be shifed left so that
last bit lines up with the MSB of the Q1.7 number, or the Q1.7 must be shifted right in order to line its MSB with the LSB of the int number. In this circuit, the
values are mulitplied directly, so the multiplication result must be shifted left as the MSB of the int lines up with the MSB of the Q format number. Of course, this
will just move the answer to higher bits, so the result can just be taken as the bottom 8 bits, same as the int by int case. The overflow/underflow can be checked with
the same rule as the int by int case.

Module Signals:
input logic signed [7:0] a,b: operand 1, operand 2
input logic signed_a, signed_b: tells whether an operand is to be interpreted as signed or unsigned
input logic int_a, int_b: when 1, the number is interpreted as int, when 0, the number is interpreted as a Q1.7 number
output logic signed [7:0] y: the result of the multiplication

Testbench

This circuit was tested on EDA playground using the Synopsys VCS simulator.

The test bench contains a function that converts the inputs to floating point values (real type), computes the expected output, and also converts the output from the 
circuit. The results are printed for easy comparison to check for errors.

Inputs are randomized, 10 for A = Q, B = Q, 10 for A = Q, B = int, 10 for A = int, B = Q, and 10 for A = int, B = int.