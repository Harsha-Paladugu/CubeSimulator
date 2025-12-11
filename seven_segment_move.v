module seven_segment_move (
input [3:0] SW,
output reg [6:0]HEX0
);

always @(*)
begin
	case (SW)
				4'h0: HEX0 = 7'b1000001; // U
            4'h1: HEX0 = 7'b1111010; // R
            4'h2: HEX0 = 7'b1110001; // L
            4'h3: HEX0 = 7'b0111000; // F
            4'h4: HEX0 = 7'b1100000; // B
            4'h5: HEX0 = 7'b1000010; // D
            4'hA: HEX0 = 7'b1000000; // 0
            4'hB: HEX0 = 7'b1111111; // CW
            4'hC: HEX0 = 7'b1111101; // CCW
            4'hD: HEX0 = 7'b0100100; // Double
            default: HEX0 = 7'b1111111 ; // null

	endcase
end

endmodule