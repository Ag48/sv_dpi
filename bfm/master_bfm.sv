module master_bfm (
  input  logic clk, rstz,
  output logic req,
  input  logic gnt,
  output logic trans,
  output logic write,
  output logic [31:0] addr,
  output logic [31:0] wdata,
  input  logic [31:0] rdata,
  input  logic ready
);
/// clk   ~~|_____|~~~~~|_____|~~~~~|_____|~~~~~|_____|~~~~~|_____|~~~~~
/// req   ________|~~~~~~~~~~~~~~~~~~~~~~~|_____________________________
/// gnt   ____________________|~~~~~~~~~~~|_____________________________
/// trans ________________________________|~~~~~~~~~~~~~~~~~~~~~~~|_____
/// write ________________________________|~~~~~~~~~~~~~~~~~~~~~~~|_____
/// wdata XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX_______________________XXXXXX
/// ready XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX___________|~~~~~~~~~~~XXXXXX

  class transaction;
    bit cmd_type;  /// 1:write, 0:read
    bit [31:0] addr;
    bit [31:0] data;
  endclass

  /// Define for DPI-C ////////////////////////////
  export "DPI-C" task write_issue;
  export "DPI-C" task read_issue;
  export "DPI-C" task wait_cycle;
  import "DPI-C" context task test();
  /////////////////////////////////////////////////
  typedef mailbox #(transaction) t_mbx;
  t_mbx mbx_trans_req;
  t_mbx mbx_trans_dat;
  t_mbx mbx_trans_end;
  event go_e;

  /// for export task (DPI-C)
  task write_issue(int unsigned this_addr, int unsigned this_data);
    transaction this_item;
    this_item = new;
    this_item.cmd_type = 1'b1;
    this_item.addr     = this_addr;
    this_item.data     = this_data;
    $display("[%0d] write cmd. addr=%08xh, data=%08xh",$time,this_addr,this_data);
    mbx_trans_req.put(this_item);
    mbx_trans_end.get(this_item);
  endtask

  task read_issue(int unsigned this_addr);
    transaction this_item;
    bit [31:0] this_data;
    this_item = new;
    this_item.cmd_type = 1'b0;
    this_item.addr     = this_addr;
    $display("[%0d] read  cmd. addr=%08xh",$time,this_addr);
    mbx_trans_req.put(this_item);
    mbx_trans_end.get(this_item);
    this_data = this_item.data;
    $display("[%0d] read data. data=%08xh",$time,this_data);
  endtask

  task wait_cycle(int val);
    repeat (val) @(posedge clk);
  endtask

  /// for internal task (Driver)
  task req_driver;
    transaction this_item;
    forever begin
      mbx_trans_req.get(this_item);
      @(posedge clk);
      req <= 1'b1;
      @(posedge clk);
      while(gnt!==1'b1) @(posedge clk);
      req <= 1'b0;
      mbx_trans_dat.put(this_item);
    end
  endtask

  task dat_driver;
    transaction this_item;
    forever begin
      mbx_trans_dat.get(this_item);
      trans <= 1'b1;
      write <= this_item.cmd_type;
      addr  <= this_item.addr;
      if(this_item.cmd_type==1'b1)begin
        wdata <= this_item.data;
        //$display("[%0d]a write=%b", $time, write);
      end
      while(ready===1'b0) @(posedge clk);
      if(this_item.cmd_type==1'b0)begin
        this_item.data = rdata;
      end
      trans <= 1'b0;
      mbx_trans_end.put(this_item);
    end
  endtask

  task bus_reset;
    req   <= 1'b0;
    trans <= 1'b0;
    write <= 1'b0;
    addr  <= 32'h0000_0000;
    wdata <= 32'h0000_0000;
  endtask

  initial begin
    mbx_trans_req = new;
    mbx_trans_dat = new;
    mbx_trans_end = new;
    wait(rstz===1'b1);
    bus_reset;
    wait(rstz===1'b0);
    @(posedge clk);
    fork
      req_driver;
      dat_driver;
    join_none
  end

  initial begin
    @go_e;
    test();
    $finish;
  end

endmodule
