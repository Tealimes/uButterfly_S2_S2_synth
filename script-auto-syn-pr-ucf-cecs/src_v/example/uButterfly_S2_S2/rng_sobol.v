`ifndef rng_sobol
`define rng_sobol

// this code implements m_i = 1 for dim1 in paper Algorithm 659: Implementing Sobol's quasirandom sequence generator
// https://dl.acm.org/doi/10.1145/42288.214372
// supported BITWIDTH are 2-10
module rng_sobol #(
    parameter BITWIDTH = 8
) (
    input wire iClk,    // Clock
    input wire iRstN,  // Asynchronous reset active low
    input wire iEn,
    input wire iClr,
    output wire [BITWIDTH-1:0]sobolSeq
);

    wire [BITWIDTH-1:0] cntNum;
    wire [BITWIDTH-1:0] oneHot;
    wire [BITWIDTH*BITWIDTH-1:0] dirVec;

    // this value is shared among different sobol rngs to generate position of lsz
    cntwithen #(
        .BITWIDTH(BITWIDTH)
    ) u_cntwithen(
        .iClk(iClk),
        .iRstN(iRstN),
        .iEn(iEn),
        .iClr(iClr),
        .oCnt(cntNum)
        );

    lsz #(
        .BITWIDTH(BITWIDTH)
    ) u_lsz(
        .iGray(cntNum),
        .oOneHot(oneHot)
        );

    /* initialization of directional vectors for current dimension*/
    genvar i;
    generate
        for (i = 0; i < BITWIDTH; i = i + 1) begin : dirVec_init
            assign dirVec[(i+1)*BITWIDTH-1 : i*BITWIDTH] = 1 << (BITWIDTH-1-i);
        end
    endgenerate

    sobolrng_core #(
        .BITWIDTH(BITWIDTH)
    ) u_sobolrng_core(
        .iClk(iClk),
        .iRstN(iRstN),
        .iEn(iEn),
        .iClr(iClr),
        .iOneHot(oneHot),
        .dirVec(dirVec),
        .oRand(sobolSeq)
        );

endmodule

`endif

