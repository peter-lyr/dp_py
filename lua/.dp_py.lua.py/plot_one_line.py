# Copyright (c) 2024 liudepei. All Rights Reserved.
# create at 2024/03/09 18:41:00 星期六


import re
import sys

try:
    import matplotlib.pyplot as plt
except:
    import os
    os.system('pip install matplotlib -i https://pypi.tuna.tsinghua.edu.cn/simple --trusted-host mirrors.aliyun.com')
    import matplotlib.pyplot as plt


def get_number_pattern():
    decint = r"(?:[1-9](?:_?\d)*|0+(_?0)*)"
    binint = r"(?:0[bB](?:_?[01])+)"
    octint = r"(?:0[oO](?:_?[0-7])+)"
    hexint = r"(?:0[xX](?:_?[0-9a-fA-F])+)"
    integer = rf"(?:{decint}|{binint}|{octint}|{hexint})"

    digitpart = r"(?:\d(?:_?\d)*)"
    exponent = rf"(?:[eE][-+]?{digitpart})"
    fraction = rf"(?:\.{digitpart})"
    pointfloat = rf"(?:{digitpart}?{fraction}|{digitpart}\.)"
    exponentfloat = rf"(?:(?:{digitpart}|{pointfloat}){exponent})"
    floatnumber = rf"(?:{pointfloat}|{exponentfloat})"

    number = re.compile(rf"^[-+]?(?:{integer}|{floatnumber})$")

    return number


# patt = get_number_pattern()
patt = re.compile('[0-9a-fA-F]{2}') # 240824-15h27m 只处理一个字节的16进制


def get_nums_list_from_file(file):
    with open(file, "rb") as f:
        content = f.read().decode("utf-8")
    numbers = []
    temp = content.split()
    for t in temp:
        m = patt.match(t)
        if not m:
            continue
        try:
            # num = eval(m[0])
            num = eval('0x' + m[0]) # 240824-15h28m
            numbers.append(num)
        except Exception as e:
            print(e)
    return numbers


def main():
    if len(sys.argv) > 1:
        y = get_nums_list_from_file(sys.argv[1])
        if not y:
            return
    else:
        return
    plt.plot(y)
    plt.show()


if __name__ == "__main__":
    main()
