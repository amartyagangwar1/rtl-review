`timescale 1 ns/1ps

module counter8_tb;

logic clk;
logic reset;
logic enable;
logic [7:0] count;

counter8 dut(.clk(clk), .reset(reset), .enable(enable), .count(count));

initial clk = 0;
always #5 clk = ~clk;

initial begin
    reset = 0;
    enable =0;
    //-------------------test 1-------------------
    //counter reset test
    @ (negedge clk) //reset initial counter value
    reset = 1;
    @ (negedge clk); //turn reset off and let count up until 10
    reset = 0;
    enable = 1;
    
    repeat (10) @(posedge clk);
    #1;
    if(count === 10) 
        $display("Test 1 Initial Value: %0d", count);
    else
        $error("Test 1 ERROR, counting logic incorrect");
    @ (negedge clk) //test reset
        reset = 1;
        
    @ (posedge clk)
        #1;
        if(count !== 8'd0)
            $error("Test 1 ERROR: Count did not properly reset, %0d", count);
        else
            $display("Test 1 PASS: Count properly reset, %0d", count);


    //-------------------test 2-------------------
    //Verify counting
    @ (negedge clk); // reset count and let count up until 15
    reset = 1;
    enable = 0;

    @ (negedge clk);
    reset = 0;
    enable = 1;
    
    repeat (15) @(posedge clk);
    #1;
    if(count === 15) 
        $display("Test 2 PASS: %0d", count);
    else
        $error("Test 2 ERROR, counting logic incorrect");

    //-------------------test 3-------------------
    //enable hold
    @ (negedge clk); // reset count and let count up until 10 then hold value
    reset = 1;
    enable = 0;

    @ (negedge clk);
    reset = 0;
    enable = 1;
    
    repeat (10) @(posedge clk);
    #1;
    
    @ (negedge clk);
    enable = 0;

    repeat (10) @(posedge clk);
    #1;
    if(count === 10) 
        $display("Test 3 PASS: %0d", count);
    else
        $error("Test 3 ERROR, enable logic incorrect");

    //-------------------test 4-------------------
    //enable on test
    @ (negedge clk); // reset count and let count up until 10 then hold value
    reset = 1;
    enable = 0;

    @ (negedge clk);
    reset = 0;
    enable = 1;
    
    repeat (10) @(posedge clk);
    #1;
    
    @ (negedge clk);
        enable = 0;

    repeat (10) @(posedge clk);
    #1;
    if(count !== 10) 
        $error("Test 4 ERROR, enable logic incorrect");
    
    @ (negedge clk);
        enable = 1;
         
    repeat (10) @(posedge clk);
    #1;
    if(count !== 20)
        $error("Test 4 ERROR, enable logic incorrect");
    else 
        $display("Test 4 PASS, enable logic correct");

    //-------------------test 5-------------------
    //reset priority test
    @ (negedge clk); // reset count and let count up until 10 then hold value
        reset = 1;
        enable = 0;

    @ (negedge clk);
        reset = 0;
        enable = 1;

     repeat (10) @(posedge clk);
    #1;

    @ (negedge clk);
    reset = 1;
    enable = 1;
    
    @ (posedge clk);
    #1;
    if(count !== 0)
        $error("Test 5 ERROR, reset does not have priority");
    else
        $display("Test 5 PASS, reset priority is set properly");

    //-------------------test 6-------------------
    //wraparound test
    @ (negedge clk); // reset count and let count up until 255 then ensure it goes back to zero
        reset = 1;
        enable = 0;

    @ (negedge clk);
        reset = 0;
        enable = 1;

    repeat (255) @(posedge clk);
    #1;
    $display("Test 6, value is %0d, testing overflow", count);
    
    @ (posedge clk);
    #1;
    if(count !== 0)
        $error("Test 6 ERROR, wraparound did not function properly, %0d", count);
    else
        $display("Test 6 PASS, wraparound functional, %0d", count);

    $finish;
end
endmodule