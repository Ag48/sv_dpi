module test;

    import "DPI-C" context task c_main();

    initial begin
        c_main();  

        $finish(2);
    end  

//------------------------------------------------
// export 関数の宣言
//------------------------------------------------
 
    export "DPI-C" task read_byte;
    export "DPI-C" task write_byte;

//------------------------------------------------
// メモリ
//------------------------------------------------

    byte unsigned memory[int];  

//------------------------------------------------
// export 関数の定義
//------------------------------------------------

    task read_byte( input int unsigned addr, inout byte unsigned data );
        data = memory[addr];  

        $display("read_byte : addr = 0x%08h, data = 0x%02h", addr, data );
    endtask : read_byte  

    task write_byte( input int unsigned addr, input byte unsigned data );
        $display("write_word : addr = 0x%08h, data = 0x%02h", addr, data );
        memory[addr] = data;  

    endtask : write_byte

endmodule : test
