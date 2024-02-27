class driver;
  rand bit [7:0] x,y,z;
endclass

class monitor;
  static real x_r,y_r,z_r,w_r,w_ra;
  function automatic void converter_fxp_Q1_7 (input bit [7:0] A);
    int n = 1;
    x_r = A[7] ? -1 : 0;
    for (int i = 6; i >= 0; i = i - 1)
    begin
      x_r = x_r + (A[i] * 1/(real'(2**n)));
      n = n + 1;
    end
  endfunction

  function automatic void converter_fxp_Q2_6 (input bit [7:0] A);
    int i = 0;
    int n = 1;
    y_r = A[7] ? -2 : 0;
    y_r = A[6] ? y_r + 1 : y_r;
    for (i = 5; i >= 0; i = i - 1)
    begin
      y_r = y_r + (A[i] * 1/(real'(2**n)));
      n = n + 1;
    end
  endfunction

  function automatic void converter_fxp_Q0_8 (input bit [7:0] A);
    int n = 1;
    z_r = 0;
    for (int i = 7; i >= 0; i = i - 1)
    begin
      z_r = z_r + (A[i] * 1/(real'(2**n)));
      n = n + 1;
    end
  endfunction

  function automatic void converter_fxp_Q5_14 (input bit [18:0] A);
    int n = 1;
    w_ra = 0;
    w_ra = A[18] ? -16 : 0;
    w_ra = A[17] ? w_ra + 8 : w_ra;
    w_ra = A[16] ? w_ra + 4 : w_ra;
    w_ra = A[15] ? w_ra + 2 : w_ra;
    w_ra = A[14] ? w_ra + 1 : w_ra;
    for (int i = 13; i >= 0; i = i - 1)
    begin
      w_ra = w_ra + (A[i] * 1/(real'(2**n)));
      n = n + 1;
      //$display("%0f",w_ra);
    end
  endfunction

  function automatic void calculate_result (input bit [7:0] A,B,C);
    converter_fxp_Q1_7(A);
    converter_fxp_Q2_6(B);
    converter_fxp_Q0_8(C);

    w_r = (x_r * y_r) + (y_r * z_r) + x_r + y_r + z_r;
  endfunction
endclass

module exercise_10_TB;
  logic signed [18:0] w_o;
  logic signed [7:0] x_i, y_i;
  logic [7:0] z_i;
  logic en_i, valid_o;
  bit clk_i, rst_i;
  real x_r, y_r, z_r, w_r;
  driver driver;
  monitor monitor;

  int i = 0;
  real output_expected [0:9];
  real output_actual [0:9];

  wn dut(.*);

  initial
    forever
      #5 clk_i = !clk_i;

  initial
  begin
    $dumpfile("dump.vcd");
    $dumpvars;

    driver = new();
    monitor = new();

    rst_i = 1'b1;
    repeat(2) @(negedge clk_i);
    rst_i = 0;
    repeat(2) @(negedge clk_i);
    en_i = 1;
    x_i = 8'b1000_0000; //results in -1.99609375, most negative case
    y_i = 8'b1000_0000;
    z_i = 8'b1111_1111;
    monitor.calculate_result(x_i,y_i,z_i);
    $display("x = %f, y= %f, z = %f, w = %f", monitor.x_r, monitor.y_r, monitor.z_r,monitor.w_r);

    @(negedge clk_i);
    en_i = 0;
    @(negedge clk_i);
    en_i = 1;
    x_i = 8'b0111_1111; //results in 7.918151855, most positive case
    y_i = 8'b0111_1111;
    z_i = 8'b1111_1111;
    monitor.calculate_result(x_i,y_i,z_i);
    $display("x = %f, y= %f, z = %f, w = %f", monitor.x_r, monitor.y_r, monitor.z_r,monitor.w_r);
    repeat(5) @(negedge clk_i)
    begin
      en_i = 0;
    end
    repeat (14) @(negedge clk_i) //just enough for ten inputs
    begin
      en_i = 1;
      assert(driver.randomize);
      x_i = driver.x;
      y_i = driver.y;
      z_i = driver.z;
      monitor.calculate_result(x_i,y_i,z_i);
      output_expected[i] = monitor.w_r;
      i = i + 1;
      if (valid_o)
      begin
        monitor.converter_fxp_Q5_14(w_o);
        output_actual[i-5] = monitor.w_ra;
      end
    end
    for (int j = 0; j < 10; j++)
    begin
      $display("expected output = %0f, acutal output = %0f", output_expected[j], output_actual[j]);
    end
    $stop;
  end
endmodule
