//==============================================================
// CubeSimDriver (with one-shot buttons for MOVE and SCRAMBLE)
//==============================================================
module CubeSimDriver (
    //////////// CLOCK //////////
    input               CLOCK_50,

    //////////// SEG7 //////////
    output      [6:0]   HEX0,
    output      [6:0]   HEX1,
    output      [6:0]   HEX2,
    output      [6:0]   HEX3,

    //////////// KEY //////////
    input       [3:0]   KEY,

    //////////// LED //////////
    output      [9:0]   LEDR,

    //////////// SW //////////
    input       [5:0]   SW,
	 
	 	//////////// VGA //////////
	output		          		VGA_BLANK_N,
	output	     [7:0]		VGA_B,
	output		          		VGA_CLK,
	output	     [7:0]		VGA_G,
	output		          		VGA_HS,
	output	     [7:0]		VGA_R,
	output		          		VGA_SYNC_N,
	output		          		VGA_VS
);

    // ------------------------
    // Basic signals
    // ------------------------
    wire clk   = CLOCK_50;
    wire rst = KEY[3];   // active-low reset from KEY3

    // Manual face selection: SW[5:3] -> 0..5
    wire [2:0] faceSelect      = SW[5:3];
    // Manual rotation selection: SW[1:0]
    wire [1:0] rotationControl = SW[1:0];
    // Expand face to 6 bits to feed cubeState
    wire [5:0] faceInput       = {3'b000, faceSelect};

    // ------------------------
    // One-shot button logic
    // ------------------------
    // We want *one clock pulse* per press, not "high as long as button is held".
    // Buttons are active-low on the board, so we invert them to get active-high inside.

    // Raw (asynchronous) active-high button signals
    wire scramble_raw = ~KEY[2];  // KEY2: scramble
    wire move_raw     = ~KEY[1];  // KEY1: manual move

    // Synchronizers + edge detectors
    reg scramble_ff0, scramble_ff1;
    reg move_ff0,     move_ff1;

    // Synchronize button signals to clk and create 1-clock pulses on rising edge
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            scramble_ff0 <= 1'b0;
            scramble_ff1 <= 1'b0;
            move_ff0     <= 1'b0;
            move_ff1     <= 1'b0;
        end else begin
            scramble_ff0 <= scramble_raw;
            scramble_ff1 <= scramble_ff0;
            move_ff0     <= move_raw;
            move_ff1     <= move_ff0;
        end
    end

    // Rising edge detection: "new press" = current high & previous low
    wire scramble_pulse = scramble_ff0 & ~scramble_ff1;  // 1 clock tick per press
    wire move_pulse     = move_ff0     & ~move_ff1;      // 1 clock tick per press

    // ------------------------
    // FSM state encoding
    // ------------------------
    reg  [6:0] S, NS;

    localparam START    = 7'd0,
               DISPLAY  = 7'd1,
               SCRAMBLE = 7'd2,
               MOVE     = 7'd3,
               SOLVE    = 7'd4,
               VERIFY   = 7'd5,
               DONE     = 7'd6;

    // ------------------------
    // Cube state (flattened)
    // ------------------------
    reg  [161:0] cubeFlat;       // current cube
    wire [161:0] cubeFlatNext;   // cube after applying move

    // ------------------------
    // Rotation count (quarter turns)
    // ------------------------
    reg [2:0] rotCount;  // 0=none,1=CW,2=double,3=CCW

    always @(*) begin
        case (rotationControl)
            2'b00: rotCount = 3'd0; // no move
            2'b01: rotCount = 3'd1; // CW
            2'b10: rotCount = 3'd3; // CCW (3 CW turns)
            2'b11: rotCount = 3'd2; // double
            default: rotCount = 3'd0;
        endcase
    end

    // ------------------------
    // Random move generator
    // ------------------------
    wire [2:0] randFace;
    wire [1:0] randRot;

    moveGenerator rng (
        .clk         (clk),
        .rst         (rst),   // if your RNG expects active-high reset, use ~rst
        .nextFace    (randFace),
        .nextRotation(randRot)
    );

    // ------------------------
    // Current move selection (manual vs random)
    // ------------------------
    reg [5:0] curFace;
    reg [2:0] curRotCount;

    // During SCRAMBLE: use RNG
    // Otherwise: use switches
    always @(*) begin
        // default: manual move
        curFace     = faceInput;
        curRotCount = rotCount;

        case (S)
            SCRAMBLE: begin
                curFace = {3'b000, randFace};
                case (randRot)
                    2'd0: curRotCount = 3'd1; // CW
                    2'd1: curRotCount = 3'd3; // CCW
                    2'd2: curRotCount = 3'd2; // double
                    default: curRotCount = 3'd0;
                endcase
            end
            default: ; // keep manual settings
        endcase
    end

    // ------------------------
    // Move engine
    // ------------------------
    cubeState turnCube (
        .nextFaceMove (curFace),
        .nextRotation (curRotCount),
        .cubeState    (cubeFlat),
        .cubeStateNew (cubeFlatNext)
    );

    // ------------------------
    // moveCount & scrambleCount
    // ------------------------
    reg [5:0] scrambleCount;    // 0..30
    reg [9:0] moveCount;        // 0..999 (enough for display)

    // ------------------------
    // Seven-segment for moveCount
    // ------------------------
    wire [3:0] onesDigit     =  moveCount        % 10;
    wire [3:0] tensDigit     = (moveCount / 10)  % 10;
    wire [3:0] hundredsDigit = (moveCount / 100) % 10;

    seven_segment OneDigitDisplay (
        .SW   (onesDigit),
        .HEX0 (HEX0)
    );

    seven_segment TenDigitDisplay (
        .SW   (tensDigit),
        .HEX0 (HEX1)
    );

    seven_segment HundredDigitDisplay (
        .SW   (hundredsDigit),
        .HEX0 (HEX2)
    );

    assign HEX3 = 7'b111_1111;  // off
	 
	 vga_Top printCube (
	 .clk(clk),
	 .color(cubeFlat),
	 .rst(rst),
	 .VGA_BLANK_N(VGA_BLANK_N),
	 .VGA_B(VGA_B),
	 .VGA_CLK(VGA_CLK),
	 .VGA_G(VGA_G),
	 .VGA_HS(VGA_HS),
	 .VGA_R(VGA_R),
	 .VGA_SYNC_N(VGA_SYNC_N),
	 .VGA_VS(VGA_VS)
	 );
	 
	 

    // ------------------------
    // Solved detection stub
    // ------------------------
    wire isSolved = 1'b0;       // TODO: implement real checker later

    // ------------------------
    // Sequential: state + cubeFlat + counts
    // ------------------------
    integer i;

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            S             <= START;
            cubeFlat      <= 162'd0;
            scrambleCount <= 6'd0;
            moveCount     <= 10'd0;
        end else begin
            S <= NS;

            case (S)
                // Initialize solved cube
                START: begin
                    for (i = 0; i < 54; i = i + 1) begin
                        if      (i < 9)   cubeFlat[3*i +: 3] <= 3'b000; // face 0
                        else if (i < 18)  cubeFlat[3*i +: 3] <= 3'b001; // face 1
                        else if (i < 27)  cubeFlat[3*i +: 3] <= 3'b010; // face 2
                        else if (i < 36)  cubeFlat[3*i +: 3] <= 3'b011; // face 3
                        else if (i < 45)  cubeFlat[3*i +: 3] <= 3'b100; // face 4
                        else              cubeFlat[3*i +: 3] <= 3'b101; // face 5
                    end
                    scrambleCount <= 6'd0;
                    moveCount     <= 10'd0;
                end

                // Scramble: one random move per clock until 30 moves done
                SCRAMBLE: begin
                    cubeFlat      <= cubeFlatNext;
                    scrambleCount <= scrambleCount + 6'd1;
                    // moveCount unchanged here
                end

                // Manual MOVE: apply one manual move
                MOVE: begin
                    cubeFlat <= cubeFlatNext;
                    if (moveCount != 10'd999)
                        moveCount <= moveCount + 10'd1;
                end

                // Other states: hold values
                default: begin
                    cubeFlat      <= cubeFlat;
                    scrambleCount <= scrambleCount;
                    moveCount     <= moveCount;
                end
            endcase
        end
    end

    // ------------------------
    // Next-state logic
    // ------------------------
    reg done;

    always @(*) begin
        NS   = S;
        done = 1'b0;

        case (S)
            START: begin
                NS = DISPLAY;
            end

            // Idle / display state:
            //   - scramble_pulse: do one 30-move scramble
            //   - move_pulse    : apply one manual move
            DISPLAY: begin
                if (scramble_pulse)
                    NS = SCRAMBLE;
                else if (move_pulse)
                    NS = MOVE;
                else
                    NS = DISPLAY;
            end

            // Scramble for exactly 30 moves, then back to DISPLAY
            SCRAMBLE: begin
                if (scrambleCount == 6'd29)
                    NS = DISPLAY;
                else
                    NS = SCRAMBLE;
            end

            // Single manual move, then back to DISPLAY
            MOVE: begin
                NS = DISPLAY;
            end

            SOLVE: begin
                NS = MOVE;
            end

            VERIFY: begin
                if (isSolved)
                    NS = DONE;
                else
                    NS = DISPLAY;
            end

            DONE: begin
                done = 1'b1;
                NS   = DONE;
            end

            default: begin
                NS = START;
            end
        endcase
    end

    // ------------------------
    // Debug LEDs
    // ------------------------
    assign LEDR[6:0] = S;        // show FSM state
    assign LEDR[9:7] = 3'b000;

endmodule
