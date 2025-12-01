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
    // Basic signals
    // ------------------------
    wire clk   = CLOCK_50;
    wire rst_n = KEY[3];       // active-low reset from pushbutton

    wire start = ~KEY[2];      // start / scramble button (active-low on board)
    wire [1:0] rotationControl = KEY[1:0];
    wire [5:0] faceInput       = SW[5:0];

    // ------------------------
    // State encoding
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
    // Rotation count (quarter turns) for manual input
    // ------------------------
    reg [2:0] rotCount;  // 0..3 (0=none,1=CW,3=CCW,2=double)

    always @(*) begin
        case (rotationControl)
            2'b00: rotCount = 3'd0; // no move
            2'b01: rotCount = 3'd1; // CW
            2'b10: rotCount = 3'd3; // CCW = 3 CW turns
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
        .rst         (rst_n),       // active-low reset
        .nextFace    (randFace),    // 0..5
        .nextRotation(randRot)      // 0=CW,1=CCW,2=double
    );

    // ------------------------
    // Current move selection (manual vs random)
    // ------------------------
    reg [5:0] curFace;       // what we actually feed to cubeState
    reg [2:0] curRotCount;   // as quarter-turn count

    // ------------------------
    // Scramble counter (30 random moves)
    // ------------------------
    reg [5:0] scrambleCount; // 0..30

    // ------------------------
    // Move engine (combinational)
    // ------------------------
    cubeState turnCube (
        .nextFaceMove (curFace),
        .nextRotation (curRotCount),
        .cubeState    (cubeFlat),
        .cubeStateNew (cubeFlatNext)
    );

    // Stub for solved detection
    wire isSolved;
    assign isSolved = 1'b0;

    // ------------------------
    // Choose move source based on state
    // ------------------------
    always @(*) begin
        // default: manual move from switches/keys
        curFace     = faceInput;
        curRotCount = rotCount;

        case (S)
            SCRAMBLE: begin
                // Use random face and rotation during scramble
                curFace = {3'b000, randFace};  // extend 3-bit face to 6 bits

                // Convert randRot (0,1,2) into quarter-turn counts
                case (randRot)
                    2'd0: curRotCount = 3'd1; // CW
                    2'd1: curRotCount = 3'd3; // CCW (= 3 CW)
                    2'd2: curRotCount = 3'd2; // double
                    default: curRotCount = 3'd0;
                endcase
            end

            default: begin
                // already set to manual above
            end
        endcase
    end

    // ------------------------
    // Sequential: state + cubeFlat + scrambleCount
    // ------------------------
    integer i;  // for initialization loop

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            S             <= START;
            cubeFlat      <= 162'd0;
            scrambleCount <= 6'd0;
        end else begin
            S <= NS;

            case (S)
                START: begin
                    // initialize to solved cube
                    for (i = 0; i < 54; i = i + 1) begin
                        if (i < 9)       cubeFlat[3*i +: 3] <= 3'b000; // face 0
                        else if (i < 18) cubeFlat[3*i +: 3] <= 3'b001; // face 1
                        else if (i < 27) cubeFlat[3*i +: 3] <= 3'b010; // face 2
                        else if (i < 36) cubeFlat[3*i +: 3] <= 3'b011; // face 3
                        else if (i < 45) cubeFlat[3*i +: 3] <= 3'b100; // face 4
                        else             cubeFlat[3*i +: 3] <= 3'b101; // face 5
                    end
                    scrambleCount <= 6'd0;
                end

                SCRAMBLE: begin
                    // Apply one random move per clock
                    cubeFlat      <= cubeFlatNext;
                    scrambleCount <= scrambleCount + 6'd1;
                end

                MOVE: begin
                    // Apply one manual move (from switches/keys)
                    cubeFlat <= cubeFlatNext;
                end

                default: begin
                    // hold cubeFlat and scrambleCount
                    cubeFlat      <= cubeFlat;
                    scrambleCount <= scrambleCount;
                end
            endcase
        end
    end

    // ------------------------
    // Next state logic
    // ------------------------
    reg done;

    always @(*) begin
        NS   = S;
        done = 1'b0;

        case (S)
            START: begin
                // after reset/init, go to DISPLAY
                NS = DISPLAY;
            end

            DISPLAY: begin
                // press KEY[2] (active-low) to start scramble
                if (start)
                    NS = SCRAMBLE;
                else
                    NS = DISPLAY;
            end

            SCRAMBLE: begin
                if (scrambleCount >= 6'd30)
                    NS = DISPLAY;   // finished scrambling
                else
                    NS = SCRAMBLE;  // keep scrambling
            end

            MOVE: begin
                NS = VERIFY;
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

endmodule
