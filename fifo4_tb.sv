`timescale 1ns/1ps

module fifo4_tb;

logic clk;
logic reset;
logic wr_en;
logic rd_en;
logic [7:0] data_in;
logic [7:0] data_out;
logic full;
logic empty;

//test
logic [7:0] i;

fifo4 dut(.clk(clk),
           .reset(reset),
           .wr_en(wr_en),
           .rd_en(rd_en),
           .data_in(data_in),
           .data_out(data_out),
           .full(full),
           .empty(empty));

initial clk = 0;
always #5 clk = ~clk;

initial begin
    
//----------------------------------test reset----------------------------------
    @ (negedge clk);
    reset = 1;
    i = 10;
    wr_en = 0;
    rd_en = 0;
    data_in = 0;

    @ (negedge clk);
    reset = 0;
    
    repeat (4) begin
        @ (negedge clk);
        wr_en = 1;
        data_in = i;
        i = i + 10;
    end

    @ (posedge clk);
    #1;
    if(~full) 
        $fatal(1, "Error in fill"); 
        

    @ (negedge clk);
    wr_en = 0;
    rd_en = 1;

    @ (posedge clk);
    #1;
    if(data_out !== 10) 
        $fatal(1, "Error in fill");
    //$display("%0d", data_out); //ensure intended values are stored

    @ (negedge clk);
    reset = 1;
    i=0;

    @ (posedge clk);
    #1;
    reset=0;
    if(empty) 
        $display("RESET Test PASS");
    else
        $fatal(1, "Error in reset");
    


//----------------------------------test read----------------------------------
    @ (negedge clk);
    rd_en = 0;
    i = 10;

    repeat (3) begin
        @ (negedge clk); 
        wr_en = 1;
        data_in = i;
        i = i + 10;
    end

    @ (negedge clk);
    wr_en = 0;
    rd_en = 1;
    i = 10;

    repeat (3) begin
        @ (posedge clk);
        #1;
        if(data_out !== i) begin
            $fatal(1, "Data out value does not match input, input %0d vs output %0d", i, data_out);
        end
        i <= i + 10;
    end
    if(~empty)
        $fatal(1, "READ did not properly set empty");
    $display("READ Test PASS");



//----------------------------------test simultaneous read and write----------------------------------
    @ (negedge clk);
    reset = 1;
    wr_en = 0;
    rd_en = 0;
    data_in = 0;
    i = 10;

    @ (negedge clk);
    reset = 0;

    // Fill the FIFO with three values
    repeat (3) begin
        @ (negedge clk);
        wr_en = 1;
        data_in = i;
        i = i + 10;
    end

    @ (posedge clk);
    #1;
    if (dut.count !== 3 || dut.rd_loc !== 0 || dut.wr_loc !== 3 || empty || full) begin
        $fatal(1, "Error in simultaneous read/write setup");
    end

    // Read the oldest value and write a new value in the same cycle
    @ (negedge clk);
    rd_en = 1;
    data_in = 40;

    @ (posedge clk);
    #1;
    if (data_out !== 10)
        $fatal(1, "Simultaneous read returned %0d instead of 10", data_out);

    if (dut.count !== 3)
        $fatal(1, "Simultaneous read/write changed count; expected 3, got %0d",
               dut.count);

    if (dut.rd_loc !== 1)
        $fatal(1, "Read location should be 1, got %0d", dut.rd_loc);

    if (dut.wr_loc !== 0)
        $fatal(1, "Write location should wrap to 0, got %0d", dut.wr_loc);

    if (empty || full)
        $fatal(1, "FIFO flags are incorrect after simultaneous read/write");

    @ (negedge clk);
    wr_en = 0;
    rd_en = 0;
    $display("SIMULTANEOUS READ/WRITE Test PASS");



//----------------------------------test overflow----------------------------------
    @ (negedge clk);
    reset = 1;
    i = 10;
    wr_en = 0;
    rd_en = 0;
    data_in = 0;

    @ (negedge clk);
    reset = 0;
    
    repeat (4) begin
        @ (negedge clk);
        wr_en = 1;
        data_in = i;
        i = i + 10;
    end

    @ (negedge clk);
    wr_en = 0;

    @ (posedge clk); 
    if(dut.count !== 4 || dut.rd_loc !== 0 || dut.wr_loc !== 0 || ~full) begin   
        $fatal(1, "Error in fill");
    end

    @ (negedge clk);
    data_in = 'x;
    wr_en = 1;

    @ (negedge clk);
    wr_en = 0;
    rd_en = 1;
    i = 10;
    if(~full) begin
        $fatal(1, "Error in full flag logic");
    end

    repeat (4) begin
        @ (posedge clk);
        #1;
        if(data_out !== i) begin
            $fatal(1, "Error in overflow logic");
        end  
        i = i +10;
    end
    $display("OVERFLOW Test PASS");
        


//----------------------------------test pointer wraparound----------------------------------
    @ (negedge clk);
    reset = 1;
    wr_en = 0;
    rd_en = 0;
    data_in = 0;

    @ (posedge clk);
    @ (negedge clk);
    reset = 0;

    // Fill the FIFO with four values
    wr_en = 1;
    data_in = 10;
    @ (negedge clk);
    data_in = 20;
    @ (negedge clk);
    data_in = 30;
    @ (negedge clk);
    data_in = 40;

    @ (posedge clk);
    #1;
    if (dut.count !== 4 || dut.rd_loc !== 0 || dut.wr_loc !== 0 || !full || empty) begin
        $fatal(1, "Pointer wraparound fill state is incorrect");
    end

    // Read 10
    @ (negedge clk);
    wr_en = 0;
    rd_en = 1;

    @ (posedge clk);
    #1;
    if (data_out !== 10 || dut.count !== 3 || dut.rd_loc !== 1 ||
        dut.wr_loc !== 0 || empty || full) begin
        $fatal(1, "Pointer wraparound state is incorrect after reading 10");
    end

    // Read 20
    @ (posedge clk);
    #1;
    if (data_out !== 20 || dut.count !== 2 || dut.rd_loc !== 2 ||
        dut.wr_loc !== 0 || empty || full) begin
        $fatal(1, "Pointer wraparound state is incorrect after reading 20");
    end

    // Write 50
    @ (negedge clk);
    rd_en = 0;
    wr_en = 1;
    data_in = 50;

    @ (posedge clk);
    #1;
    if (dut.count !== 3 || dut.rd_loc !== 2 || dut.wr_loc !== 1 ||
        empty || full) begin
        $fatal(1, "Pointer wraparound state is incorrect after writing 50");
    end

    // Write 60
    @ (negedge clk);
    data_in = 60;

    @ (posedge clk);
    #1;
    if (dut.count !== 4 || dut.rd_loc !== 2 || dut.wr_loc !== 2 ||
        !full || empty) begin
        $fatal(1, "Pointer wraparound state is incorrect after writing 60");
    end

    // Read 30
    @ (negedge clk);
    wr_en = 0;
    rd_en = 1;

    @ (posedge clk);
    #1;
    if (data_out !== 30 || dut.count !== 3 || dut.rd_loc !== 3 ||
        dut.wr_loc !== 2 || empty || full) begin
        $fatal(1, "Pointer wraparound state is incorrect after reading 30");
    end

    // Read 40 and verify rd_loc wraps from 3 to 0
    @ (posedge clk);
    #1;
    if (data_out !== 40 || dut.count !== 2 || dut.rd_loc !== 0 ||
        dut.wr_loc !== 2 || empty || full) begin
        $fatal(1, "Read location did not wrap from 3 to 0 after reading 40");
    end

    // Read 50
    @ (posedge clk);
    #1;
    if (data_out !== 50 || dut.count !== 1 || dut.rd_loc !== 1 ||
        dut.wr_loc !== 2 || empty || full) begin
        $fatal(1, "Pointer wraparound state is incorrect after reading 50");
    end

    @ (negedge clk);
    wr_en = 0;
    rd_en = 0;
    $display("POINTER WRAPAROUND Test PASS");



//----------------------------------test underflow----------------------------------
    // Reset FIFO
    @ (negedge clk);
    reset = 1;
    wr_en = 0;
    rd_en = 0;
    data_in = 0;

    // Write one value
    @ (negedge clk);
    reset = 0;
    wr_en = 1;
    data_in = 10;

    @ (posedge clk);
    #1;

    // Read the value
    @ (negedge clk);
    wr_en = 0;
    rd_en = 1;

    @ (posedge clk);
    #1;
    if (data_out !== 10)
        $fatal(1, "Underflow setup read failed");

    if (!empty)
        $fatal(1, "FIFO should be empty after reading its only value");

    if (dut.count !== 0)
        $fatal(1, "Count should be 0 after reading, got %0d", dut.count);

    if (dut.rd_loc !== 1)
        $fatal(1, "Read location should be 1 after reading, got %0d",
               dut.rd_loc);

    if (dut.wr_loc !== 1)
        $fatal(1, "Write location should remain 1, got %0d",
               dut.wr_loc);

    // Attempt to read while empty
    @ (posedge clk);
    #1;
    if (data_out !== 10)
        $fatal(1, "Underflow changed data_out");

    if (!empty)
        $fatal(1, "FIFO should remain empty after underflow");

    if (dut.count !== 0)
        $fatal(1, "Underflow changed count; expected 0, got %0d",
               dut.count);

    if (dut.rd_loc !== 1)
        $fatal(1, "Underflow changed read location; expected 1, got %0d",
               dut.rd_loc);

    if (dut.wr_loc !== 1)
        $fatal(1, "Underflow changed write location; expected 1, got %0d",
               dut.wr_loc);

    $display("UNDERFLOW Test PASS");



    $finish;
end
endmodule