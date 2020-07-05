module top;

// Declare the DPI import function
import "DPI-C" function void hello(string str);

initial begin
  hello("Hello SystemVerilog") ;
end

endmodule
