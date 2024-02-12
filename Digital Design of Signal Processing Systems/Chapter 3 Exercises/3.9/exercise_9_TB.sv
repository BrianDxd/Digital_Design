module iir_filter_tb;
  logic signed [7:0] d_in;
  bit clk_i;
  bit rst_i;
  logic en_i;
  logic signed [7:0] result_o;
  logic valid_o;
  logic busy_o;

  int n = 0;
  int fd1, fd2;
  int data_1, data_2;

  iir_filter dut(.*);

  initial
    forever
      #5 clk_i = !clk_i;
  initial
  begin
    $dumpfile("dump.vcd");
    $dumpvars;

    fd1 = $fopen("impulseResponseRTL.txt", "w");

    rst_i = 1'b1;
    repeat(2) @(negedge clk_i);
    rst_i = 0;
    repeat(2) @(negedge clk_i);
    en_i = 1;
    d_in = 8'b0111_1111;
    @(negedge clk_i);
    d_in = 8'b0000_0000;
    repeat (350) @(negedge clk_i)
    begin
      if (valid_o)
      begin
        $fdisplay(fd1, "%0h", result_o);
      end
    end
    $fclose(fd1);

    fd1 = $fopen("impulseResponseRTL.txt", "r");
    fd2 = $fopen("impulseResponse.txt", "r");

    while (!$feof(fd1))
    begin
      void'($fscanf(fd1,"%h\n",data_1));
      void'($fscanf(fd2,"%h\n",data_2));
      if(data_1 != data_2)
      begin
        $display("output %0d -> expected: %0h actual: %0h", n, data_2, data_1);
        n = n + 1;
      end
      else if (data_1 == data_2)
      begin
        $display("output %0d: correct, %0h == %0h", n, data_1, data_2);
        n = n + 1;
      end
    end
    $stop;
  end
endmodule
