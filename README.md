1. High-Level Description of the Problem
The goal of this project was to build a Rubik’s Cube simulator using an FPGA and Verilog. The system needed to store the state of a Rubik’s Cube, allow the user to apply legal cube moves using hardware inputs, and detect when the cube is solved. The cube state is displayed visually, and the system provides feedback such as move count and solved indication.
The main challenge was implementing all cube behavior in hardware. The design had to be clocked, deterministic, and modular, while still being easy to understand and extend.
2. Background and Requirements
A Rubik’s Cube has 6 faces with 9 stickers per face, for a total of 54 stickers. Each move of the cube rearranges these stickers in a fixed way. In hardware, this means keeping track of sticker positions and applying predefined permutations.
The project had several key requirements:

Represent the cube in a 2D layout

Maintain a correct and functioning cube state in hardware

Allow the user to control the cube using switches and buttons

Use a clean control structure to manage system behavior

4. System Design
3.1 Finite State Machine Design
A finite state machine (FSM) controls the overall flow of the system. It handles cube initialization, scrambling, move execution, solved-state checking, and bonus features like move counting and undo. Using an FSM ensures that each operation happens in a controlled order and that user inputs only trigger one action at a time.
3.2 Cube Mechanism Design
The cube is stored as an array of 54 elements, where each element represents the color of one sticker. On reset, the cube is set to the solved state by assigning one color to each face.
Cube moves are implemented as fixed permutations of sticker indices. When a move is applied, the current cube state is copied and updated based on the selected move. This approach keeps the logic simple, predictable, and easy to debug.
The cube state is also sent out as a flattened 162-bit signal so other modules can read the full cube state easily.
3.3 VGA Design
On the surface VGA design is quite simple but not very elegant. Because the rubix cube does not require movement or rearranging of blocks, merely a coloring change to an array of constant locations was the best approach. Basically the screen is split up into an array of 3072 pixels (note these aren’t actual pixels but a large grouping of them). Then there are 54 assignments, one for each block. The FSM then iterates through the array during its read sequence. If the block is a 0 then it sets it to black. If that particular block is a 1 then two things happen. First it takes in 3 bits from a 162 bit array sent from the top level cube module, this is for color. Then it turns on 3 more pixels, and shares the color, to get the size of the square appropriate for the screen. Once it iterates through the array the rubix cube will appear on the screen. The screen will change to a solved window when a 1 bit viable is set to 1. It writes to the screen in much the same way as the rubix cube.
5. Results and Features
The final system works as intended. The cube initializes correctly, moves are applied accurately, and the system reliably detects when the cube is solved.
Several bonus features were added:
Solved-state screen
Move display
Move counter
Undo functionality


Using a modular design with an FSM made the system more reliable and easier to extend.
5. Potential Improvements
There are several ways this project could be extended:
More Move Types
 Support for slice moves, wide turns, and cube rotations can be added by defining new permutation mappings. The current design already supports this structure.
3D Cube Representation
 The cube is currently stored as a 2D sticker array. A future version could use a true 3D cubie-based model that tracks both position and orientation. This would make advanced moves and larger cubes easier to support.
Additional Features
 Features like automated solving, expanded move history, or different input methods could be added by extending the existing FSM.


6. Conclusion
This project shows that a Rubik’s Cube can be accurately modeled and controlled using FPGA hardware. By using a simple array-based cube representation and fixed move logic, the design remains correct, clear, and easy to expand.
The FSM-based control structure keeps the system organized and makes it straightforward to add new features in the future.
7. Demonstration
Video Showcase: link
8. Citations
None of the cube control logic was borrowed from another source. However, parts of the VGA FSM and supporting files were adapted from material provided by Peter Jamieson. These files are labeled “source” on GitHub, and any reused code is clearly marked.

