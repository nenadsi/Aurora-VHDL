#!/usr/bin/env bash
set -e
mkdir -p sim
ghdl -a --std=08 fpga/src/fixed_point_pkg.vhd fpga/src/mandelbrot_core.vhd
ghdl -a --std=08 fpga/tb/tb_mandelbrot.vhd
ghdl -e --std=08 tb_mandelbrot
ghdl -r tb_mandelbrot --vcd=sim/mandelbrot.vcd
echo "OK: sim/mandelbrot.vcd generated"
