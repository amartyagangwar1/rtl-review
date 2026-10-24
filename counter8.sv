/* 
Design specifications
- 8-bit unsigned counter.
- Positive-edge triggered.
- Synchronous, active-high reset.
- Increments by 1 when enabled.
- Holds its value when disabled.
- Wraps from 255 to 0.
- Reset takes priority over enable.
*/

`timescale 1 ns/1ps

module counter8 (
    input logic clk,
    input logic reset,
    input logic enable, 
    output logic [7:0] count
);

always_ff @(posedge clk) begin
    if (reset) 
      count <= 0; 
    else if (enable) begin
        if(count == 255)
            count <= 0;
        else 
            count <= count + 1;
    end
end

endmodule