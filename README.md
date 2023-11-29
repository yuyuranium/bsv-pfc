# BSV Post-fix Calculator

A simple **post-fix calculator** (state machine based) written in Bluespec SystemVerilog. This project also serves as a template for other BSV projects.

This project uses [bluespec-cmake](https://github.com/yuyuranium/bluespec-cmake) to build BSV and SystemC (C++) targets.

## Codebase

The directory/file layout is structured as followed:

- `cmake`: cmake modules
- `cores`: Standalone BSV modules/IPs ready for FPGA/ASIC production (RTL ready)
- `lib`: General-purpose BSV modules that support polymorphic data types
- `sim`: SystemC simulation sources (compiles to SystemC executables)
- `test`: BSV Testbenches (compiles to Bluesim executables)
- `vendor`: Git submodules used in this project
  - `bluecheck`: A generic test bench written in Bluespec
  - `bluespec-cmake`: CMake toolchain for Bluespec
 
## Getting started

### Clone the repo and submodules

```
git clone https://github.com/yuyuranium/bsv-pfc.git
cd bsv-pfc
git submodule update --init
```

### Build all the targets

Using CMake's standard build process (Ninja is recommended)

```bash
# In bsv-pfc
mkdir build
cd build
cmake .. -G Ninja
ninja
```

or

```bash
# In bsv-pfc
cmake -S . -B build -G Ninja
cmake --build build
```

Note that this project assumes SystemC-2.3.4 is installed under `/usr/local/share`. You can edit [here](https://github.com/yuyuranium/bsv-pfc/blob/a7d36a02f6b24e64b64511c3924138b0cc0d424d/sim/CMakeLists.txt#L6) to meet your installation requirements.

### Run the simulation

By default the following executables are built:

- `stack-btest`: Bluecheck testbench for `Stack` (constrained random testing)
- `pfc-btest`: Bluecheck testbench for `PostfixCalculator` (constrained random testing)
- `pfc-tb`: Bluespec testbench for `PostfixCalculator` (evaluates 3 post-fix expressions)
- `pfc-sim`: SystemC based simulation (evaluates a post-fix expression from command line input)

To run the `pfc-sim`, you need to input a post-fix expression from the command line, for example:

```bash
# In bsv-pfc
./build/bin/pfc-sim 1 2 + 4 swap sub
```
And you will get a result of 1. (4 - (1 + 2) = 1)

A simulation trace (`trace.vcd`) will be generated for debugging. You can open it with waveform viewer, e.g.,  GTKWave or nWave.

### Verilog generation

Verilog code for `PostfixCalculator32x32` (32-bit data and depth 32) is generated under `build/lib/Verilog`
