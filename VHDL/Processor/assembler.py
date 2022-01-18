#!/usr/bin/python3

# Constants
DEPTH = 256
NUM_REGISTERS = 8

# Read assembly code from code.txt
with open("code.txt", 'r') as f:
	lines = f.readlines()

# Initialize machine code 
machineCode = ["0000"]

# Initialize maps
# Memory isn't really a register but acts like one
regMap = {'prefix' : 0, 'a' : 1, 'b' : 2, 'c' : 3, 'd' : 4, 'e' : 5, 'f' : 6, 'pc' : NUM_REGISTERS-1, 'memory' : NUM_REGISTERS+4}
jumpsMap = {'equal' : NUM_REGISTERS, 'unequal' : NUM_REGISTERS+1, 'lt' : NUM_REGISTERS+2, 'gt' : NUM_REGISTERS+3}
labels = {}

# Interpret assembly code and generate machine code
# Could be simplified with more dictionaries at a later date
for i in range(0,len(lines)):
	line = lines[i].strip()
	if (len(line) == 0 or line[0] == "#"):
		continue
	cols = line.split()
	if (("set" == cols[0]) and (len(cols) < 4)):
		if cols[2] in labels:
			mc  = 0x8000 | (regMap[cols[1]] << 8) | labels[cols[2]]
		else:
			mc  = 0x8000 | (regMap[cols[1]] << 8) | int(cols[2])
		machineCode.append(f'{mc:04X}')

	elif (("set" == cols[0]) and (len(cols) >= 4)):
		if cols[2] in labels:
			mc  = 0x8000 | (jumpsMap[cols[4]] << 8) | labels[cols[2]]
		else:
			mc  = 0x8000 | (jumpsMap[cols[4]] << 8) | int(cols[2])
		machineCode.append(f'{mc:04X}')
	
	elif "nop" ==  cols[0]:
		machineCode.append("0000")
	elif "inc" ==  cols[0]:
		mc  = 0x0089 | (regMap[cols[1]] << 8)
		machineCode.append(f'{mc:04X}')
	elif "dec" ==  cols[0]:
		mc  = 0x008A | (regMap[cols[1]] << 8)
		machineCode.append(f'{mc:04X}')
	elif "label" ==  cols[0]:
		labels[cols[1]] = len(machineCode)
	elif "copy" ==  cols[0]:
		mc  = 0x0000 | (regMap[cols[3]] << 8) | regMap[cols[1]]
		machineCode.append(f'{mc:04X}')
	elif "add" ==  cols[0]:
		mc  = 0x0081 | (regMap[cols[1]] << 8)
		machineCode.append(f'{mc:04X}')
	elif "sub" ==  cols[0]:
		mc  = 0x0082 | (regMap[cols[1]] << 8)
		machineCode.append(f'{mc:04X}')
	elif "equal" ==  cols[0]:
		mc  = 0x0083 | (regMap[cols[1]] << 8)
		machineCode.append(f'{mc:04X}')
	elif "gt" ==  cols[0]:
		mc  = 0x0084 | (regMap[cols[1]] << 8)
		machineCode.append(f'{mc:04X}')
	elif "lt" ==  cols[0]:
		mc  = 0x0085 | (regMap[cols[1]] << 8)
		machineCode.append(f'{mc:04X}')
	elif "and" ==  cols[0]:
		mc  = 0x0086 | (regMap[cols[1]] << 8)
		machineCode.append(f'{mc:04X}')
	elif "or" ==  cols[0]:
		mc  = 0x0087 | (regMap[cols[1]] << 8)
		machineCode.append(f'{mc:04X}')
	elif "xor" ==  cols[0]:
		mc  = 0x0088 | (regMap[cols[1]] << 8)
		machineCode.append(f'{mc:04X}')
	elif "shiftleft" ==  cols[0]:
		mc  = 0x008B | (regMap[cols[1]] << 8)
		machineCode.append(f'{mc:04X}')
	elif "shiftright" ==  cols[0]:
		mc  = 0x008C | (regMap[cols[1]] << 8)
		machineCode.append(f'{mc:04X}')
	else:
		print("Unknown: " + line)

		
# Write machine code to instructions.txt
with open("instructions.txt", 'w') as f:
	for line in machineCode:
		f.write("%s\n" % line)
	for i in range(0, DEPTH - len(machineCode) + 1):
		f.write("0000\n")