`timescale 1ns/1ps

module register8_tb;

    logic clk;
    logic reset;
    logic enable;
    logic [7:0] d;
    logic [7:0] q;

    register8 dut (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .d(d),
        .q(q)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    
    initial begin
        //-------------------------test 1-------------------------
        reset = 1;
        enable = 0;
        d = 8'd9;

        @(posedge clk);
        #1;

        if(q !== 8'd0) 
            $error("Test 1: Error: Q = %0d, expected value is 0", q);
        else 
            $display("Test 1: Correct Q = %0d", q);

        //-------------------------test 2-------------------------
        reset = 0;
        enable = 1;
        d = 8'd9;

        @ (posedge clk);
        #1;

        if(q !== 8'd9)
            $error("Test 2: Error: Q = %0d, expected value is 9", q);
        else   
            $display("Test 2: Correct Q = %0d", q);

        //-------------------------test 3-------------------------
        reset = 0;
        enable = 0;
        d = 9'd75;

        @ (posedge clk);
        #1;

        if(q == 8'd9)
            $display("Test 3: Correct Q = %0d", q);
        else   
            $error("Test 3: Error: Q = %0d, expected value is 9", q);

        //-------------------------test 4-------------------------
        reset = 1;
        enable = 1;
        d = 9'd42;

        @ (posedge clk);
        #1;

        if(q !== 9'd0)
            $error("Test 4: Error Q = %0d, expected value is 0", q);
        else
            $display("Test 4: Correct Q = %0d", q);
        

        $finish;  
    end

endmodule