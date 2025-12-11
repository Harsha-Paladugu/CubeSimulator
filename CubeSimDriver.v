module CubeSimDriver (
    // CLOCK
    input               CLOCK_50,

    // 7-SEG
    output      [6:0]   HEX0,
    output      [6:0]   HEX1,
    output      [6:0]   HEX2,
    output      [6:0]   HEX4,
    output      [6:0]   HEX5,

    // BUTTONS
    input       [3:0]   KEY,

    // LEDS
    output      [9:0]   LEDR,

    // SWITCHES (now 10 bits so SW[9:7] is valid)
    input       [9:0]   SW,
	 
    // VGA
    output              VGA_BLANK_N,
    output      [7:0]   VGA_B,
    output              VGA_CLK,
    output      [7:0]   VGA_G,
    output              VGA_HS,
    output      [7:0]   VGA_R,
    output              VGA_SYNC_N,
    output              VGA_VS
);

    //================================================================
    // BASIC SIGNALS
    //================================================================
    wire clk = CLOCK_50;
    wire rst = KEY[3];  // active-low

    // Face SW selection: top 3 switches
    wire [2:0] faceSelect      = SW[9:7];
    // Rotation selection: bottom 2 switches
    wire [1:0] rotationControl = SW[1:0];
    wire [5:0] faceInput       = {3'b000, faceSelect};

    //================================================================
    // ONE-SHOT BUTTON INPUTS
    //================================================================
    wire scramble_raw = ~KEY[2];
    wire move_raw     = ~KEY[1];
    wire undo_raw     = ~KEY[0];

    reg scramble_ff0, scramble_ff1;
    reg move_ff0,     move_ff1;
    reg undo_ff0,     undo_ff1;

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            scramble_ff0 <= 0; scramble_ff1 <= 0;
            move_ff0     <= 0; move_ff1     <= 0;
            undo_ff0     <= 0; undo_ff1     <= 0;
        end else begin
            scramble_ff0 <= scramble_raw;
            scramble_ff1 <= scramble_ff0;

            move_ff0     <= move_raw;
            move_ff1     <= move_ff0;

            undo_ff0     <= undo_raw;
            undo_ff1     <= undo_ff0;
        end
    end

    wire scramble_pulse = scramble_ff0 & ~scramble_ff1;
    wire move_pulse     = move_ff0     & ~move_ff1;
    wire undo_pulse     = undo_ff0     & ~undo_ff1;

    //================================================================
    // FSM
    //================================================================
    reg [6:0] S, NS;

    localparam START    = 7'd0,
               DISPLAY  = 7'd1,
               SCRAMBLE = 7'd2,
               MOVE     = 7'd3,
               VERIFY   = 7'd5,   // unused now but kept for safety
               DONE     = 7'd6;

    //================================================================
    // CUBE STATE + MULTI-UNDO STACK
    //================================================================
    reg  [161:0] cubeFlat;         // current state
    wire [161:0] cubeFlatNext;     // output of cubeState

    // MULTI-UNDO HISTORY STACK (64 entries)
    reg  [161:0] history [0:63];
    reg  [5:0]   histPtr;          // points to next free slot

    // solved flag
    reg isSolved;

    // SOLVED pattern that matches START initialization
    localparam [161:0] SOLVED_CUBE = {
        {9{3'b101}},  // Face 5 (indices 45–53)
        {9{3'b100}},  // Face 4 (36–44)
        {9{3'b011}},  // Face 3 (27–35)
        {9{3'b010}},  // Face 2 (18–26)
        {9{3'b001}},  // Face 1 (9–17)
        {9{3'b000}}   // Face 0 (0–8)
    };

    wire solvedNow = (cubeFlat == SOLVED_CUBE);

    //================================================================
    // ROTATION SELECTION
    //================================================================
    reg [2:0] rotCount;

    always @(*) begin
        case (rotationControl)
            2'b01: rotCount = 3'd1; // CW
            2'b10: rotCount = 3'd3; // CCW
            2'b11: rotCount = 3'd2; // double
            default: rotCount = 3'd0; // none
        endcase
    end

    //================================================================
    // RANDOM MOVE GENERATOR
    //================================================================
    wire [2:0] randFace;
    wire [1:0] randRot;

    moveGenerator rng (
        .clk(clk),
        .rst(rst),
        .nextFace(randFace),
        .nextRotation(randRot)
    );

    //================================================================
    // SELECT MOVE SOURCE (MANUAL OR SCRAMBLE)
    //================================================================
    reg [5:0] curFace;
    reg [2:0] curRotCount;

    always @(*) begin
        curFace     = faceInput;
        curRotCount = rotCount;

        if (S == SCRAMBLE) begin
            curFace = {3'b000, randFace};
            case (randRot)
                2'd0: curRotCount = 3'd1;
                2'd1: curRotCount = 3'd3;
                2'd2: curRotCount = 3'd2;
                default: curRotCount = 3'd0;
            endcase
        end
    end

    //================================================================
    // MOVE ENGINE
    //================================================================
    cubeState turnCube (
        .nextFaceMove(curFace),
        .nextRotation(curRotCount),
        .cubeState(cubeFlat),
        .cubeStateNew(cubeFlatNext)
    );

    //================================================================
    // COUNTERS
    //================================================================
    reg [5:0] scrambleCount; 
    reg [9:0] moveCount;

    //================================================================
    // 7-SEGMENT DISPLAY
    //================================================================
    wire [3:0] onesDigit     =  moveCount        % 10;
    wire [3:0] tensDigit     = (moveCount / 10)  % 10;
    wire [3:0] hundredsDigit =  moveCount        % 100; // not true hundreds digit but OK

    wire [3:0] faceDigit = {1'b0, faceSelect};
    wire [3:0] rotDigit  = {1'b0, rotCount};

    seven_segment      d0 (.SW(onesDigit),     .HEX0(HEX0));
    seven_segment      d1 (.SW(tensDigit),     .HEX0(HEX1));
    seven_segment      d2 (.SW(hundredsDigit), .HEX0(HEX2));

    seven_segment_move rotDisp  (.SW(rotDigit + 10), .HEX0(HEX4));
    seven_segment_move faceDisp (.SW(faceDigit),     .HEX0(HEX5));
	 
    //================================================================
    // VGA RENDERER
    //================================================================
    vga_Top printCube (
        .clk(clk),
        .color(cubeFlat),
        .rst(rst),
        .solved(isSolved),
        .VGA_BLANK_N(VGA_BLANK_N),
        .VGA_B(VGA_B),
        .VGA_CLK(VGA_CLK),
        .VGA_G(VGA_G),
        .VGA_HS(VGA_HS),
        .VGA_R(VGA_R),
        .VGA_SYNC_N(VGA_SYNC_N),
        .VGA_VS(VGA_VS)
    );

    //================================================================
    // SEQUENTIAL LOGIC (STATE + MOVES + UNDO STACK)
    //================================================================
    integer i;
	 
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            S             <= START;
            cubeFlat      <= 162'd0;
            scrambleCount <= 0;
            moveCount     <= 0;
            histPtr       <= 0;
            isSolved      <= 1'b0;
        end else begin
            S <= NS;

            case (S)

                //------------------------------------------------------
                // INIT (SOLVED)
                //------------------------------------------------------
                START: begin
                    for (i = 0; i < 54; i = i + 1) begin
                        if      (i < 9)   cubeFlat[3*i +: 3] <= 3'b000;
                        else if (i < 18)  cubeFlat[3*i +: 3] <= 3'b001;
                        else if (i < 27)  cubeFlat[3*i +: 3] <= 3'b010;
                        else if (i < 36)  cubeFlat[3*i +: 3] <= 3'b011;
                        else if (i < 45)  cubeFlat[3*i +: 3] <= 3'b100;
                        else              cubeFlat[3*i +: 3] <= 3'b101;
                    end
                    histPtr       <= 0;
                    scrambleCount <= 0;
                    moveCount     <= 0;
                    isSolved      <= 1'b0;
                end

                //------------------------------------------------------
                // SCRAMBLE MODE
                //------------------------------------------------------
                SCRAMBLE: begin
                    cubeFlat      <= cubeFlatNext;
                    scrambleCount <= scrambleCount + 1;
                    moveCount     <= 0;
                    isSolved      <= 1'b0;
                end

                //------------------------------------------------------
                // MANUAL MOVE (PUSH ONTO UNDO STACK)
                //------------------------------------------------------
                MOVE: begin
                    if (histPtr < 63) begin
                        history[histPtr] <= cubeFlat;
                        histPtr          <= histPtr + 1;
                    end

                    cubeFlat <= cubeFlatNext;

                    if (moveCount != 999 && curRotCount > 0)
                        moveCount <= moveCount + 1;
                end

                //------------------------------------------------------
                // DISPLAY MODE (UNDO POPS STACK)
                //------------------------------------------------------
                DISPLAY: begin
                    if (undo_pulse && histPtr > 0) begin
                        histPtr   <= histPtr - 1;
                        cubeFlat  <= history[histPtr - 1];
                        if (moveCount > 0)
                            moveCount <= moveCount - 1;
                    end
                    // isSolved is only asserted in DONE
                end

                //------------------------------------------------------
                // DONE: hold solved flag
                //------------------------------------------------------
                DONE: begin
                    isSolved <= 1'b1;
                end

                default: begin
                    // no-op
                end
            endcase
        end
    end

    //================================================================
    // NEXT STATE LOGIC
    //================================================================
    always @(*) begin
        case (S)

            START:
                NS = DISPLAY;

            DISPLAY: begin
                if (scramble_pulse)
                    NS = SCRAMBLE;
                else if (move_pulse)
                    NS = MOVE;
                // only go to DONE if solved AND we've actually done something
                else if (solvedNow && (moveCount != 0 || scrambleCount != 0))
                    NS = DONE;
                else
                    NS = DISPLAY;
            end

            SCRAMBLE:
                NS = (scrambleCount == 6'd3) ? DISPLAY : SCRAMBLE;

            MOVE:
                NS = DISPLAY;       // always go back to DISPLAY first

            DONE:
                NS = DONE;          // stay in solved screen until reset

            default:
                NS = START;
        endcase
    end

    //================================================================
    // DEBUG LEDS
    //================================================================
    assign LEDR[6:0] = S;
    assign LEDR[9:7] = 3'b000;

endmodule
