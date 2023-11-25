from os import listdir
from os.path import isfile, join

folder = join(__file__, "..")

for f in listdir(folder):
    if not f.endswith(".txt"):
        continue
    with (open(f.replace("inp", "test"), "w") as out, open(f) as inp):
       out.write(inp.read()[::-1])
