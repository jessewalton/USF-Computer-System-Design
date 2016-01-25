#!/usr/bin/env python2
from __future__ import print_function, division
import re, sys


subspairs = "addcy, addc, compare, comp, disable interrupt, dint, enable interrupt, eint, input, in, output, out, return, ret, returni, reti, subcy, subc".upper().split(",")
subs = [(subspairs[i].strip(), subspairs[i+1].strip(),) for i in range(0, len(subspairs), 2)]
print(subs)

iref_pblaze_re = r"(fetch|input|output|store)\s+(s[0-9a-f]{1,2})\,\s+\((s[0-9a-f]{1,2})\)"
iref_pblaze_sub = r"\1 \2\, \3"
iref_kcpsm_re = r"(fetch|in|out|store)\s+(s[0-9a-f]{1,2})\,\s+(s[0-9a-f]{1,2})"
iref_kcpsm_sub = r"\1 \2\, \(\3\)"



if len(sys.argv) != 4:
    print("usage: pconv.py [pblaze|kcpsm] infile outfile")
    sys.exit(1)

new_format, ifile_name, ofile_name = sys.argv[1:]
new_format = new_format.lower()

ifile = open(ifile_name, "r").readlines()

ofile = open(ofile_name, "w")


consts = {}
if new_format == "pblaze":
    print("preparsing")
    # preparse
    for line in ifile:
        sline = line.split(";")[0]
        sline = sline.split(":")[-1]
        sline = sline.strip()
        parts = sline.split()
        print(parts)
        if parts and parts[0].upper() == "INPUT":
            consts[parts[2]] = "DSIN"
            print(parts[2])
        if parts and parts[0].upper() == "OUTPUT":
            consts[parts[2]] = "DSOUT"
            print(parts[2])

for line in ifile:
    sline = line[:]

    if sline.find(";") != -1:
        sline, comment = sline[:sline.find(";")], sline[sline.find(";"):]
    else:
        comment = ""
    if sline.find(":") != -1:
        sline, label = sline[sline.find(":")+1:], sline[:sline.find(":")+1]
    else:
        label = ""

    # print(sline)
    
    if new_format == "kcpsm":
        parts = sline.split()
        '''if len(parts) == 3 and parts[1].upper() in ["DSIN", "DSOUT"]:
            sline = "CONSTANT" + parts[0] + ", " + parts[2]'''
        sline = re.sub(r"(\s*)(\w+)(\s+)(DSIN|DSOUT)(\s+)(\$)([0-9a-f]{1,2})(.*)", r"\1CONSTANT\3\2,\5\7", sline)

        a, b = 1, 0
        sline = re.sub(iref_kcpsm_re, iref_kcpsm_sub, sline, re.IGNORECASE)

        sline = re.sub(r"\s\$([0-9a-f]{1,2})", r"\1", sline, re.IGNORECASE)

    else:
        parts = sline.split(",")
        if len(parts) == 2:
            parts = parts[0].split() + [parts[1]]
            print(parts)
            if parts[0].upper() == "CONSTANT":
                # sline = parts[1] + " " + consts[parts[1]] + parts[2]
                sline = re.sub(r"(\s*)(CONSTANT)(\s+)(\w+)(\s*,\s*)([0-9a-f]{1,2})(.*)", r"\1\4\3" + consts[parts[1]] + r"\3\6", sline)


        a, b = 0, 1
        sline = re.sub(iref_pblaze_re, iref_pblaze_sub, sline, re.IGNORECASE)

        sline = re.sub(r"([\s,]+)([0-9a-f]{1,2})", r"\1$\2", sline, re.IGNORECASE)

    for r in subs:
        sline = re.sub(re.escape(r[a]), re.escape(r[b]), sline, re.IGNORECASE)
        
    outline = label + sline + comment
    if outline[-1] != "\n":
        outline += "\n"

    ofile.write(outline)

ofile.close()







