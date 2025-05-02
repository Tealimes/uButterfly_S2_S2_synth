//By Alexander Peacock, undergrad at UCF ECE
//email: alexpeacock56ten@gmail.com
`ifndef uMUL_bi
`define uMUL_bi


module uMUL_bi #(
    parameter BITWIDTH = 8
) (
    input wire iClk,
    input wire iRstN,
    input wire iEn,
    input wire iA,
    input wire [BITWIDTH - 1: 0] iB, // iB is not sent in from an external, static buffer
    input wire iClr,
    output reg oMult
);

    wire [BITWIDTH-1:0] sobolSeqInv;
    wire [BITWIDTH-1:0] sobolSeq;
    wire andTop;
    wire andBot;
    wire iA_inv;
    assign iA_inv = ~iA;
    
    rng_sobol #(
        .BITWIDTH(BITWIDTH)
    ) u_rng_sobolTop (
        .iClk(iClk),
        .iRstN(iRstN),
        .iEn(iA_inv), 
        .iClr(iClr),
        .sobolSeq(sobolSeqInv)
    );

    rng_sobol #(
        .BITWIDTH(BITWIDTH)
    ) u_rng_sobolBot (
        .iClk(iClk),
        .iRstN(iRstN),
        .iEn(iA), 
        .iClr(iClr),
        .sobolSeq(sobolSeq)
    );

    assign andTop = iA_inv & ~(iB > sobolSeqInv);
    assign andBot = iA & (iB > sobolSeq);

    // output is a combinational logic
    always@(*) begin
        oMult <= andTop | andBot;
    end

endmodule

`endif


