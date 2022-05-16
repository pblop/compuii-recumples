for n in range(0, 61+1):
    for m in range(28, 31+1):
        if n-m < 0:
            continue
        nbcd = int(str(n), 16)
        mbcd = int(str(m), 16)

        good_result = int(str(n-m), 16)
        gotten = nbcd - mbcd

        lastdigitg = gotten & 0xf
        #if lastdigitg >= 0xa:
        #    gotten -= 6

        lastdigitn = nbcd & 0xf
        lastdigitm = mbcd & 0xf
        if lastdigitm > lastdigitn:
            print(f"{hex(lastdigitm)} > {hex(lastdigitn)}")
            gotten -= 6
        #if m == 28 and lastdigitn == 2:
        #    pass
        #elif m == 28 or m == 29:
        #    #print(lastdigitn)
        #    if lastdigitn <= 2:
        #        gotten -= 6
    #  lastdigitn = n & 0xf
    #  if lastdigitn == 0x8 or lastdigitn == 0x9:
    #    gotten += 6

        if gotten != good_result:
            print(f"0x{n}-0x{m}: gotten: {hex(gotten)}, correct: {hex(good_result)}")

