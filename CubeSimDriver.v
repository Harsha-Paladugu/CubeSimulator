//==============================================================
// CubeSimDriver
// Top-level FSM to drive a Rubik's cube state machine on DE1-SoC
//
// - Uses a simple FSM with states: START, DISPLAY, SCRAMBLE, MOVE, etc.
// - Initializes cube to solved state on reset
// - Can perform a 30-move random scramble
// - Can apply manual moves selected by switches
// - Tracks and displays the number of manual moves on HEX0–HEX2
//
// Button / Switch mapping (as implemented here):
//   KEY[3]  : Active-low reset (hold to reset, release to run)
//   KEY[2]  : Start scramble (active-low: press to start 30 random moves)
//   KEY[1]  : Apply one manual move (active-low: press to apply current SW move)
//   KEY[0]  : UNUSED (you can repurpose later)
//
//   SW[5:3] : Face selection for manual move (0–5)  -> mapped into curFace
//   SW[2:0] : You can ignore or repurpose bits not used as faceSelect; here we
//             only use SW[5:3] for face and SW[1:0] for rotation:
//   SW[1:0] : Rotation selection for manual move:
//               2'b00 = no move
//               2'b01 = CW        (1 quarter turn)
//               2'b10 = CCW       (3 CW quarter turns)
//               2'b11 = double    (2 quarter turns)
//
// Display mapping:
//   HEX0    : Ones digit of moveCount (0–9)
//   HEX1    : Tens digit of moveCount
//   HEX2    : Hundreds digit of moveCount
//   HEX3    : Turned off (all segments off)
//   LEDR[6:0] : Shows current FSM state encoding (for debugging)
//   LEDR[9:7] : Zero (unused)
//
// NOTE: This file assumes you already have these modules defined:
//   - moveGenerator  : produces random faces and rotations
//   - cubeState      : takes a cube state + move and returns next state
//   - seven_segment  : converts a 4-bit value (0–9) to 7-seg pattern
//
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
    input       [5:0]   SW
);

    // ------------------------
    // Basic signals & controls
    // ------------------------
    wire clk   = CLOCK_50;

    // KEY[3] is wired as active-low reset:
    //   Pressing KEY3 -> rst_n = 0 -> asynchronous reset asserted
    //   Releasing KEY3 -> rst_n = 1 -> normal operation
    wire rst_n = KEY[3];

    // Scramble button: KEY[2] active-low
    //   Press KEY2 to start a 30-move random scramble
    wire scrambleBtn = ~KEY[2];

    // Manual move button: KEY[1] active-low
    //   Press KEY1 to apply one manual move selected by SW
    wire doMoveBtn   = ~KEY[1];

    // Manual move selection:
    //   Use top 3 switches (SW[5:3]) for face index 0..5
    //   Use bottom 2 switches (SW[1:0]) for rotation control
    wire [2:0] faceSelect      = SW[5:3];          // 3 bits -> face 0..5
    wire [1:0] rotationControl = SW[1:0];          // 2 bits -> rotation encoding
    wire [5:0] faceInput       = {3'b000, faceSelect}; // expand to 6-bit face

    // Count of manual moves applied in MOVE state (0..999 shown)
    integer moveCount;

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
    // 54 stickers * 3 bits per sticker = 162 bits
    // cubeFlat[3*i +: 3] corresponds to sticker i
    reg  [161:0] cubeFlat;       // current cube state
    wire [161:0] cubeFlatNext;   // cube after applying the current move

    // ------------------------
    // Rotation count (quarter turns) for manual/random moves
    // ------------------------
    // rotCount represents how many quarter turns in CW direction:
    //   0 = no move
    //   1 = 90° CW
    //   2 = 180° (double turn)
    //   3 = 270° CW (i.e., 90° CCW)
    reg [2:0] rotCount;  // 0..3

    // Map 2-bit rotationControl from switches into rotCount
    always @(*) begin
        case (rotationControl)
            2'b00: rotCount = 3'd0; // no move (used as "do nothing" if you hit MOVE)
            2'b01: rotCount = 3'd1; // 90° CW
            2'b10: rotCount = 3'd3; // 90° CCW = 3 CW quarter turns
            2'b11: rotCount = 3'd2; // 180° double turn
            default: rotCount = 3'd0;
        endcase
    end

    // ------------------------
    // Random move generator
    // ------------------------
    // moveGenerator must produce:
    //   randFace: 3-bit face index (0..5)
    //   randRot : 2-bit rotation selector (0,1,2) -> we convert to quarter turns
    wire [2:0] randFace;
    wire [1:0] randRot;

    moveGenerator rng (
        .clk         (clk),
        .rst         (rst_n),       // NOTE: if moveGenerator expects active-high reset,
                                    //       you may need to invert this (use ~rst_n instead).
        .nextFace    (randFace),    // 0..5
        .nextRotation(randRot)      // 0=CW, 1=CCW, 2=double
    );

    // ------------------------
    // Current move selection (manual vs random)
    // ------------------------
    reg [5:0] curFace;       // 6-bit face index for cubeState
    reg [2:0] curRotCount;   // 3-bit quarter-turn count

    // ------------------------
    // Scramble counter (30 random moves)
    // ------------------------
    // We will perform EXACTLY 30 random moves during SCRAMBLE.
    reg [5:0] scrambleCount; // 0..30

    // ------------------------
    // Move engine (combinational cube transformer)
    // ------------------------
    cubeState turnCube (
        .nextFaceMove (curFace),      // which face to turn (0..5)
        .nextRotation (curRotCount),  // how many quarter turns
        .cubeState    (cubeFlat),     // current cube
        .cubeStateNew (cubeFlatNext)  // resulting cube
    );

    // ------------------------
    // Seven-segment displays for moveCount
    // ------------------------
    // Convert moveCount (integer) into 3 decimal digits: ones, tens, hundreds
    wire [3:0] onesDigit;
    wire [3:0] tensDigit;
    wire [3:0] hundredsDigit;

    assign onesDigit     = moveCount % 10;
    assign tensDigit     = (moveCount / 10)  % 10;
    assign hundredsDigit = (moveCount / 100) % 10;

    // Each seven_segment instance expects a 4-bit input (0..9) and drives a HEX display
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

    // Turn off HEX3 for now (all segments off or all on depending on your decoder convention).
    // Adjust this if your seven_segment expects active-low vs active-high.
    assign HEX3 = 7'b111_1111;

    // ------------------------
    // Stub for solved detection
    // ------------------------
    // Right now, we don't have a real "is solved?" detector.
    // This is a placeholder. When you implement solved detection, wire it here.
    wire isSolved;
    assign isSolved = 1'b0;

    // ------------------------
    // Choose move source based on FSM state
    // ------------------------
    // In DISPLAY and MOVE states: use manual move from switches.
    // In SCRAMBLE state: use random face + random rotation.
    always @(*) begin
        // Default: manual move from switches (for DISPLAY/MOVE)
        curFace     = faceInput;
        curRotCount = rotCount;

        case (S)
            SCRAMBLE: begin
                // During SCRAMBLE we ignore the switches and use RNG
                curFace = {3'b000, randFace};  // expand 3-bit random face into 6 bits

                // Convert randRot (0,1,2) into quarter-turn counts
                case (randRot)
                    2'd0: curRotCount = 3'd1; // CW
                    2'd1: curRotCount = 3'd3; // CCW (3 CW turns)
                    2'd2: curRotCount = 3'd2; // double turn
                    default: curRotCount = 3'd0;
                endcase
            end

            default: begin
                // DISPLAY, MOVE, VERIFY, etc. → use manual move (already set)
            end
        endcase
    end

    // ------------------------
    // Sequential logic: state, cubeFlat, scrambleCount, moveCount
    // ------------------------
    integer i;  // loop index for initialization

    always @(posedge clk or negedge rst_n) begin
        // Asynchronous active-low reset
        if (!rst_n) begin
            S             <= START;
            cubeFlat      <= 162'd0;
            scrambleCount <= 6'd0;
            moveCount     <= 0;
        end else begin
            // State update
            S <= NS;

            case (S)
                // -------------------------------------------------
                // START: one-time initialization of a solved cube
                // -------------------------------------------------
                START: begin
                    // Initialize cubeFlat to a solved cube configuration
                    // Faces:
                    //   0: stickers  0.. 8 -> color 000
                    //   1: stickers  9..17 -> color 001
                    //   2: stickers 18..26 -> color 010
                    //   3: stickers 27..35 -> color 011
                    //   4: stickers 36..44 -> color 100
                    //   5: stickers 45..53 -> color 101
                    for (i = 0; i < 54; i = i + 1) begin
                        if (i < 9)       cubeFlat[3*i +: 3] <= 3'b000; // face 0
                        else if (i < 18) cubeFlat[3*i +: 3] <= 3'b001; // face 1
                        else if (i < 27) cubeFlat[3*i +: 3] <= 3'b010; // face 2
                        else if (i < 36) cubeFlat[3*i +: 3] <= 3'b011; // face 3
                        else if (i < 45) cubeFlat[3*i +: 3] <= 3'b100; // face 4
                        else             cubeFlat[3*i +: 3] <= 3'b101; // face 5
                    end
                    scrambleCount <= 6'd0;
                    moveCount     <= 0;
                end

                // -------------------------------------------------
                // SCRAMBLE: apply one random move per clock
                // -------------------------------------------------
                SCRAMBLE: begin
                    // Apply one random move each cycle while in SCRAMBLE
                    cubeFlat      <= cubeFlatNext;
                    scrambleCount <= scrambleCount + 6'd1;
                    // moveCount is not changed during scramble
                end

                // -------------------------------------------------
                // MOVE: apply one manual move from switches
                // -------------------------------------------------
                MOVE: begin
                    // Apply one manual move (faceInput + rotCount)
                    cubeFlat  <= cubeFlatNext;
                    moveCount <= moveCount + 1;
                end

                // -------------------------------------------------
                // Other states: hold current cube & counters
                // -------------------------------------------------
                default: begin
                    // DISPLAY, SOLVE, VERIFY, DONE → hold values
                    cubeFlat      <= cubeFlat;
                    scrambleCount <= scrambleCount;
                    moveCount     <= moveCount;
                end
            endcase
        end
    end

    // ------------------------
    // Next-state logic (combinational)
    // ------------------------
    reg done; // indicates DONE state (not used yet, but left for completeness)

    always @(*) begin
        NS   = S;
        done = 1'b0;

        case (S)
            // After reset, we initialize the cube and then go to DISPLAY
            START: begin
                NS = DISPLAY;
            end

            // DISPLAY:
            //   - Wait here most of the time.
            //   - If scrambleBtn pressed -> go to SCRAMBLE (30 random moves).
            //   - If doMoveBtn pressed   -> go to MOVE (apply one manual move).
            DISPLAY: begin
                if (scrambleBtn)
                    NS = SCRAMBLE;
                else if (doMoveBtn)
                    NS = MOVE;
                else
                    NS = DISPLAY;
            end

            // SCRAMBLE:
            //   - Keep applying random moves until scrambleCount reaches 30.
            //   - Then return to DISPLAY.
            SCRAMBLE: begin
                // We want EXACTLY 30 random moves:
                // scrambleCount starts at 0 in START.
                // When scrambleCount == 29, we are about to apply the 30th move
                // in the current SCRAMBLE cycle. After that, we go back to DISPLAY.
                if (scrambleCount == 6'd29)
                    NS = DISPLAY;   // finished 30th move.
                else
                    NS = SCRAMBLE;  // keep scrambling
            end

            // MOVE:
            //   - Apply one manual move, then go back to DISPLAY.
            MOVE: begin
                NS = DISPLAY;
            end

            // SOLVE:
            //   - Placeholder for a future auto-solver.
            //   - Could step through a solution and reuse MOVE state.
            SOLVE: begin
                NS = MOVE;
            end

            // VERIFY:
            //   - Intended to check if cube is solved and go to DONE.
            //   - Currently isSolved is always 0, so this will always go
            //     back to DISPLAY.
            VERIFY: begin
                if (isSolved)
                    NS = DONE;
                else
                    NS = DISPLAY;
            end

            // DONE:
            //   - Reached when isSolved is true.
            //   - FSM stays here forever (can be reset with KEY3).
            DONE: begin
                done = 1'b1;
                NS   = DONE;
            end

            // Default: if somehow in an undefined state, go back to START.
            default: begin
                NS = START;
            end
        endcase
    end

    // ------------------------
    // Debug outputs on LEDs
    // ------------------------
    // Show current FSM state S on LEDs[6:0]. Higher LEDs unused.
    assign LEDR[6:0] = S;
    assign LEDR[9:7] = 3'b000;

endmodule
