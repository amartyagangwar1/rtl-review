`timescale 1ns/1ps

module fifo4 (
    input logic clk,
    input logic reset,
    input logic wr_en,
    input logic rd_en,
    input logic [7:0] data_in,
    output logic [7:0] data_out,
    output logic full,
    output logic empty
);

    //internal variables (limited to within the module)
    logic [7:0] arr [3:0];
    logic [1:0] wr_loc, rd_loc;
    logic [2:0] count;

    always_ff @(posedge clk) begin
        if(reset) begin //reset
            wr_loc <= 2'd0;
            rd_loc <= 2'd0;
            count <= 3'd0;
            data_out <= 8'd0;
        end else begin
            if((wr_en && ~full) && (rd_en && ~empty))begin  //simultaneous read and write logic
                arr[wr_loc] <= data_in;
                wr_loc <= wr_loc + 1;
                data_out <= arr[rd_loc];
                rd_loc <= rd_loc + 1;
            end else if (wr_en && ~full) begin   //write logic
                arr[wr_loc] <= data_in;
                count <= count + 1;
                wr_loc <= wr_loc + 1;
            end else if (rd_en && ~empty) begin //read logic
                    data_out <= arr[rd_loc];
                    rd_loc <= rd_loc + 1;
                    count <= count -1;
            end
        end
    end

    //combinational logic to set full and empty flags
    assign full = (count == 3'd4);
    assign empty = (count == 3'd0);

endmodule