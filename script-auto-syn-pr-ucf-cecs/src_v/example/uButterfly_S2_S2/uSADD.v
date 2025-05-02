//By Alexander Peacock, undergrad at UCF ECE
//email: alexpeacock56ten@gmail.com
`ifndef uSADD
`define uSADD


module uSADD (
    input wire iClk,
    input wire iRstN, 
    input wire iClr,
    input wire iA,
    input wire iB,
    output wire oC
);

    wire [1:0] PCout;
    reg [1:0] acc;

    //Used to calculate the output
    assign PCout = iA + iB;

    //constantly accumulates it's own LSB with the PCout
    always@(posedge iClk or negedge iRstN) begin
        if(~iRstN) begin
            acc <= 0;
        end else begin
            if(iClr) begin 
                acc <= 0;
            end else begin
                acc <= acc[0] + iA + iB;
           end
        end
    end

    //outputs the MSB of the accumulator 
    assign oC = acc[1];
endmodule

`endif
