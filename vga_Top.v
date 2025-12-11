module vga_Top	(
 
	input 		  clk,
	input [161:0] color,
	input         rst,
	input 		  solved,

	//////////// VGA //////////
	output		          VGA_BLANK_N,
	output reg	  [7:0]  VGA_B,
	output		          VGA_CLK,
	output reg	  [7:0]  VGA_G,
	output		          VGA_HS,
	output reg	  [7:0]  VGA_R,
	output		          VGA_SYNC_N,
	output		          VGA_VS
);
 
// ----------------------------------------------------
// BITMAP ROM (cube layout)
// ----------------------------------------------------
wire [17:0] SW_db;  // unused but keeping for now

reg [0:0] bitmap_rom [0:3072];

integer i_init;
initial begin
    // Set all to 0 (off) first
    for (i_init = 0; i_init < 3072; i_init = i_init + 1) begin
        bitmap_rom[i_init] = 1'b0;
    end

    bitmap_rom[652] = 1'b1;
    bitmap_rom[655] = 1'b1;
    bitmap_rom[658] = 1'b1;
    bitmap_rom[844] = 1'b1;
    bitmap_rom[847] = 1'b1;
    bitmap_rom[850] = 1'b1;
    bitmap_rom[1036] = 1'b1;
    bitmap_rom[1039] = 1'b1;
    bitmap_rom[1042] = 1'b1;

    bitmap_rom[1282] = 1'b1;
    bitmap_rom[1285] = 1'b1;
    bitmap_rom[1288] = 1'b1;
    bitmap_rom[1292] = 1'b1;
    bitmap_rom[1295] = 1'b1;
    bitmap_rom[1298] = 1'b1;
    bitmap_rom[1302] = 1'b1;
    bitmap_rom[1305] = 1'b1;
    bitmap_rom[1308] = 1'b1;

    bitmap_rom[1312] = 1'b1;
    bitmap_rom[1315] = 1'b1;
    bitmap_rom[1318] = 1'b1;
    bitmap_rom[1474] = 1'b1;
    bitmap_rom[1477] = 1'b1;
    bitmap_rom[1480] = 1'b1;
    bitmap_rom[1484] = 1'b1;
    bitmap_rom[1487] = 1'b1;
    bitmap_rom[1490] = 1'b1;
    bitmap_rom[1494] = 1'b1;
    bitmap_rom[1497] = 1'b1;
    bitmap_rom[1500] = 1'b1;
    bitmap_rom[1504] = 1'b1;
    bitmap_rom[1507] = 1'b1;
    bitmap_rom[1510] = 1'b1;

    bitmap_rom[1666] = 1'b1;
    bitmap_rom[1669] = 1'b1;
    bitmap_rom[1672] = 1'b1;
    bitmap_rom[1676] = 1'b1;
    bitmap_rom[1679] = 1'b1;
    bitmap_rom[1682] = 1'b1;
    bitmap_rom[1686] = 1'b1;
    bitmap_rom[1689] = 1'b1;
    bitmap_rom[1692] = 1'b1;
    bitmap_rom[1696] = 1'b1;
    bitmap_rom[1699] = 1'b1;
    bitmap_rom[1702] = 1'b1;

    bitmap_rom[1932] = 1'b1;
    bitmap_rom[1935] = 1'b1;
    bitmap_rom[1938] = 1'b1;
    bitmap_rom[2124] = 1'b1;
    bitmap_rom[2127] = 1'b1;
    bitmap_rom[2130] = 1'b1;
    bitmap_rom[2316] = 1'b1;
    bitmap_rom[2319] = 1'b1;
    bitmap_rom[2322] = 1'b1;
end

