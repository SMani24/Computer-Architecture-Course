# Computer Architecture Coursework

University Computer Architecture assignments covering hardware datapaths, finite-state controllers, and a 32-bit RISC-V processor implemented in three execution architectures: **single-cycle, multi-cycle, and five-stage pipelined**.

The repository preserves HDL source, assembly programs, instruction images, assignment specifications, submission reports, and historical ModelSim artifacts. The processors implement a limited integer-instruction subset; they are not complete RV32I implementations.

## Repository layout

```text
CAs/
├── CA1/
│   ├── 8Queen/              # Eight-queens hardware solvers and component tests
│   └── 8Queen-Report.*      # Report and archived submission
├── CA2/
│   ├── single-cycle/
│   │   ├── code/           # Single-cycle CPU and testbench
│   │   └── assemblies/     # Minimum, instruction exercise, and bubble sort
│   └── ...                 # Specification, report, archive, ISA references
├── CA3/
│   ├── multi-cycle/
│   │   ├── code/           # Multi-cycle CPU and testbench
│   │   └── assemblies/     # Minimum and instruction exercise
│   └── ...                 # Specification, report, and archive
└── CA4/
    ├── pipeline/
    │   ├── code/           # Pipelined CPU, hazard unit, and testbench
    │   └── assemblies/     # Minimum and instruction exercise
    └── ...                 # Specification, report, and archive
hws/
└── 2/                      # Earlier RISC-V assembly homework
```

The CA2–CA4 specifications and handwritten reports are primarily in Persian. Reports include datapath diagrams, control tables or state diagrams, and simulation screenshots. ZIP files preserve submission snapshots, which can differ from the extracted files.

## Assignment progression

| Assignment | Design | Main components |
|---|---|---|
| [CA1](CAs/CA1/) | Dedicated eight-queens hardware | Safety checks, backtracking FSMs, row registers, and a stack-based solver variant. This is a separate exercise rather than a CPU stage. |
| [CA2](CAs/CA2/single-cycle/) | Single-cycle processor | Combinational decode and execution, separate instruction ROM/data RAM, ALU, register file, immediate generation, and branch/jump PC selection. |
| [CA3](CAs/CA3/multi-cycle/) | Multi-cycle processor | FSM sequencing, shared instruction/data memory, enabled instruction and PC registers, and temporary OldPC, MDR, A, B, and ALUOut registers. The ALU is reused across execution steps. |
| [CA4](CAs/CA4/pipeline/) | Five-stage processor | Fetch, Decode, Execute, Memory, and Writeback stages; pipelined data/control; operand forwarding; load-use stall detection; and branch/jump flush logic. |

The CPU assignments prescribe the same core instruction subset and a program that finds the minimum of ten signed 32-bit integers. The main progression is the execution architecture and its control/timing requirements.

## Processor organization

All three CPU versions contain a 32-bit datapath, 32-register file, ALU, instruction decoder, and immediate generator for I/S/B/J/U formats. The ALU implements addition, subtraction, AND, OR, XOR, and signed less-than. Register reads are combinational; CA2/CA3 write the register file on the rising clock edge, while CA4 writes on the falling edge.

Memory models use 256-word, 32-bit arrays by default and index them with `address[31:2]`. Reads are combinational and stores are clocked. CA2/CA4 use separate instruction and data arrays; CA3 uses one shared array. Instruction images are loaded with `$readmemh("instructions.hex", ...)`: at initialization for the instruction ROMs, and during reset for CA3's shared memory.

In CA4, branches resolve in Execute using subtraction and the ALU zero flag. Its hazard unit selects Execute operands from captured register data, the Memory-stage ALU result, or the Writeback result. The store-data path also receives forwarding. Fetch and Decode can be held for a detected load-use dependency, and taken branches/jumps request clearing of younger pipeline stages. The checked-in implementation has limitations described below.

Useful starting points:

- [Single-cycle datapath](CAs/CA2/single-cycle/code/datapath.v) and [controller](CAs/CA2/single-cycle/code/controller.v).
- [Multi-cycle datapath](CAs/CA3/multi-cycle/code/datapath.v) and [control FSM](CAs/CA3/multi-cycle/code/controller_main.v).
- [Pipeline datapath](CAs/CA4/pipeline/code/datapath.v), [pipelined controller](CAs/CA4/pipeline/code/controller.v), and [hazard unit](CAs/CA4/pipeline/code/hazard_unit.v).

