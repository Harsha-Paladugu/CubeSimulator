module cubeState (
	 input [5:0] nextFaceMove,
	 input [1:0] nextRotation,
	 input [161:0] cubeState,
    output reg  [161:0] cubeStateNew
);
	 
	 
	 
	integer i, k, j;
	 
	 // make a temporary copy to do moves on
   reg [2:0] tmp  [0:53];
	 
	 // temporary placeholder index
    reg [2:0] tmpIndex;

    // Make Move
    always @(*) begin
			// 1. Copy current cube into tmp
			j = 0;
		for (i = 0; i < 54; i = i+1) begin
				tmp[i] = cubeState[3*i +: 3];
		end

			// 2. Select Move to make and perform swap
			case (nextFaceMove)
			
				6'd0: begin														// U face
					for(k = 0; k < nextRotation ; k = k + 1) begin	// Perform move nextRotation # of times 
					
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
				
				6'd2: begin														// F face
					for(k = 0; k < nextRotation; k = k + 1) begin	// Perform move nextRotation # of times 
					
						//***Swap corners***
						
						// FUL -> FUR -> FDR -> FDL -> FUL
						tmpIndex = tmp[18];
						tmp[18] = tmp[24];
						tmp[24] = tmp[26];
						tmp[26] = tmp[20];
						tmp[20] = tmpIndex;
						
						// UFL -> RUF -> DFR -> LDF -> UFL
						tmpIndex = tmp[6];
						tmp[6] = tmp[17];
						tmp[17] = tmp[47];
						tmp[47] = tmp[27];
						tmp[27] = tmpIndex;
						
						// UFR -> RDF -> DFL -> LUF -> UFR
						tmpIndex = tmp[8];
						tmp[8] = tmp[11];
						tmp[11] = tmp[45];
						tmp[45] = tmp[33];
						tmp[33] = tmpIndex;
						
						// ***Corner Swaps Complete***
						
						// ***Swap Edges***
						
						// FU -> FR -> FD -> FL -> FU
						tmpIndex = tmp[19];
						tmp[19] = tmp[21];
						tmp[21] = tmp[25];
						tmp[25] = tmp[23];
						tmp[23] = tmpIndex;
						
						// UF -> RF -> DF -> LF -> UF
						tmpIndex = tmp[7];
						tmp[7] = tmp[14];
						tmp[14] = tmp[46];
						tmp[46] = tmp[30];
						tmp[30] = tmpIndex;

						// ***Edge Swaps Complete***
						
						// *** Move Complete***
					end // end for loop
				end // end F case
				
				6'd3: begin														// R face
					for(k = 0; k < nextRotation; k = k + 1) begin	// Perform move nextRotation # of times 
					
						//***Swap corners***
						
						// RUF -> RUB -> RDB -> RDF -> RUF
						tmpIndex = tmp[27];
						tmp[27] = tmp[33];
						tmp[33] = tmp[35];
						tmp[35] = tmp[29];
						tmp[29] = tmpIndex;
						
						// UFR -> BUR -> DBR -> FDR -> UFR
						tmpIndex = tmp[8];
						tmp[8] = tmp[26];
						tmp[26] = tmp[53];
						tmp[53] = tmp[36];
						tmp[36] = tmpIndex;
						
						// FUR -> UBR -> BDR -> DFR -> FUR
						tmpIndex = tmp[20];
						tmp[20] = tmp[47];
						tmp[47] = tmp[42];
						tmp[42] = tmp[2];
						tmp[2] = tmpIndex;
						
						// ***Corner Swaps Complete***
						
						// ***Swap Edges***
						
						// RU -> RB -> RD -> RF -> RU
						tmpIndex = tmp[28];
						tmp[28] = tmp[30];
						tmp[30] = tmp[34];
						tmp[34] = tmp[32];
						tmp[32] = tmpIndex;
						
						// UR -> BR -> DR -> FR -> UR
						tmpIndex = tmp[5];
						tmp[5] = tmp[23];
						tmp[23] = tmp[50];
						tmp[50] = tmp[39];
						tmp[39] = tmpIndex;

						// ***Edge Swaps Complete***
						
						// *** Move Complete***
					end // end for loop
				end // end R case	
				6'd4: begin														// B face
					for(k = 0; k < nextRotation; k = k + 1) begin	// Perform move nextRotation # of times 
					
						//***Swap corners***
						
						// BUR -> BUL -> BDL -> BDR -> BUR
						tmpIndex = tmp[36];
						tmp[36] = tmp[42];
						tmp[42] = tmp[44];
						tmp[44] = tmp[38];
						tmp[38] = tmpIndex;
						
						// RUB -> UBL -> LDB -> DBR -> RUB
						tmpIndex = tmp[29];
						tmp[29] = tmp[53];
						tmp[53] = tmp[15];
						tmp[15] = tmp[0];
						tmp[0] = tmpIndex;
						
						// UBR -> LUB -> DBL -> RDB -> UBR
						tmpIndex = tmp[2];
						tmp[2] = tmp[35];
						tmp[35] = tmp[51];
						tmp[51]= tmp[9];
						tmp[9] = tmpIndex;
						
						// ***Corner Swaps Complete***
						
						// ***Swap Edges***
						
						// BU -> BL -> BD -> BR -> BU
						tmpIndex = tmp[37];
						tmp[37] = tmp[39];
						tmp[39] = tmp[43];
						tmp[43] = tmp[41];
						tmp[41] = tmpIndex;
						
						// UB -> LB -> DB -> RB -> UB
						tmpIndex = tmp[1];
						tmp[1] = tmp[32];
						tmp[32] = tmp[52];
						tmp[52] = tmp[12];
						tmp[12] = tmpIndex;

						// ***Edge Swaps Complete***
						
						// *** Move Complete***
					end // end for loop
				end // end B case

				6'd5: begin														// D face
					for(k = 0; k < nextRotation; k = k + 1) begin	// Perform move nextRotation # of times 
					
						//***Swap corners***
						
						// DFL -> DFR -> DBR -> DBL -> DFL
						tmpIndex = tmp[45];
						tmp[45] = tmp[51];
						tmp[51] = tmp[53];
						tmp[53] = tmp[47];
						tmp[47] = tmpIndex;
						
						// FDL -> RDF -> BDR -> LDB -> FDL
						tmpIndex = tmp[24];
						tmp[24] = tmp[15];
						tmp[15] = tmp[42];
						tmp[42] = tmp[33];
						tmp[33] = tmpIndex;
						
						// LDF -> FDR -> RDB -> BDL -> LDF
						tmpIndex = tmp[17];
						tmp[17] = tmp[44];
						tmp[44] = tmp[35];
						tmp[35] = tmp[26];
						tmp[26] = tmpIndex;
						
						// ***Corner Swaps Complete***
						
						// ***Swap Edges***
						
						// DF -> DR -> DB -> DL -> DF
						tmpIndex = tmp[46];
						tmp[46] = tmp[48];
						tmp[48] = tmp[52];
						tmp[52] = tmp[50];
						tmp[50] = tmpIndex;
						
						// FD -> RD -> BD -> LD -> FD
						tmpIndex = tmp[25];
						tmp[25] = tmp[16];
						tmp[16] = tmp[43];
						tmp[43] = tmp[34];
						tmp[34] = tmpIndex;

						// ***Edge Swaps Complete***
						
						// *** Move Complete***
					end // end for loop
				end // end D case
				
				default: begin
				end
			endcase

			for (i = 0; i < 54; i = i + 1) begin
            cubeStateNew[3*i +: 3] = tmp[i];
         end // end for
 end // end always
endmodule


// 0 = U
// 1 = L
// 2 = F
// 3 = R
// 4 = B
// 5 = D