#CubeSim – FPGA Rubik’s Cube Simulator

CubeSim is a Rubik’s Cube simulator implemented entirely in hardware using Verilog on an FPGA. The project models the cube state, applies legal cube moves through hardware inputs, and detects when the cube has been solved. The cube is displayed visually, and the system includes several quality-of-life features such as move counting and undo support.

Features

Hardware-based Rubik’s Cube simulation

2D sticker-based cube representation (54 stickers)

Deterministic move logic using fixed permutations

Finite State Machine (FSM) for system control

User-controlled moves via switches and buttons

Solved-state detection

Bonus features:

Move counter

Move display

Undo functionality

Solved screen

Project Structure
CubeSim/
├── CubeSimDriver.v      # Top-level module and FSM control
├── cubeState.v          # Cube state storage and move logic
├── vga_Top.v            # VGA output logic
├── seven_segment*.v     # Seven-segment display modules
├── source/              # Borrowed VGA-related support files
└── README.md

Design Overview
Cube Representation

The cube is stored as an array of 54 elements, where each element represents a sticker color. The full cube state is also exported as a flattened 162-bit bus to simplify communication between modules.

Move Logic

Each move is implemented as a fixed permutation of sticker indices. This ensures deterministic behavior and avoids race conditions. New move types can be added by defining additional permutation mappings.

Control Logic

A finite state machine controls initialization, scrambling, move execution, solved-state checking, and bonus features. This structure keeps the system reliable and easy to extend.

Display

The cube is displayed using a 2D layout. Rather than moving graphics, the design updates colors at fixed screen locations based on the cube state.

Demo

A video demonstration of the project is available on YouTube:

📺 Project Demo:
(Insert YouTube link here)

Requirements

FPGA board (e.g., DE1-SoC / DE2 series)

Quartus Prime

VGA-capable display


Credits and Citations

All cube control and move logic was written specifically for this project.

Portions of the VGA FSM and supporting files were adapted from materials provided by Peter Jamieson.
