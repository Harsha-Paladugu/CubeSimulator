module cubeState (
    input  wire       clk,
    input  wire       rst,
	 input [5:0] nextFaceMove,
	 input [2:0] nextRotation,
    output reg  [161:0] cube_flat      // flattened output: 54 * 3 bits
);

	 // each index of cube contains a 3-bit color code 000 - 101
    reg [2:0] cube [0:53];
	 
	 // make a temporary copy to do moves on
    reg [2:0] tmp  [0:53];
	 
	 // temporary placeholder index
    reg [2:0] tmpIndex;

    integer i, k;

    // Initialize / reset to solved state
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            // Face 0: indices 0–8 = white (000)
            for (i = 0; i < 9; i = i + 1) begin
                cube[i] <= 3'b000;
				end

            // Face 1: indices 9–17 = orange (001)
            for (i = 9; i < 18; i = i + 1) begin
                cube[i] <= 3'b001;
				end

            // Face 2: indices 18–26 = green (010)
            for (i = 18; i < 27; i = i + 1) begin
                cube[i] <= 3'b010;
				end

            // Face 3: indices 27–35 = red (011)
            for (i = 27; i < 36; i = i + 1) begin
                cube[i] <= 3'b011;
				end

            // Face 4: indices 36–44 = blue (100)
            for (i = 36; i < 45; i = i + 1) begin
                cube[i] <= 3'b100;
				end

            // Face 5: indices 45–53 = yellow (101)
            for (i = 45; i < 54; i = i + 1) begin
                cube[i] <= 3'b101;
				end

        end  // end if
		  else begin

				// 1. Copy current cube into tmp
				for (k = 0; k < 54; k = k + 1) begin
					tmp[k] = cube[k];
				end

				// 2. Select Move to make and perform swap
				case (nextFaceMove)
				
					6'd0: begin														// U face
						for(k = 0; k < nextRotation; k = k + 1) begin	// Perform move nextRotation # of times 
						
							//***Swap corners***
							
							// UBL -> UBR -> UFR -> UFL -> UBL
							tmpIndex = tmp[0];
							tmp[0] = tmp[6];
							tmp[6] = tmp[8];
							tmp[8] = tmp[2];
							tmp[2] = tmpIndex;
							
							// FUR -> LUF -> BLU -> RUB -> FRU
							tmpIndex = tmp[20];
							tmp[20] = tmp[29];
							tmp[29] = tmp[38];
							tmp[38] = tmp[11];
							tmp[11] = tmpIndex;
							
							// FLU -> LUB -> BRU -> RUF -> FLU
							tmpIndex = tmp[18];
							tmp[18] = tmp[27];
							tmp[27] = tmp[36];
							tmp[36] = tmp[9];
							tmp[9] = tmpIndex;
							
							// ***Corner Swaps Complete***
							
							// ***Swap Edges***
							
							// UB -> UR -> UF -> UL -> UB
							tmpIndex = tmp[1];
							tmp[1] = tmp[3];
							tmp[3] = tmp[7];
							tmp[7] = tmp[5];
							tmp[5] = tmpIndex;
							
							// FU -> LU -> BU -> RU -> FU
							tmpIndex = tmp[19];
							tmp[19] = tmp[28];
							tmp[28] = tmp[37];
							tmp[37] = tmp[10];
							tmp[10] = tmpIndex;
							
							// ***Edge Swaps Complete***
							
							// *** Move Complete***
						end // end for loop
					end // end U case
					
					6'd1: begin														// L face
						for(k = 0; k < nextRotation; k = k + 1) begin	// Perform move nextRotation # of times 
						
							//***Swap corners***
							
							// LUB -> LUF -> LDF -> LDB -> LUB
							tmpIndex = tmp[9];
							tmp[9] = tmp[15];
							tmp[15] = tmp[17];
							tmp[17] = tmp[11];
							tmp[11] = tmpIndex;
							
							// UBL -> FUL -> DFL -> BDL -> UBL
							tmpIndex = tmp[0];
							tmp[0] = tmp[44];
							tmp[44] = tmp[45];
							tmp[45] = tmp[18];
							tmp[18] = tmpIndex;
							
							// UFL -> FDL -> DBL -> BLU -> UFL
							tmpIndex = tmp[6];
							tmp[6] = tmp[38];
							tmp[38] = tmp[51];
							tmp[51] = tmp[24];
							tmp[24] = tmpIndex;
							
							// ***Corner Swaps Complete***
							
							// ***Swap Edges***
							
							// LU -> LF -> LD -> LB
							tmpIndex = tmp[10];
							tmp[10] = tmp[12];
							tmp[12] = tmp[16];
							tmp[16] = tmp[14];
							tmp[14] = tmpIndex;
							
							// UL -> FL -> DL -> BL -> UL
							tmpIndex = tmp[3];
							tmp[3] = tmp[41];
							tmp[41] = tmp[48];
							tmp[48] = tmp[21];
							tmp[21] = tmpIndex;

							// ***Edge Swaps Complete***
							
							// *** Move Complete***
						end // end for loop
					end // end L case
					
					
					
				endcase
				
				// 3. Write tmp back into cube so state updates
            for (k = 0; k < 54; k = k + 1) begin
                cube[k] <= tmp[k];
				end
					 
		  end // end else
    end // end always
	 
	 // Pack internal cube[] into flattened 162-bit output
    always @(*) begin
        for (i = 0; i < 54; i = i + 1) begin
            cube_flat[3*i + 0] = cube[i][0];
            cube_flat[3*i + 1] = cube[i][1];
            cube_flat[3*i + 2] = cube[i][2];
        end // end for
    end // end always 

endmodule
