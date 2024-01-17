class driver;
  rand bit [7:0] a,b;
  rand bit signed_a, signed_b;
endclass

class monitor;
  static int count;
  function automatic void converter_fxp (input bit [7:0] A,B,Y, input bit int_a, int_b, signed_a, signed_b);
    int i = 0;
    int n = 0;
    real a_real = 0;
    real b_real = 0;
    real y_expected = 0;
    real y_actual = 0;
    bit signed_out;
    bit int_out;

    signed_out = (signed_a || signed_b);
    int_out = (int_a && int_b) ? 1 : 0;

    case({int_a,signed_a})
      2'b00:
      begin
        n = 1;
        a_real = (A[7] == 1'b1) ? 1 : 0;
        for (i = $bits(A)-2; i >= 0; i = i-1)
        begin
          a_real = (A[i] * 1/(real'(2**n))) + a_real;
          n = n + 1;
        end
      end
      2'b01:
      begin
        n = 1;
        a_real = (A[7] == 1'b1) ? -1 : 0;
        for (i = $bits(A) - 2; i >= 0; i = i-1)
        begin
          a_real = (A[i] * 1/(real'(2**n))) + a_real;
          n = n + 1;
        end
      end
      2'b10:
      begin
        a_real = real'(unsigned'(A));
      end
      2'b11:
      begin
        a_real = real'(signed'(A));
      end
    endcase

    case({int_b,signed_b})
      2'b00:
      begin
        n = 1;
        b_real = (B[7] == 1'b1) ? 1 : 0;
        for (i = $bits(B)-2; i >= 0; i = i-1)
        begin
          b_real = (B[i] * 1/(real'(2**n))) + b_real;
          n = n + 1;
        end
      end
      2'b01:
      begin
        n = 1;
        b_real = (B[7] == 1'b1) ? -1 : 0;
        for (i = $bits(B)-2; i >= 0; i = i-1)
        begin
          b_real = (B[i] * 1/(real'(2**n))) + b_real;
          n = n + 1;
        end
      end
      2'b10:
      begin
        b_real = real'(unsigned'(B));
      end
      2'b11:
      begin
        b_real = real'(signed'(B));
      end
    endcase

    case ({int_out, signed_out})
      2'b00:
      begin
        n = 1;
        y_actual = (Y[7] == 1'b1) ? 1 : 0;
        for (i = $bits(Y)-2; i >= 0; i = i-1)
        begin
          y_actual = (Y[i] * 1/(real'(2**n))) + y_actual;
          n = n + 1;
        end
      end
      2'b01:
      begin
        n = 1;
        y_actual = (Y[7] == 1'b1) ? -1 : 0;
        for (i = $bits(Y) - 2; i >= 0; i = i-1)
        begin
          y_actual = (Y[i] * 1/(real'(2**n))) + y_actual;
          n = n + 1;
        end
      end
      2'b10:
      begin
        y_actual = real'(unsigned'(Y));
      end
      2'b11:
      begin
        y_actual = real'(signed'(Y));
      end
    endcase

    y_expected = a_real * b_real;
    $display("test case %0d: a = %0f, b = %0f, y_actual = %0f, y_expected = %0f", count, a_real, b_real, y_actual, y_expected);
    count++;
    if (Y == 8'hFF || Y == 8'h7F || Y == 8'h80)
      $display("output saturated");
  endfunction
endclass

module multiplier_tb;
  logic [7:0] a,b;
  logic signed_a, signed_b;
  logic int_a, int_b;
  logic [7:0] y;

  multiplier mult_1(.*);

  driver driver;
  monitor monitor;

  initial
  begin
    $dumpvars();
    $dumpfile("dump.vcd");
    driver = new();
    monitor = new();

    repeat(10)
    begin
      if (!driver.randomize())
        $error("randomization failed");
      a = driver.a;
      b = driver.b;
      signed_a = driver.signed_a;
      signed_b = driver.signed_b;
      int_a = 0;
      int_b = 0;
      #5;
      monitor.converter_fxp(a,b,y,int_a,int_b,signed_a,signed_b);
    end
    repeat(10)
    begin
      if (!driver.randomize())
        $error("randomization failed");
      a = driver.a;
      b = driver.b;
      signed_a = driver.signed_a;
      signed_b = driver.signed_b;
      int_a = 0;
      int_b = 1;
      #5;
      monitor.converter_fxp(a,b,y,int_a,int_b,signed_a,signed_b);
    end
    repeat(10)
    begin
      if (!driver.randomize())
        $error("randomization failed");
      a = driver.a;
      b = driver.b;
      signed_a = driver.signed_a;
      signed_b = driver.signed_b;
      int_a = 1;
      int_b = 0;
      #5;
      monitor.converter_fxp(a,b,y,int_a,int_b,signed_a,signed_b);
    end
    repeat(10)
    begin
      driver.randomize() with {a * b < 255;};
      a = driver.a;
      b = driver.b;
      signed_a = driver.signed_a;
      signed_b = driver.signed_b;
      int_a = 1;
      int_b = 1;
      #5;
      monitor.converter_fxp(a,b,y,int_a,int_b,signed_a,signed_b);
    end
    $stop;
  end
endmodule
