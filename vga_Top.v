module vga_Top	(
 
	input 		  clk,
	input [161:0] color,
	input         rst,



	//////////// VGA //////////
	output		          		VGA_BLANK_N,
	output reg	     [7:0]		VGA_B,
	output		          		VGA_CLK,
	output reg	     [7:0]		VGA_G,
	output		          		VGA_HS,
	output reg	     [7:0]		VGA_R,
	output		          		VGA_SYNC_N,
	output		          		VGA_VS

	//////////// GPIO_0, GPIO_0 connect to GPIO Default //////////
	//inout 		    [35:0]		GPIO_0,

	//////////// GPIO_1, GPIO_1 connect to GPIO Default //////////
	//inout 		    [35:0]		GPIO_1

);

// DONE STANDARD PORT DECLARATION ABOVE

/* HANDLE SIGNALS FOR CIRCUIT */

wire [17:0]SW_db;

reg [0:0] bitmap_rom [0:3072];
 // Initialize the bitmap
initial begin
    // Set all to 0 (off) first
    for (i = 0; i < 3072; i = i + 1) begin
        bitmap_rom[i] = 1'b0;
    end
    
    bitmap_rom[1282] = 1'b1;
    bitmap_rom[1283] = 1'b1;
	 bitmap_rom[1285] = 1'b1;
	 bitmap_rom[1286] = 1'b1;
	 bitmap_rom[1288] = 1'b1;
	 bitmap_rom[1289] = 1'b1;
	 bitmap_rom[1346] = 1'b1;
	 bitmap_rom[1347] = 1'b1;
	 bitmap_rom[1349] = 1'b1;
	 bitmap_rom[1350] = 1'b1;
	 bitmap_rom[1352] = 1'b1;
	 bitmap_rom[1353] = 1'b1;
	 bitmap_rom[1474] = 1'b1; 
	 bitmap_rom[1475] = 1'b1; 
	 bitmap_rom[1538] = 1'b1; 
	 bitmap_rom[1539] = 1'b1; 
	 bitmap_rom[1477] = 1'b1; 
	 bitmap_rom[1478] = 1'b1; 
	 bitmap_rom[1541] = 1'b1; 
	 bitmap_rom[1542] = 1'b1; 
	 bitmap_rom[1480] = 1'b1; 
	 bitmap_rom[1481] = 1'b1; 
	 bitmap_rom[1544] = 1'b1; 
	 bitmap_rom[1545] = 1'b1; 
	 bitmap_rom[1666] = 1'b1; 
	 bitmap_rom[1667] = 1'b1; 
	 bitmap_rom[1730] = 1'b1; 
	 bitmap_rom[1731] = 1'b1; 
	 bitmap_rom[1669] = 1'b1; 
	 bitmap_rom[1670] = 1'b1; 
	 bitmap_rom[1733] = 1'b1; 
	 bitmap_rom[1734] = 1'b1; 
	 bitmap_rom[1672] = 1'b1; 
	 bitmap_rom[1673] = 1'b1;
	 bitmap_rom[1736] = 1'b1; 
	 bitmap_rom[1737] = 1'b1; 
	 bitmap_rom[1292] = 1'b1;
