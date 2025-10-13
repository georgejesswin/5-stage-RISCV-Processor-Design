# RISC-V 32-bit Pipelined Processor (RV32I)

This project implements a **5-stage pipelined RISC-V 32-bit base ISA (RV32I)** processor in Verilog. The design follows standard **RISC principles** and incorporates pipeline registers, hazard detection, and forwarding to handle instruction dependencies efficiently.

---

## Processor Overview

The processor consists of **five stages**, each mapped to specific Verilog modules:

### 1. Instruction Fetch (IF)
- Modules: `pc.v`, `instr_mem.v`
- Responsibilities:
  - Fetch instructions from instruction memory.
  - Increment or update the Program Counter (PC) based on branches/jumps.

### 2. Instruction Decode (ID)
- Modules: `instr_decode.v`, `control.v`, `reg_file.v`, `forward.v` 
- Responsibilities:
  - Decode instructions and extract operands.
  - Generate control signals for ALU, memory, and write-back stages.
  - Read data from the register file.
  - Detect hazards and manage stalling/forwarding.

### 3. Execute (EX)
- Module: `alu.v`
- Responsibilities:
  - Perform arithmetic and logic operations.
  - Compute branch targets and evaluate branch conditions.

### 4. Memory Access (MEM)
- Module: `data_mem.v`
- Responsibilities:
  - Perform load and store operations to data memory.
  - Support byte, half-word, and word accesses, including signed/unsigned loads.

### 5. Write Back (WB)
- Module: `wb.v`, assisted by `forward.v`
- Responsibilities:
  - Write results back to the register file.
  - Select between ALU results and memory data.

---

## Pipeline Registers

To support pipelining, **four dedicated pipeline registers** are included between stages:

- `if_id.v` – IF/ID pipeline register  
- `id_ex.v` – ID/EX pipeline register  
- `ex_mem.v` – EX/MEM pipeline register  
- `mem_wb.v` – MEM/WB pipeline register  

These registers, along with **flush and stall logic**, ensure correct execution in the presence of hazards.

---

## Hazard Handling

The processor handles three primary pipeline hazards:

1. **Data Hazards**  
   - Occur when an instruction depends on the result of a previous one.  
   - Managed using the **forwarding unit** (`forward.v`) and **stalling** through hazard detection logic.

2. **Control Hazards**  
   - Caused by branch and jump instructions.  
   - Managed using **flush logic** in pipeline registers to discard incorrectly fetched instructions.

3. **Structural Hazards**  
   - Arise from resource conflicts.  
   - Avoided by having separate instruction (`instr_mem.v`) and data memory (`data_mem.v`).

---

## Testbench

- Module: `tb.v`  
- Provides stimulus to the processor for simulation.  
- Monitors PC, instruction, ALU results, registers, memory, and forwarding signals.

---

## Project Files

| Module | Description |
|--------|-------------|
| `alu.v` | ALU for arithmetic and logic operations |
| `control.v` | Control signal generation |
| `data_mem.v` | Data memory supporting load/store instructions |
| `ex_mem.v` | EX/MEM pipeline register |
| `forward.v` | Forwarding unit for data hazard resolution |
| `id_ex.v` | ID/EX pipeline register |
| `if_id.v` | IF/ID pipeline register |
| `instr_decode.v` | Instruction decoder |
| `instr_mem.v` | Instruction memory |
| `mem_wb.v` | MEM/WB pipeline register |
| `pc.v` | Program Counter |
| `reg_file.v` | Register file with 32 general-purpose registers |
| `tb.v` | Testbench |
| `top.v` | Top-level module integrating all submodules |
| `wb.v` | Write-back stage |

---


---

This project provides a **baseline RISC-V pipelined processor** for educational and experimentation purposes.
