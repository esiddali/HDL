#!/bin/bash
rm work-obj93.cf
python assembler.py
ghdl -a --ieee=synopsys ROM.vhd
ghdl -a --ieee=synopsys RAM.vhd
ghdl -a --ieee=synopsys processor.vhd
ghdl -a --ieee=synopsys processor_tb.vhd
ghdl -r --ieee=synopsys ProcessorTest --wave=Processor.ghw
