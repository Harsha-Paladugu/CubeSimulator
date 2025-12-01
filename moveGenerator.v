module moveGenerator (
    input  wire clk,
    input  wire rst,
    output reg [2:0] nextFace,
    output reg [1:0] nextRotation
);

    reg [7:0] lfsr;

    // LFSR with taps: 8,6,5,4 (max period 255)
    wire feedback = lfsr[7] ^ lfsr[5] ^ lfsr[4] ^ lfsr[3];

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            lfsr         <= 8'hA5;  // non-zero seed
            nextFace     <= 0;
            nextRotation <= 0;
        end else begin
            // shift LFSR
            lfsr <= {lfsr[6:0], feedback};

            // map to 0..5
            if (lfsr[2:0] >= 6)
                nextFace <= lfsr[2:0] - 2;   // map 6,7 to 4,5 
            else
                nextFace <= lfsr[2:0];

            case (lfsr[4:3])
                2'b00: nextRotation <= 2'd0;   // CW
                2'b01: nextRotation <= 2'd1;   // CCW
                default: nextRotation <= 2'd2; // double
            endcase
        end
    end

endmodule