bitmap_rom[1293] = 1'b1;
bitmap_rom[1295] = 1'b1;
bitmap_rom[1296] = 1'b1;
bitmap_rom[1298] = 1'b1;
bitmap_rom[1299] = 1'b1;
bitmap_rom[1356] = 1'b1;
bitmap_rom[1357] = 1'b1;
bitmap_rom[1359] = 1'b1;
bitmap_rom[1360] = 1'b1;
bitmap_rom[1362] = 1'b1;
bitmap_rom[1363] = 1'b1;
bitmap_rom[1484] = 1'b1;
bitmap_rom[1485] = 1'b1;
bitmap_rom[1548] = 1'b1;
bitmap_rom[1549] = 1'b1;
bitmap_rom[1487] = 1'b1;
bitmap_rom[1488] = 1'b1;
bitmap_rom[1551] = 1'b1;
bitmap_rom[1552] = 1'b1;
bitmap_rom[1490] = 1'b1;
bitmap_rom[1491] = 1'b1;
bitmap_rom[1554] = 1'b1;
bitmap_rom[1555] = 1'b1;
bitmap_rom[1676] = 1'b1;
bitmap_rom[1677] = 1'b1;
bitmap_rom[1740] = 1'b1;
bitmap_rom[1741] = 1'b1;
bitmap_rom[1679] = 1'b1;
bitmap_rom[1680] = 1'b1;
bitmap_rom[1743] = 1'b1;
bitmap_rom[1744] = 1'b1;
bitmap_rom[1682] = 1'b1;
bitmap_rom[1683] = 1'b1;
bitmap_rom[1746] = 1'b1;
bitmap_rom[1747] = 1'b1;
bitmap_rom[1302] = 1'b1;
bitmap_rom[1303] = 1'b1;
bitmap_rom[1305] = 1'b1;
bitmap_rom[1306] = 1'b1;
bitmap_rom[1308] = 1'b1;
bitmap_rom[1309] = 1'b1;
bitmap_rom[1366] = 1'b1;
bitmap_rom[1367] = 1'b1;
bitmap_rom[1369] = 1'b1;
bitmap_rom[1370] = 1'b1;
bitmap_rom[1372] = 1'b1;
bitmap_rom[1373] = 1'b1;
bitmap_rom[1494] = 1'b1;
bitmap_rom[1495] = 1'b1;
bitmap_rom[1558] = 1'b1;
bitmap_rom[1559] = 1'b1;
bitmap_rom[1497] = 1'b1;
bitmap_rom[1498] = 1'b1;
bitmap_rom[1561] = 1'b1;
bitmap_rom[1562] = 1'b1;
bitmap_rom[1500] = 1'b1;
bitmap_rom[1501] = 1'b1;
bitmap_rom[1564] = 1'b1;
bitmap_rom[1565] = 1'b1;
bitmap_rom[1686] = 1'b1;
bitmap_rom[1687] = 1'b1;
bitmap_rom[1750] = 1'b1;
bitmap_rom[1751] = 1'b1;
bitmap_rom[1689] = 1'b1;
bitmap_rom[1690] = 1'b1;
bitmap_rom[1753] = 1'b1;
bitmap_rom[1754] = 1'b1;
bitmap_rom[1692] = 1'b1;
bitmap_rom[1693] = 1'b1;
bitmap_rom[1756] = 1'b1;
bitmap_rom[1757] = 1'b1;
bitmap_rom[1312] = 1'b1;
bitmap_rom[1313] = 1'b1;
bitmap_rom[1315] = 1'b1;
bitmap_rom[1316] = 1'b1;
bitmap_rom[1318] = 1'b1;
bitmap_rom[1319] = 1'b1;
bitmap_rom[1376] = 1'b1;
bitmap_rom[1377] = 1'b1;
bitmap_rom[1379] = 1'b1;
bitmap_rom[1380] = 1'b1;
bitmap_rom[1382] = 1'b1;
bitmap_rom[1383] = 1'b1;
bitmap_rom[1504] = 1'b1;
bitmap_rom[1505] = 1'b1;
bitmap_rom[1568] = 1'b1;
bitmap_rom[1569] = 1'b1;
bitmap_rom[1507] = 1'b1;
bitmap_rom[1508] = 1'b1;
bitmap_rom[1571] = 1'b1;
bitmap_rom[1572] = 1'b1;
bitmap_rom[1510] = 1'b1;
bitmap_rom[1511] = 1'b1;
bitmap_rom[1574] = 1'b1;
bitmap_rom[1575] = 1'b1;
bitmap_rom[1696] = 1'b1;
bitmap_rom[1697] = 1'b1;
bitmap_rom[1760] = 1'b1;
bitmap_rom[1761] = 1'b1;
bitmap_rom[1699] = 1'b1;
bitmap_rom[1700] = 1'b1;
bitmap_rom[1763] = 1'b1;
bitmap_rom[1764] = 1'b1;
bitmap_rom[1702] = 1'b1;
bitmap_rom[1703] = 1'b1;
bitmap_rom[1766] = 1'b1;
bitmap_rom[1767] = 1'b1;
bitmap_rom[652] = 1'b1;
bitmap_rom[653] = 1'b1;
bitmap_rom[655] = 1'b1;
bitmap_rom[656] = 1'b1;
bitmap_rom[658] = 1'b1;
bitmap_rom[659] = 1'b1;
bitmap_rom[716] = 1'b1;
bitmap_rom[717] = 1'b1;
bitmap_rom[719] = 1'b1;
bitmap_rom[720] = 1'b1;
bitmap_rom[722] = 1'b1;
bitmap_rom[723] = 1'b1;
bitmap_rom[844] = 1'b1;
bitmap_rom[845] = 1'b1;
bitmap_rom[908] = 1'b1;
bitmap_rom[909] = 1'b1;
bitmap_rom[847] = 1'b1;
bitmap_rom[848] = 1'b1;
bitmap_rom[911] = 1'b1;
bitmap_rom[912] = 1'b1;
bitmap_rom[850] = 1'b1;
bitmap_rom[851] = 1'b1;
bitmap_rom[914] = 1'b1;
bitmap_rom[915] = 1'b1;
bitmap_rom[1036] = 1'b1;
bitmap_rom[1037] = 1'b1;
bitmap_rom[1100] = 1'b1;
bitmap_rom[1101] = 1'b1;
bitmap_rom[1039] = 1'b1;
bitmap_rom[1040] = 1'b1;
bitmap_rom[1103] = 1'b1;
bitmap_rom[1104] = 1'b1;
bitmap_rom[1042] = 1'b1;
bitmap_rom[1043] = 1'b1;
bitmap_rom[1106] = 1'b1;
bitmap_rom[1107] = 1'b1;
bitmap_rom[1932] = 1'b1;
bitmap_rom[1933] = 1'b1;
bitmap_rom[1935] = 1'b1;
bitmap_rom[1936] = 1'b1;
bitmap_rom[1938] = 1'b1;
bitmap_rom[1939] = 1'b1;
bitmap_rom[1996] = 1'b1;
bitmap_rom[1997] = 1'b1;
bitmap_rom[1999] = 1'b1;
bitmap_rom[2000] = 1'b1;
bitmap_rom[2002] = 1'b1;
bitmap_rom[2003] = 1'b1;
bitmap_rom[2124] = 1'b1;
bitmap_rom[2125] = 1'b1;
bitmap_rom[2188] = 1'b1;
bitmap_rom[2189] = 1'b1;
bitmap_rom[2127] = 1'b1;
bitmap_rom[2128] = 1'b1;
bitmap_rom[2191] = 1'b1;
bitmap_rom[2192] = 1'b1;
bitmap_rom[2130] = 1'b1;
bitmap_rom[2131] = 1'b1;
bitmap_rom[2194] = 1'b1;
bitmap_rom[2195] = 1'b1;
bitmap_rom[2316] = 1'b1;
bitmap_rom[2317] = 1'b1;
bitmap_rom[2380] = 1'b1;
bitmap_rom[2381] = 1'b1;
bitmap_rom[2319] = 1'b1;
bitmap_rom[2320] = 1'b1;
bitmap_rom[2383] = 1'b1;
bitmap_rom[2384] = 1'b1;
bitmap_rom[2322] = 1'b1;
bitmap_rom[2323] = 1'b1;
bitmap_rom[2386] = 1'b1;
bitmap_rom[2387] = 1'b1;
  
