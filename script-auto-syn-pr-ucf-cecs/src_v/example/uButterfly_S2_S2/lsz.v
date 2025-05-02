`ifndef lsz
`define lsz

module lsz #(
    parameter BITWIDTH = 8,
    parameter LOGBITWIDTH = $clog2(BITWIDTH)
) (
    input wire [BITWIDTH-1:0] iGray, // input gray number
    output wire [BITWIDTH-1:0] oOneHot // output one-hot encoding
);

    // priority based
    wire [BITWIDTH-1:0] tc;

    genvar i;

    // temporal/thermometer coding
    assign tc[0] = ~iGray[0];
    generate
        for (i = 1; i < BITWIDTH; i = i + 1) begin
            assign tc[i] = tc[i-1] | ~iGray[i];
        end
    endgenerate

    // one hot coding
    assign oOneHot[0] = tc[0];
    generate
        for (i = 1; i < BITWIDTH; i = i + 1) begin
            assign oOneHot[i] = tc[i-1] ^ tc[i];
        end
    endgenerate

endmodule

`endif

