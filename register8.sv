`timescale 1ns/1ps

module register8 (
    input logic clk,
    input logic reset,
    input logic enable,
    input logic [7:0] d,
    output logic [7:0] q
);

always_ff @(posedge clk) begin
    if (reset)
        q<=8'd0;
    else if (enable)
        q<=d;
end

endmodule