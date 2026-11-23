import sys

OP = {
    "NOP": 0x00, "HLT": 0x01,
    "LDI A": 0x10, "LDI B": 0x11, "LDI H": 0x12, "LDI L": 0x13,
    "ADD": 0x20, "SUB": 0x21, "AND": 0x22, "OR": 0x23,
    "XOR": 0x24, "CMP": 0x25, "ADC": 0x26, "SBC": 0x27,
    "ADDI": 0x28, "CMPI": 0x29,
    "INC A": 0x30, "DEC A": 0x31, "NOT A": 0x32, "SHL A": 0x33,
    "SHR A": 0x34, "NEG A": 0x35, "SAR A": 0x36, "MUL": 0x38, "DIV": 0x39,
    "LD": 0x50, "ST": 0x51, "LD HL": 0x52, "ST HL": 0x53,
    "INC HL": 0x54, "DEC HL": 0x55, "PUSH A": 0x58, "POP A": 0x59,
    "CALL": 0x5A, "RET": 0x5B,
    "JMP": 0x60, "JZ": 0x61, "JNZ": 0x62, "JC": 0x63,
    "JNC": 0x64, "JLT": 0x65, "JGE": 0x66,
}

regs = ["A", "B", "H", "L"]
for d in range(4):
    for s in range(4):
        OP[f"MOV {regs[d]}, {regs[s]}"] = 0x40 + d * 4 + s

IMM8 = {0x10, 0x11, 0x12, 0x13, 0x28, 0x29}
ADDR16 = {0x50, 0x51, 0x5A, 0x60, 0x61, 0x62, 0x63, 0x64, 0x65, 0x66}


def parse_line(line):
    if line in OP:
        return OP[line], None
    if "," in line:
        left, right = line.split(",", 1)
        left, right = left.strip(), right.strip()
        if f"{left}, {right}" in OP:
            return OP[f"{left}, {right}"], None
        return OP[left], right
    cmd, arg = line.rsplit(" ", 1)
    return OP[cmd.strip()], arg.strip()


def assemble(filename):
    with open(filename) as f:
        raw_lines = f.readlines()

    labels = {}
    program = []
    pc = 0
    max_addr = 0

    for raw in raw_lines:
        line = " ".join(raw.split(";")[0].upper().split())
        if not line:
            continue
        if ":" in line:
            name, line = line.split(":", 1)
            labels[name.strip()] = pc
            line = line.strip()
            if not line:
                continue
        if line.startswith(".ORG "):
            pc = int(line.split()[1], 0)
            continue

        program.append((pc, line))
        if line.startswith(".DB "):
            pc += len(line[4:].split(","))
        else:
            op, _ = parse_line(line)
            pc += 3 if op in ADDR16 else (2 if op in IMM8 else 1)
        max_addr = max(max_addr, pc)

    mem = [0] * max_addr
    for addr, line in program:
        if line.startswith(".DB "):
            for i, val in enumerate(line[4:].split(",")):
                mem[addr + i] = int(val.strip(), 0) & 0xFF
            continue

        op, arg = parse_line(line)
        mem[addr] = op
        if arg is not None:
            val = labels[arg] if arg in labels else int(arg, 0)
            mem[addr + 1] = val & 0xFF
            if op in ADDR16:
                mem[addr + 2] = (val >> 8) & 0xFF

    return mem


if __name__ == "__main__":
    src = sys.argv[1]
    out = sys.argv[2] if len(sys.argv) > 2 else src.rsplit(".", 1)[0] + ".hex"
    data = assemble(src)
    with open(out, "w") as f:
        for b in data:
            f.write(f"{b:02X}\n")