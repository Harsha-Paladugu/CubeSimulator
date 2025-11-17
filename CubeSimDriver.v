module cubeSimDriver (

	//////////// CLOCK //////////
	input 		          		CLOCK_50,

	//////////// SEG7 //////////
	output		     [6:0]		HEX0,
	output		     [6:0]		HEX1,
	output		     [6:0]		HEX2,
	output		     [6:0]		HEX3,

	//////////// KEY //////////
	input 		     [3:0]		KEY,

	//////////// LED //////////
	output		     [9:0]		LEDR,

	//////////// SW //////////
	input 		     [5:0]		SW
);

wire [5:0] faceInput;
	
assign faceInput = SW[8:0];

reg done;
assign LEDR[3:0] = {start, rst, clk, done};
assign LEDR[5:4] = display_control;
assign LEDR[9:6] = S;

wire clk;
assign clk = CLOCK_50;
wire rst;
assign rst = KEY[3];
wire start;
assign start = ~KEY[2];
wire [1:0]rotationControl; // {0 = cw, 1 = ccw, 2 = double}
assign rotationControl = KEY[1:0];

endmodule