// ----------------------------------------------------
// SOLVED MESSAGE ROM
// ----------------------------------------------------
reg [0:0] solved_rom [0:3072];
integer s_init;
initial begin
    integer i;
    for (i = 0; i < 3072; i=i+1)
        solved_rom[i] = 1'b0;

    // S
    solved_rom[2*64 + 0] = 1;
    solved_rom[2*64 + 1] = 1;
    solved_rom[2*64 + 2] = 1;
    solved_rom[2*64 + 3] = 1;
    solved_rom[2*64 + 4] = 1;

    solved_rom[3*64 + 0] = 1;
    solved_rom[4*64 + 0] = 1;
    solved_rom[5*64 + 0] = 1;

    solved_rom[6*64 + 0] = 1;
    solved_rom[6*64 + 1] = 1;
    solved_rom[6*64 + 2] = 1;
    solved_rom[6*64 + 3] = 1;
    solved_rom[6*64 + 4] = 1;

    solved_rom[7*64 + 4] = 1;
    solved_rom[8*64 + 4] = 1;
    solved_rom[9*64 + 4] = 1;

    solved_rom[10*64 + 0] = 1;
    solved_rom[10*64 + 1] = 1;
    solved_rom[10*64 + 2] = 1;
    solved_rom[10*64 + 3] = 1;
    solved_rom[10*64 + 4] = 1;

    // O  (cols 8–11)
    solved_rom[128 + 8]  = 1;
    solved_rom[128 + 9]  = 1;
    solved_rom[128 + 10] = 1;
    solved_rom[128 + 11] = 1;

    solved_rom[192 + 8]  = 1;
    solved_rom[256 + 8]  = 1;
    solved_rom[320 + 8]  = 1;
    solved_rom[384 + 8]  = 1;
    solved_rom[448 + 8]  = 1;
    solved_rom[512 + 8]  = 1;
    solved_rom[576 + 8]  = 1;

    solved_rom[192 + 11] = 1;
    solved_rom[256 + 11] = 1;
    solved_rom[320 + 11] = 1;
    solved_rom[384 + 11] = 1;
    solved_rom[448 + 11] = 1;
    solved_rom[512 + 11] = 1;
    solved_rom[576 + 11] = 1;

    solved_rom[640 + 8]  = 1;
    solved_rom[640 + 9]  = 1;
    solved_rom[640 + 10] = 1;
    solved_rom[640 + 11] = 1;

    // L  (cols 16–19)
    solved_rom[128 + 16] = 1;
    solved_rom[192 + 16] = 1;
    solved_rom[256 + 16] = 1;
    solved_rom[320 + 16] = 1;
    solved_rom[384 + 16] = 1;
    solved_rom[448 + 16] = 1;
    solved_rom[512 + 16] = 1;
    solved_rom[576 + 16] = 1;
    solved_rom[640 + 16] = 1;

    solved_rom[640 + 17] = 1;
    solved_rom[640 + 18] = 1;
    solved_rom[640 + 19] = 1;

    // V  (cols 22–26)
    solved_rom[665] = 1;
    solved_rom[536] = 1;
    solved_rom[538] = 1;
    solved_rom[407] = 1;
    solved_rom[411] = 1;
    solved_rom[279] = 1;
    solved_rom[283] = 1;
    solved_rom[151] = 1;
    solved_rom[155] = 1;

    // E (start at col 32)
    solved_rom[128 + 32] = 1;
    solved_rom[192 + 32] = 1;
    solved_rom[256 + 32] = 1;
    solved_rom[320 + 32] = 1;
    solved_rom[384 + 32] = 1;
    solved_rom[448 + 32] = 1;
    solved_rom[512 + 32] = 1;
    solved_rom[576 + 32] = 1;
    solved_rom[640 + 32] = 1;

    solved_rom[128 + 33] = 1;
    solved_rom[128 + 34] = 1;
    solved_rom[128 + 35] = 1;
    solved_rom[128 + 36] = 1;
    solved_rom[128 + 37] = 1;

    solved_rom[384 + 33] = 1;
    solved_rom[384 + 34] = 1;
    solved_rom[384 + 35] = 1;
    solved_rom[384 + 36] = 1;

    solved_rom[640 + 33] = 1;
    solved_rom[640 + 34] = 1;
    solved_rom[640 + 35] = 1;
    solved_rom[640 + 36] = 1;
    solved_rom[640 + 37] = 1;

    // D (start at col 40)
    solved_rom[128 + 40] = 1;
    solved_rom[192 + 40] = 1;
    solved_rom[256 + 40] = 1;
    solved_rom[320 + 40] = 1;
    solved_rom[384 + 40] = 1;
    solved_rom[448 + 40] = 1;
    solved_rom[512 + 40] = 1;
    solved_rom[576 + 40] = 1;
    solved_rom[640 + 40] = 1;

    solved_rom[128 + 41] = 1;
    solved_rom[128 + 42] = 1;

    solved_rom[192 + 43] = 1;
    solved_rom[256 + 44] = 1;
    solved_rom[320 + 45] = 1;
    solved_rom[384 + 45] = 1;
    solved_rom[448 + 45] = 1;
    solved_rom[512 + 45] = 1;
    solved_rom[576 + 44] = 1;
    solved_rom[640 + 43] = 1;

    solved_rom[640 + 41] = 1;
    solved_rom[640 + 42] = 1;
