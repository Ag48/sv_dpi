module tb_top;

  // import "DPI-C" context function int test();

  logic clk, rstz;
  logic req,gnt,trans,write,ready;
  logic [31:0] addr,wdata,rdata;
  master_bfm master (
    .clk, .rstz, .req, .gnt, .trans, .write,
    .addr, .wdata, .rdata, .ready
  );
  slave_bfm slave (
    .clk, .rstz, .trans, .write,
    .addr, .wdata, .rdata, .ready
  );
  task gen_clk;
    forever begin
      #50 clk <= ~clk;
    end
  endtask

  task gen_gnt;
    forever begin
      while(req!==1'b1) @(posedge clk);
      repeat (2) @(posedge clk);
      gnt <= 1'b1;
      @(posedge clk);
      gnt <= 1'b0;
      @(posedge clk);
    end
  endtask

  initial begin
    bit [31:0] this_rdata;
    $display("run start");
    clk  <= 1'b1;
    rstz <= 1'b1;
    gnt  <= 1'b0;
    #100 fork
           gen_clk;
           gen_gnt;
         join_none
    #20  rstz <= 1'b0;
    #100;
    -> master.go_e;
  end
endmodule