end

// VGA DRIVER
wire active_pixels; // is on when we're in the active draw space
wire frame_done;

wire [9:0]x; // current x
wire [9:0]y; // current y - 10 bits = 1024 ... a little bit more than we need

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

/* -------------------------------- */
/* MEMORY to STORE a MINI frambuffer.  Problem is the FPGA's on-chip memory can't hold an entire frame, so some
form of compression is needed.  I show a simple compress the image to 16 pixels or a 4 by 4, but this memory
could handle more */
reg [14:0] frame_buf_mem_address;
reg [23:0] frame_buf_mem_data;
reg frame_buf_mem_wren;
wire [23:0]frame_buf_mem_q;

  
vga_frame vga_memory(
	frame_buf_mem_address,
	clk,
	frame_buf_mem_data,
	frame_buf_mem_wren,
	frame_buf_mem_q);



/* -------------------------------- */
/* 	FSM to control the writing to the framebuffer and the reading of it.
	I make a 4x4 pixel map in memory.  Then as I read this info I display it 
	noting that the VGA draws in rows, so I have to make sure the right data
	is loaded.  Note, that some of these parameters can be increased. */
reg [15:0]i;
reg [7:0]j;
reg [7:0]offCount;
reg [7:0]jCount;
//looks to see if there is a black space left or above the current spot
reg [0:0]blkx;

