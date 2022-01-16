#!/bin/bash

rm work-obj93.cf

ghdl -a --ieee=synopsys memory.vhd
ghdl -a --ieee=synopsys processor.vhd
ghdl -a --ieee=synopsys processor_tb.vhd

ghdl -r --ieee=synopsys ProcessorTest --wave=Processor.ghw
