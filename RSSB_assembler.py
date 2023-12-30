import tkinter as tk
from tkinter.filedialog import askopenfilename 
tk.Tk().withdraw()
class RSSB:
    def __init__(self):
        self.instructions = []
        for i in range(65536):
            self.instructions.append("0000")
        self.labels = dict()
        self.current_address = 0

    def assemble(self, source_code):
        #First pass
        lines = source_code.splitlines()
        self.current_address = 0
        for line in lines:
            line = line.strip()
            #If line isn't empty
            if (line != "" and line[0] != ';' and 
                line.split()[0].lower() != "rssb" and line.split()[0] != ".ORG"):
                label = line.split()[0]
                if label in self.labels:
                    raise ValueError(f"Duplicate label {label} on line {self.current_address}")
                self.labels[label] = self.current_address
            self.current_address += 1

        #Second Pass
        self.current_address = 0
        for line in lines:
            line = line.strip()
            if line != "" and line[0] != ";":
                opcode = self.parse_instruction(line)
                if opcode == "no": continue 
                self.instructions[self.current_address] = opcode
            self.current_address += 1
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
        if mnemonic == ".ORG":
            self.current_address = int(operand, 16)
            return "no"
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
nf = open("memory.hex", "w")
nf.write(a.assemble(f.read()))
