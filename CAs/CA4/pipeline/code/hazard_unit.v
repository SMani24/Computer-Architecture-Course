module hazard_uint (
    // HazardUnit inputs
    RegWriteM,
    Rs1E,
    Rs2E,
    RdM,
    RegWriteW,
    RdW,
    Rs1D,
    Rs2D,
    RdE,
    PCSrcE,
    ResultSrcE,
    
    // DataPath inputs
    ForwardAE,
    ForwardBE,
    StallD,
    StallF,
    FlushD,
    FlushE
);

    input RegWriteM;
    input [19:15] Rs1E;
    input [24:20] Rs2E;
    input [11:7] RdM;
    input RegWriteW;
    input [11:7] RdW;
    input PCSrcE;
    input [19:15] Rs1D;
    input [24:20] Rs2D;
    input [11:7] RdE;
    input [1:0] ResultSrcE;

    output reg [1:0] ForwardAE;
    output reg [1:0] ForwardBE;
    output reg StallD;
    output reg StallF;
    output reg FlushD;
    output reg FlushE;

    // Data Hazard:
    // Non-lw 
    always @(*) begin
        // ALU A input
        if ((RegWriteM == 1'b1) && (Rs1E == RdM) && (RdM != 0)) begin
            ForwardAE = 2'b10;
        end
        else if ((RegWriteW == 1'b1) && (Rs1E == RdW) && (RdW != 0)) begin
            ForwardAE = 2'b01;
        end 
        else begin
            ForwardAE = 2'b00;
        end

        // ALU B input
        if ((RegWriteM == 1'b1) && (Rs2E == RdM) && (RdM != 0)) begin
            ForwardBE = 2'b10;
        end
        else if ((RegWriteW == 1'b1) && (Rs2E == RdW) && (RdW != 0)) begin
            ForwardBE = 2'b01;
        end
        else begin
            ForwardBE = 2'b00;
        end
    end

    //lw
    always @(*) begin
        FlushE = 1'b0;
        StallD = 1'b0;
        StallF = 1'b0;
        if ((ResultSrcE == 01) & (Rs1D == RdE || Rs2D == RdE) & (RdE != 0)) begin
            FlushE = 1'b1;
            StallD = 1'b1;
            StallF = 1'b1;
        end
    end

    // Control Hazard
    always @(*) begin
        FlushD = 0;
        FlushE = 0;

        if (PCSrcE) begin
            FlushD = 1'b1;
            FlushE = 1'b1;
        end    
    end
endmodule
