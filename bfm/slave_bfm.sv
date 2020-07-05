module slave_bfm (
  input  logic clk,rstz,
  input  logic trans,
  input  logic write,
  input  logic [31:0] addr,
  input  logic [31:0] wdata,
  output logic [31:0] rdata,
  output logic ready
);

 byte memory [int unsigned]; /// associative array

  function byte get_mem_data(logic [31:0] this_addr);
    if(memory.exists(this_addr))
      return(memory[this_addr]);
    else begin
      $display("[%0d] no written data. return random value...",$time);
      return($random);
    end
  endfunction
  task mem_access;
    byte wait_val;
    forever begin
      while(trans!==1'b1) @(posedge clk);
      wait_val = $urandom_range(0,3);
      repeat(wait_val) @(posedge clk);
      ready <= 1'b1;
      if(write===1'b1)begin
        memory[{addr[31:2],2'b00}] = wdata[7:0];
        memory[{addr[31:2],2'b01}] = wdata[15:8];
        memory[{addr[31:2],2'b10}] = wdata[23:16];
        memory[{addr[31:2],2'b11}] = wdata[31:24];
      end else begin
        rdata[7:0]   = get_mem_data({addr[31:2],2'b00});
        rdata[15:8]  = get_mem_data({addr[31:2],2'b01});
        rdata[23:16] = get_mem_data({addr[31:2],2'b10});
        rdata[31:24] = get_mem_data({addr[31:2],2'b11});
      end
      @(posedge clk);
      ready <= 1'b0;
      @(posedge clk);
    end
  endtask
  task reset_bus;
    rdata <= 32'h00000000;
    ready <= 1'b0;
  endtask
  initial begin
    reset_bus;
    wait(rstz===1'b1);
    mem_access;
  end
endmodule
