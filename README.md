# 8-bit CPU

This project is a custom, minimal instruction set computer designed to execute basic arithmetic, logic, and control flow operations. It features a 3-stage finite state machine (FSM) control unit, an 8-bit ALU with status flags, and 256 bytes of addressable memory.

## Architecture Overview

* **Data Width:** 8-bit data bus and 8-bit address bus.
* **Memory:** 256 bytes of synchronous RAM (`256 x 8-bit`).
* **Registers:** * 8 General Purpose Registers (`R0` to `R7`).
    * `R1` acts as the primary accumulator (`reg_a`).
    * `R2` acts as the secondary operand (`reg_b`).
* **Control Unit:** 3-stage FSM pipeline:
    1.  `FETCH`: Retrieves the next instruction from memory using the Program Counter (PC).
    2.  `EXECUTE`: Decodes the instruction, performs ALU operations, or reads/writes memory.
    3.  `JUMP`: Evaluates branch conditions and updates the PC if necessary.

## Project Structure

| File | Description |
| :--- | :--- |
| `alu.v` | The Arithmetic Logic Unit. Handles math, bitwise operations, and sets flags (`Zero`, `Carry`, `Negative`). |
| `control_unit.v` | The brain of the CPU. Manages the FSM, decodes the 4-bit opcodes, and drives control signals. |
| `memory.v` | A 256-byte RAM module for storing instructions and data. |
| `program_counter.v` | An 8-bit counter that keeps track of the current execution address. |
| `registers.v` | The register file containing eight 8-bit general-purpose registers. |

## Instruction Set Architecture (ISA)

The CPU uses the top 4 bits of the instruction register `[7:4]` to decode the operation. 

| Opcode (Hex) | Mnemonic | Description | Flags Affected |
| :---: | :--- | :--- | :--- |
| `0x0` | `ADD` | Adds `R1` and `R2`, stores in `R1` | Z, C, N |
| `0x1` | `SUB` | Subtracts `R2` from `R1`, stores in `R1` | Z, C, N |
| `0x2` | `AND` | Bitwise AND of `R1` and `R2` | Z, N |
| `0x3` | `OR` | Bitwise OR of `R1` and `R2` | Z, N |
| `0x4` | `XOR` | Bitwise XOR of `R1` and `R2` | Z, N |
| `0x5` | `PUSH` | Outputs `R1` | Z, N, C=0 |
| `0x6` | `SHL` | Shift `R1` left by 1 | Z, N, C |
| `0x7` | `SHR` | Shift `R1` right by 1 | Z, N=0, C |
| `0x8` | `LOAD` | Loads data from memory (addressed by `R2`) | Z, N |
| `0x9` | `STORE` | Stores `R1` into memory (addressed by `R2`) | Z, N |
| `0xA` | `JMP` | Unconditional jump to address in `R1` | Z, N |
| `0xB` | `JZ` | Jump if Zero flag is set | - |
| `0xC` | `JNZ` | Jump if Zero flag is not set | - |
| `0xD` | `JC` | Jump if Carry flag is set | - |
| `0xE` | `JNC` | Jump if Carry flag is not set | - |
| `0xF` | `POP` | Loads data into ALU from input bus | Z, N, C=0 |

## Getting Started

### Prerequisites

To simulate and synthesize this processor, you will need a Verilog simulator. [Icarus Verilog](http://iverilog.icarus.com/) and [GTKWave](http://gtkwave.sourceforge.net/) are recommended.

If you are on a Fedora/RHEL-based system, you can install the toolchain via:
```bash
sudo dnf install iverilog gtkwave
