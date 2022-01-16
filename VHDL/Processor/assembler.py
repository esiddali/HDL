DEPTH = 256

with open("code.txt", 'r') as f:
	lines = f.readlines()

machineCode = ["0000"]

regMap = {'a' : 1, 'b' : 2, 'pc' : 3}
labels = {}

for i in range(0,len(lines)):
	line = lines[i].strip()
	if line[0] == "#":
		continue
	cols = line.split()
	if "set" == cols[0]:
		if cols[2] in labels:
			mc  = 0x8000 | (regMap[cols[1]] << 8) | labels[cols[2]]
		else:
			mc  = 0x8000 | (regMap[cols[1]] << 8) | int(cols[2])
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
	else:
		print("Unknown: " + line)

		

with open("instructions.txt", 'w') as f:
	for line in machineCode:
		f.write("%s\n" % line)
	for i in range(0, DEPTH - len(machineCode) + 1):
		f.write("0000\n")