end

// ----------------------------------------------------
// VGA DRIVER
// ----------------------------------------------------
wire active_pixels;
wire frame_done;
wire [9:0] x;  // current x
wire [9:0] y;  // current y

vga_driver the_vga(
    .clk(clk),
    .rst(rst),

    .vga_clk(VGA_CLK),
    .hsync(VGA_HS),
    .vsync(VGA_VS),

    .active_pixels(active_pixels),
    .frame_done(frame_done),

    .xPixel(x),
    .yPixel(y),

    .VGA_BLANK_N(VGA_BLANK_N),
    .VGA_SYNC_N(VGA_SYNC_N)
);

// ----------------------------------------------------
// MINI FRAMEBUFFER
// ----------------------------------------------------
reg  [14:0] frame_buf_mem_address;
reg  [23:0] frame_buf_mem_data;
reg         frame_buf_mem_wren;
wire [23:0] frame_buf_mem_q;

vga_frame vga_memory(
    .address (frame_buf_mem_address),
    .clock   (clk),
    .data    (frame_buf_mem_data),
    .wren    (frame_buf_mem_wren),
    .q       (frame_buf_mem_q)
);

// ----------------------------------------------------
// FSM + INDEXING
// ----------------------------------------------------
reg [15:0] i;        // loop index for bitmap / framebuffer
reg [7:0]  j;        // bit index into `color` (3 bits per sticker)
reg        blkx;     // unused but kept
reg [7:0]  S, NS;
reg [2:0]  write_substate;
reg [5:0]  sticker;

// Latch 'solved' per frame to avoid mid-frame tearing
reg solved_frame;

parameter 
    START        = 8'd0,
    W2M_INIT     = 8'd1,
    W2M_COND     = 8'd2,
    W2M_INC      = 8'd3,
    RFM_INIT     = 8'd4,
    RFM_DRAWING  = 8'd5,
    ERROR        = 8'hFF;

parameter LOOP_SIZE        = 16'd3072;
parameter LOOP_I_SIZE      = 16'd64;
parameter LOOP_Y_SIZE      = 16'd48;
parameter WIDTH            = 16'd640;
parameter HEIGHT           = 16'd480;
parameter PIXELS_IN_WIDTH  = WIDTH/LOOP_I_SIZE;   // 160
parameter PIXELS_IN_HEIGHT = HEIGHT/LOOP_Y_SIZE;  // 120

// Use frame-latched solved flag for pixel_on selection
wire pixel_on = solved_frame ? solved_rom[i] : bitmap_rom[i];

// ----------------------------------------------------
// LATCH SOLVED PER FRAME
// ----------------------------------------------------
always @(posedge clk or negedge rst) begin
    if (!rst)
        solved_frame <= 1'b0;
    else if (frame_done)
        solved_frame <= solved;
end

