from os import listdir, mkdir
from os.path import isfile, join, isdir
from re import compile


def convert(fn):
    with open(fn, encoding="cp1251") as fl:
        cont = fl.read()

    with open(join("utf8", fn), "w", encoding="utf-8") as fl:
        fl.write(cont)


if __name__ == '__main__':
    folder = join(__file__, "..")
    exp = compile(r".*\.(inc|asm|s)")
    if not isdir("utf8"):
        mkdir("utf8")

    for f in (f for f in listdir(folder) if isfile(f) and exp.fullmatch(f)):
        convert(f)