## Instruction subset

These instructions have explicit decode/datapath paths. Their presence does not establish correctness for every operand, dependency, or control-flow case.

| Category | Instructions |
|---|---|
| Register arithmetic | `ADD`, `SUB` |
| Immediate arithmetic | `ADDI` |
| Register logic | `AND`, `OR` |
| Immediate logic | `ANDI`, `ORI`, `XORI` |
| Signed comparison | `SLT`, `SLTI` |
| Word memory access | `LW`, `SW` |
| Conditional branch | `BEQ`, `BNE` |
| PC-relative jump | `JAL` |
| Upper immediate | `LUI` |
| Register-indirect jump | `JALR` — partial implementation; see limitations |

`ANDI` is decoded in addition to the prescribed assignment subset. Register `XOR` is not decoded even though the ALU has an XOR operation. Shifts, unsigned comparisons, subword memory accesses, additional branch conditions, `AUIPC`, and ISA extensions are not implemented. There is no implemented trap/interrupt handling or illegal-instruction exception path. Some unsupported encodings silently select a default operation.

See the [CA4 main decoder](CAs/CA4/pipeline/code/controller_main.v), [ALU decoder](CAs/CA4/pipeline/code/controller_alu.v), and [ALU](CAs/CA4/pipeline/code/alu.v) for the actual instruction behavior.

## Simulation

Historical compile records identify **ModelSim – Intel FPGA Edition 2020.1**. Each CPU has a project file and a top-level testbench:

| Version | Working directory | Project file | Testbench |
|---|---|---|---|
| Single-cycle | `CAs/CA2/single-cycle/code` | `sinlge-cycle.mpf` | `riscv_single_cycle_testbench` |
| Multi-cycle | `CAs/CA3/multi-cycle/code` | `multi-cycle.mpf` | `riscv_multi_cycle_testbench` |
| Pipeline | `CAs/CA4/pipeline/code` | `pipeline.mpf` | `riscv_pipeline_testbench` |

The single-cycle project filename retains its original spelling. Existing projects contain absolute Windows source paths, so remap those paths before using them on another machine.

An example source-based workflow for CA4, from a terminal configured for ModelSim:

```sh
cd CAs/CA4/pipeline/code
vlib work                       # Needed if the work library does not exist
vlog -sv *.v
vsim -gui work.riscv_pipeline_testbench
```

Then, in the ModelSim console:

```tcl
add wave -r sim:/riscv_pipeline_testbench/*
run -all
```

Use the corresponding directory and testbench from the table for CA2/CA3. Compile each assignment into its own library: modules such as `datapath`, `controller`, and `register_file` reuse names across versions but have different implementations. The `-sv` flag accommodates unpacked array ports used by the `.v` sources. Recompile from source rather than relying on the committed compiled libraries.

Run from the selected `code` directory so the relative `instructions.hex` path resolves correctly. The testbench supplies clock/reset stimulus and stops after a fixed interval. Inspect internal registers and memory in the Wave window; these benches do not automatically assert expected outputs or print a functional pass/fail result.


### Selecting a program

Each CPU loads the `code/instructions.hex` file. To try another supplied image, copy it into that location before starting or reloading the simulation. For example, from `CAs/CA4/pipeline/code`:

```sh
cp ../assemblies/all_instructions.hex instructions.hex
```

This replaces the active image. Restart/reload the simulation so the ROM initialization or shared-memory reset reads it again. Assembly source and preassembled images are included, but the original assembler/export command is not documented.

## Programs and recorded results

| Program | Purpose and caveats |
|---|---|
| `min.s` / `min.hex` | Initializes ten integers and finds the minimum in `s1`/`x9`, using loads/stores, signed comparisons, branches, and a backward jump. CA3/CA4 finish with `x20 = 1337` as a marker. |
| `all_instructions.s` / `.hex` | Directed exercise of the implemented subset, with some expected values annotated in comments. It is not an exhaustive ISA test suite. |
| CA2 `bubble_sort.s` / `.hex` | Twenty-element sorting program with an expected sequence in comments. It uses `BGE`, which these CPUs do not implement, so its inclusion does not demonstrate successful execution on this HDL. |