// ----------------------------------------------------
// NEXT STATE LOGIC
// ----------------------------------------------------
always @(*) begin
    case (S)
        START:      NS = W2M_INIT;
        W2M_INIT:   NS = W2M_COND;

        W2M_COND: begin
            if (i < LOOP_SIZE)
                NS = W2M_INC;
            else
                NS = RFM_INIT;
        end

        W2M_INC: NS = W2M_COND;

        // After a frame is done, go refresh framebuffer again
        RFM_INIT: begin
            if (frame_done == 1'b1)
                NS = W2M_INIT;
            else
                NS = RFM_INIT;
        end

        RFM_DRAWING: begin
            if (frame_done == 1'b1)
                NS = W2M_INIT;
            else
                NS = RFM_DRAWING;
        end

        default:    NS = ERROR;
    endcase
end

// ----------------------------------------------------
// STATE REGISTER
// ----------------------------------------------------
always @(posedge clk or negedge rst) begin
    if (!rst) begin
        S  <= START;
    end else begin
        S  <= NS;
    end
end

// ----------------------------------------------------
// SEQUENTIAL: WRITE/READ CONTROL + j / blkx UPDATE
// ----------------------------------------------------
always @(posedge clk or negedge rst) begin
    if (!rst) begin
        frame_buf_mem_address <= 14'd0;
        frame_buf_mem_data    <= 24'd0;
        frame_buf_mem_wren    <= 1'b0;
        i                     <= 16'd0;
        j                     <= 8'd0;
        write_substate        <= 3'b000;
        sticker               <= 6'd0;
    end else begin
        case (S)
            START: begin
                frame_buf_mem_address <= 14'd0;
                frame_buf_mem_data    <= 24'd0;
                frame_buf_mem_wren    <= 1'b0;
                i                     <= 16'd0;
                j                     <= 8'd0;
                sticker               <= 6'd0;
                write_substate        <= 3'b000;
            end

            // Start a new write pass
            W2M_INIT: begin
                frame_buf_mem_address <= 14'd0;
                frame_buf_mem_data    <= 24'd0;
                frame_buf_mem_wren    <= 1'b1;
                i                     <= 16'd0;
                j                     <= 8'd0;  
                sticker               <= 6'd0;
                write_substate        <= 3'b000; // restart color bit index
            end

            W2M_COND: begin
                // nothing to do here; controlled by NS logic
            end

            // Write one pixel's worth of RGB to the framebuffer
            W2M_INC: begin
                if (pixel_on == 1'b1) begin
                    case (write_substate)
                        3'b000: begin
                            frame_buf_mem_address <= i;
                            frame_buf_mem_data    <= {red, green, blue};
                            write_substate        <= 3'b001;
                        end

                        3'b001: begin
                            frame_buf_mem_address <= i + 1;
                            frame_buf_mem_data    <= {red, green, blue};
                            write_substate        <= 3'b010;
                        end

                        3'b010: begin
                            frame_buf_mem_address <= i + LOOP_I_SIZE;  // = +64
                            frame_buf_mem_data    <= {red, green, blue};
                            write_substate        <= 3'b011;
                        end

                        3'b011: begin
                            frame_buf_mem_address <= i + LOOP_I_SIZE + 1; // = +65
                            frame_buf_mem_data    <= {red, green, blue};
                            write_substate        <= 3'b100;
                        end

                        3'b100: begin
                            // done writing this 2×2 block
                            i              <= i + 1;
                            j              <= j + 3;
                            write_substate <= 3'b000;
                            sticker        <= sticker + 1'b1;
                        end
                    endcase
                end else begin
                    // OFF pixel: skip writing (just advance i)
                    i <= i + 1;
                end
            end

            // Read phase: map x/y to framebuffer address
            RFM_INIT: begin
                frame_buf_mem_wren <= 1'b0; // turn off writing
                if (y < HEIGHT && x < WIDTH)
                    frame_buf_mem_address <= (y/PIXELS_IN_HEIGHT) * LOOP_I_SIZE + (x/PIXELS_IN_WIDTH);
            end

            RFM_DRAWING: begin
                if (y < HEIGHT && x < WIDTH)
                    frame_buf_mem_address <= (y/PIXELS_IN_HEIGHT) * LOOP_I_SIZE + (x/PIXELS_IN_WIDTH);
            end

            default: begin
                // do nothing
            end
        endcase
    end
end

// ----------------------------------------------------
// STICKER → CUBE INDEX MAPPING
// ----------------------------------------------------
reg  [5:0] cubeIdx;      // index 0..53 into packed color[]
wire [2:0] cubeColor;

always @(*) begin
    case (sticker)
        // U face (already aligned)
        6'd0  : cubeIdx = 6'd0;
        6'd1  : cubeIdx = 6'd1;
        6'd2  : cubeIdx = 6'd2;
        6'd3  : cubeIdx = 6'd3;
        6'd4  : cubeIdx = 6'd4;
        6'd5  : cubeIdx = 6'd5;
        6'd6  : cubeIdx = 6'd6;
        6'd7  : cubeIdx = 6'd7;
        6'd8  : cubeIdx = 6'd8;

        // Side belt mapping (R, F, L, B)
        6'd9  : cubeIdx = 6'd9;
        6'd10 : cubeIdx = 6'd10;
        6'd11 : cubeIdx = 6'd11;

        6'd12 : cubeIdx = 6'd18;
        6'd13 : cubeIdx = 6'd19;
        6'd14 : cubeIdx = 6'd20;
        6'd15 : cubeIdx = 6'd27;
        6'd16 : cubeIdx = 6'd28;
        6'd17 : cubeIdx = 6'd29;
        6'd18 : cubeIdx = 6'd36;
        6'd19 : cubeIdx = 6'd37;
        6'd20 : cubeIdx = 6'd38;

        6'd21 : cubeIdx = 6'd12;
        6'd22 : cubeIdx = 6'd13;
        6'd23 : cubeIdx = 6'd14;
        6'd24 : cubeIdx = 6'd21;
        6'd25 : cubeIdx = 6'd22;
        6'd26 : cubeIdx = 6'd23;
        6'd27 : cubeIdx = 6'd30;
        6'd28 : cubeIdx = 6'd31;
        6'd29 : cubeIdx = 6'd32;
        6'd30 : cubeIdx = 6'd39;
        6'd31 : cubeIdx = 6'd40;
        6'd32 : cubeIdx = 6'd41;

        6'd33 : cubeIdx = 6'd15;
        6'd34 : cubeIdx = 6'd16;
        6'd35 : cubeIdx = 6'd17;
        6'd36 : cubeIdx = 6'd24;
        6'd37 : cubeIdx = 6'd25;
        6'd38 : cubeIdx = 6'd26;
        6'd39 : cubeIdx = 6'd33;
        6'd40 : cubeIdx = 6'd34;
        6'd41 : cubeIdx = 6'd35;

        // B and D faces already aligned
        6'd42 : cubeIdx = 6'd42;
        6'd43 : cubeIdx = 6'd43;
        6'd44 : cubeIdx = 6'd44;
        6'd45 : cubeIdx = 6'd45;
        6'd46 : cubeIdx = 6'd46;
        6'd47 : cubeIdx = 6'd47;
        6'd48 : cubeIdx = 6'd48;
        6'd49 : cubeIdx = 6'd49;
        6'd50 : cubeIdx = 6'd50;
        6'd51 : cubeIdx = 6'd51;
        6'd52 : cubeIdx = 6'd52;
        6'd53 : cubeIdx = 6'd53;

        default: cubeIdx = 6'd0;
    endcase
end

assign cubeColor = { color[3*cubeIdx+2], color[3*cubeIdx+1], color[3*cubeIdx] };

// ----------------------------------------------------
// COMBINATIONAL: COLOR MAPPING (NO STATE UPDATES)
// ----------------------------------------------------
reg [7:0] red;
reg [7:0] green;
reg [7:0] blue;
reg [2:0] packedColor;

always @(*) begin
    // Always show what's in memory on the VGA outputs
    {VGA_R, VGA_G, VGA_B} = frame_buf_mem_q;

    // Default RGB if bitmap cell is OFF
    red         = 8'h00;
    green       = 8'h00;
    blue        = 8'h00;
    packedColor = 3'b000;

    // Only compute a color when we're in the write phase and the bitmap cell is ON
    if (pixel_on == 1'b1) begin
        if (solved_frame) begin
            // SOLVED screen: draw white text regardless of cube colors
            red   = 8'hFF;
            green = 8'hFF;
            blue  = 8'hFF;
        end else begin
            // Normal cube: use cubeColor -> RGB mapping
            packedColor = cubeColor;

            if      (packedColor == 3'b000) begin
                red   = 8'hFF;
                green = 8'hFF;
                blue  = 8'hFF;
            end else if (packedColor == 3'b001) begin
                red   = 8'hFF;
                green = 8'h6E;
                blue  = 8'h00;
            end else if (packedColor == 3'b010) begin
                red   = 8'h00;
                green = 8'hFF;
                blue  = 8'h00;
            end else if (packedColor == 3'b011) begin
                red   = 8'hFF;
                green = 8'h00;
                blue  = 8'h00;
            end else if (packedColor == 3'b100) begin
                red   = 8'h00;
                green = 8'h00;
                blue  = 8'hFF;
            end else if (packedColor == 3'b101) begin
                red   = 8'hFF;
                green = 8'hF2;
                blue  = 8'h00;
            end else begin
                // fallback / error color (magenta)
                red   = 8'hFF;
                green = 8'h00;
                blue  = 8'hFF;
            end
        end
    end
end

endmodule
