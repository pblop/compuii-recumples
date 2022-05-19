for i in range(0, 100):
    h = int(str(i), 16)
    h2 = h >> 1

    if i % 4 == 0:
        print("  ", end="")
    print(f"{h:#04x}: {h2:08b} => {h2&0b00001001:08b}")
