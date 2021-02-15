f1 = open("boot_code.cde")
f1_str = f1.readlines();

f2_str = ''
f2 = open("shivam2.hex","w")
for i in f1_str:
    el = hex(int(i[0:32], 2))[2:]
    if len(el) < 8:
        f2_str += '0'*(8-len(el))
    f2_str += el + '\n'

f2.write(f2_str)
