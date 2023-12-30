import tkinter as tk
from tkinter.filedialog import askopenfilename 
tk.Tk().withdraw()
class RSSB:
    def __init__(self):
        self.instructions = []
        self.labels = dict()

    def assemble(self, source_code):
        #First pass
        lines = source_code.splitlines()
        current_address = 0
        for line in lines:
            line = line.strip()
            #If line isn't empty
            if line != "" and line[0] != ';' and line.split()[0].lower() != "rssb":
                label = line.split()[0]
                if label in self.labels:
                    raise ValueError(f"Duplicate label {label} on line {current_address}")
                self.labels[label] = current_address
            current_address += 1

        #Second Pass
        for line in lines:
            line = line.strip()
            if line != "" and line[0] != ";":
                opcode = self.parse_instruction(line)
                self.instructions.append(opcode)
        s = ""
        for inst in self.instructions:
            s += inst
            s += '\n'
        return s

    def parse_instruction(self, instruction):
        words = instruction.strip().split()
        if words[0] in self.labels:
            mnemonic = words[1]
            operand = words[2]
        else:
            mnemonic = words[0]
            operand = words[1]
        if mnemonic.lower() != "rssb":
            raise ValueError("Invalid Instruction. (Hint, use rssb)")
        if operand in self.labels:
            return hex(self.labels[operand])[2:].zfill(4)
        else:
            try:
                return hex(int(operand, 16))[2:].zfill(4)
            except:
                raise ValueError("Invalid Operand")

a = RSSB()
fn = askopenfilename()
f = open(fn)
print(a.assemble(f.read()))