reg [2:0]packedColor;
reg [7:0]S;
reg [7:0]NS;

parameter 
	START = 8'd0,
	W2M_INIT = 8'd1, // Write 2 Memory init - this is a FOR loop
	W2M_COND = 8'd2, // Write 2 Memory condion
	W2M_INC = 8'd3, // Write 2 Memory incrementer
	RFM_INIT = 8'd4, // Read From Memory init
	RFM_DRAWING = 8'd5, // Read From Memory draw step
	ERROR = 8'hFF;

parameter LOOP_SIZE = 16'd3072;
parameter LOOP_I_SIZE = 16'd64;
parameter LOOP_Y_SIZE = 16'd48;
parameter WIDTH = 16'd640;
parameter HEIGHT = 16'd480;
parameter PIXELS_IN_WIDTH = WIDTH/LOOP_I_SIZE; // 160
parameter PIXELS_IN_HEIGHT = HEIGHT/LOOP_Y_SIZE; // 120
//reg pattern_mem [0:LOOP_SIZE-1];


/* Calculate NS */
always @(*)
	case (S)
		START: NS = W2M_INIT;
		W2M_INIT: NS = W2M_COND;
		W2M_COND:
			if (i < LOOP_SIZE)
				NS = W2M_INC;
			else
				NS = RFM_INIT;
		W2M_INC: NS = W2M_COND;
		RFM_INIT: 
			if (frame_done == 1'b0)
				NS = RFM_DRAWING;
			else	
				NS = RFM_INIT;
		RFM_DRAWING:
			if (frame_done == 1'b1)
				NS = RFM_INIT;
			else
				NS = RFM_DRAWING;
		default:	NS = ERROR;
	endcase

	
always @(posedge clk or negedge rst)
begin
	if (rst == 1'b0)
	begin
			S <= START;
	end
	else
	begin
			S <= NS;
	end
end

/* 
The code goes through a write phase (after reset) and an endless read phase once writing is done.

The W2M (write to memory) code is roughly:
for (i = 0; i < 16; i++)
	mem[i] = color // where color is a shade of FF/16 * i if switch is on SW[2:0] for {R, G, B}

The RFM (read from memory) is synced with the VGA display which goes row by row
for (i = 0; i < 480; i++) // height
	for (j = 0; j < 640; j++) // width
		color = mem[(i/120 * 4) + j/160] OR just use x, y coming from vga_driver
		
I later simplified and just used the x and y coming from the vga_driver and used it to calculate the memory load.
		
*/

always @(posedge clk or negedge rst)
begin
	if (rst == 1'b0)
	begin
		frame_buf_mem_address <= 14'd0;
		frame_buf_mem_data <= 24'd0;
		frame_buf_mem_wren <= 1'd0;
		i <= 16'd0;
		
	end
	else
	begin
		case (S)
			START:
			begin
				frame_buf_mem_address <= 14'd0;
				frame_buf_mem_data <= 24'd0;
				frame_buf_mem_wren <= 1'd0;
				i <= 16'd0;
			end
			W2M_INIT:
			begin
				frame_buf_mem_address <= 14'd0;
				frame_buf_mem_data <= 24'd0;
				frame_buf_mem_wren <= 1'd1;
				i <= 16'd0;
			end
			W2M_COND:
			begin
			end
			W2M_INC: 
			begin
				i <= i + 1'b1;
				frame_buf_mem_address <= frame_buf_mem_address + 1'b1;
				frame_buf_mem_data <= {red, green, blue}; // done in the combinational part below
			end
			RFM_INIT: 
			begin
				frame_buf_mem_wren <= 1'd0; // turn off writing to memory
				// y and x come from the vga_driver module as it progresses through the drawing of the page
				if (y < HEIGHT && x < WIDTH)
					frame_buf_mem_address <= (y/PIXELS_IN_HEIGHT) * LOOP_I_SIZE + (x/PIXELS_IN_WIDTH);
			end
			RFM_DRAWING:
			begin
				// y and x come from the vga_driver module as it progresses through the drawing of the page
				if (y < HEIGHT && x < WIDTH)
					frame_buf_mem_address <= (y/PIXELS_IN_HEIGHT) * LOOP_I_SIZE + (x/PIXELS_IN_WIDTH);
			end	
		endcase
	end
end

reg [7:0]red;
reg [7:0]green;
reg [7:0]blue;

always @(*) begin
	if(i==0)begin
	j=8'b0;
	end

    // Reading phase → output memory contents
    if (S == RFM_INIT || S == RFM_DRAWING)
        {VGA_R, VGA_G, VGA_B} = frame_buf_mem_q;
    else
        {VGA_R, VGA_G, VGA_B} = 24'h000000; // black during write phase


    // Writing phase: check bitmap for each block
	 
    if(bitmap_rom[i]==1'b1) begin
	 if (offCount>=64 && offCount<=128) begin
	     offCount=8'b0;
		  j = j-jCount;
		  jCount=0;
		  end
        packedColor[0]=color[j];
        packedColor[1]=color[j+1];
        packedColor[2]=color[j+2];
		 if(blkx) begin
        blkx = 1'b0;
		  j = j+3;
		  jCount = jCount+3;
		  end 
		  if(packedColor == 3'b000)begin
		  red   = 8'hFF;
		  green = 8'hFF;
		  blue  = 8'hFF;
		  end else if (packedColor == 3'b001)begin
		  red   = 8'hFF;
		  green = 8'h40;
		  blue  = 8'h00;
		  end else if (packedColor == 3'b010)begin
		  red   = 8'h00;
		  green = 8'hFF;
		  blue  = 8'h00;
		  end else if (packedColor == 3'b011)begin
		  red   = 8'hFF;
		  green = 8'h00;
		  blue  = 8'h00;
		  end else if (packedColor == 3'b100)begin
		  red   = 8'h00;
		  green = 8'h00;
		  blue  = 8'hFF;
		  end else if (packedColor == 3'b101)begin
		  red   = 8'hFF;
		  green = 8'hFF;
		  blue  = 8'h00;
		  end else begin
		  red   = 8'hFF;
		  green = 8'h00;
		  blue  = 8'hFF;
		  end
    end
    else begin
        // Block is "off"
		  offCount = offCount+1;
		  blkx = 1'b1;
        red   = 8'h00;
        green = 8'h00;
        blue  = 8'h00;
		  
    end

end



endmodule


