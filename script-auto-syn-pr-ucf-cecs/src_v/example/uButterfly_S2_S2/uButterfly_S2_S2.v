//By Alexander Peacock, undergrad at UCF ECE
//email: alexpeacock56ten@gmail.com

`ifndef uButterfly_S2_S2
`define uButterfly_S2_S2

`include "uMUL_bi.v"
`include "uSADD.v"

module uButterfly_S2_S2  #(
    parameter BITWIDTH = 8
) (
    input wire iClk, iRstN, iEn, iClr1, iClr2, //clock, reset, enable, clear1 and clear2 for pipelining purposes
    input wire iReal0, iImg0, iReal1, iImg1, //real and image inputs
    input wire [BITWIDTH-1:0] iwReal, iwImg, //binary twiddle inputs
    output wire oReal0, oImg0, oReal1, oImg1 //butterfly outputs
    
);

    //used for butterfly equation parts
    wire eq_Real1_x_wReal;
    wire eq_Real1_x_wImg;
    wire eq_Img1_x_wReal;
    wire eq_Img1_x_wImg;
    
    //scales select input 
    wire scalerReal0;
    wire scalerImg0;
    
    //final part for outputs
    wire real_eq;
    wire img_eq;
    
    reg biZero; //used for bipolar 0

    //creates bipolar 0 (1/2 * 2 - 1 == 0)
    always@(posedge iClk or negedge iRstN) begin
        if(~iRstN) begin 
            biZero <= 0;
        end else begin
            biZero <= ~biZero;
        end
    end
    
    //these account for the multiplication of input 1 with w
    uMUL_bi #(
        .BITWIDTH(BITWIDTH)
    )u_uMUL_bi_Real1_x_wReal (
        .iClk(iClk),
        .iRstN(iRstN),
        .iEn(iEn),
        .iA(iReal1),
        .iB(iwReal),
        .iClr(iClr1),
        .oMult(eq_Real1_x_wReal)
    );

    uMUL_bi #(
        .BITWIDTH(BITWIDTH)
    ) u_uMUL_bi_Real1_x_wImg (
        .iClk(iClk),
        .iRstN(iRstN),
        .iEn(iEn),
        .iA(iReal1),
        .iB(iwImg),
        .iClr(iClr1),
        .oMult(eq_Real1_x_wImg)
    );

    uMUL_bi #(
        .BITWIDTH(BITWIDTH)
    ) u_uMUL_bi_Img1_x_wReal (
        .iClk(iClk),
        .iRstN(iRstN),
        .iEn(iEn),
        .iA(iImg1),
        .iB(iwReal),
        .iClr(iClr1),
        .oMult(eq_Img1_x_wReal)
    );

    uMUL_bi #(
        .BITWIDTH(BITWIDTH)
    ) u_uMUL_bi_Img1_x_wImg (
        .iClk(iClk),
        .iRstN(iRstN),
        .iEn(iEn),
        .iA(iImg1),
        .iB(iwImg),
        .iClr(iClr1),
        .oMult(eq_Img1_x_wImg)
    );

    //creates parts to be added and subtracted in butterfly

    uSADD u_uSSUB_realeq (
        .iClk(iClk),
        .iRstN(iRstN),
        .iClr(iClr1),
        .iA(eq_Real1_x_wReal),
        .iB(~eq_Img1_x_wImg),
        .oC(real_eq)
    );

    uSADD u_uSADD_imgeq (
        .iClk(iClk),
        .iRstN(iRstN),
        .iClr(iClr1),
        .iA(eq_Real1_x_wImg),
        .iB(eq_Img1_x_wReal),
        .oC(img_eq) 
    );

    //scales first input to match with the other scaled equations
    uSADD u_uSADD_scalerReal (
        .iClk(iClk),
        .iRstN(iRstN),
        .iClr(iClr1),
        .iA(iReal0),
        .iB(biZero),
        .oC(scalerReal0)
    );

    uSADD uSADD_scalerImg (
        .iClk(iClk),
        .iRstN(iRstN),
        .iClr(iClr1),
        .iA(iImg0),
        .iB(biZero),
        .oC(scalerImg0)
    );

    //used to find final outputs

    uSADD u_uSADD_oReal0 (
        .iClk(iClk),
        .iRstN(iRstN),
        .iClr(iClr2),
        .iA(scalerReal0),
        .iB(real_eq),
        .oC(oReal0) 
    );

    uSADD u_uSADD_oImg0 (
        .iClk(iClk),
        .iRstN(iRstN),
        .iClr(iClr2),
        .iA(scalerImg0),
        .iB(img_eq),
        .oC(oImg0) 
    );

    uSADD u_uSSUB_oReal1 (
        .iClk(iClk),
        .iRstN(iRstN),
        .iClr(iClr2),
        .iA(scalerReal0),
        .iB(~real_eq),
        .oC(oReal1) 
    );

    uSADD u_uSSUB_oImg1 (
        .iClk(iClk),
        .iRstN(iRstN),
        .iClr(iClr2),
        .iA(scalerImg0),
        .iB(~img_eq),
        .oC(oImg1) 
    );
    
endmodule

`endif

