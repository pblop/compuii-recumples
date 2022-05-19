correctas = 0
totales = 0

for i in range(0, 100):
    h = int(str(i), 16)
    for j in range(0, 100):
        h2 = int(str(j), 16)
        s = h+h2
        s %= 0x100
        scorr = i+j
        scorr %= 100
        hscorr = int(str(scorr), 16)

        #ajuste
        hpc = h & 0x0f
        h2pc = h2 & 0x0f
        hsc = (h & 0xf0)
        h2sc = (h2 & 0xf0)
        if hsc + h2sc > 0x90:
            s += 0x60
        if hpc + h2pc > 0x9:
            s += 0x06
        s %= 0x100
        if hscorr != s:
            print(hsc + h2sc, hpc + h2pc)
            print(f"{h:02x}+{h2:02x}={s:02x}, {scorr}, {hscorr:02x}")
            correctas += 1
        totales += 1
print(correctas)
print(totales)
