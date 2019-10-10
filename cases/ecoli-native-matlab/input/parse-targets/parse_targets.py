#!/usr/bin/env python3

import pandas as pd
import re

def parse_frame(df):
    print("Original products:\t", df.shape[0])
    # Discard non candidates. The second condition includes etoh, lactate, etc.
    df = df[ (df["Candidate for coupling"] == 1) | df["10% yield cMCS size"].str.contains("outflow")]
    print("Candidates:\t", df.shape[0])
    # Discard metabolies with very low yield
    df = df[df["Max. yield"] >= 0.1]
    print("Yield above 0.01:\t", df.shape[0])
    # Discard metabolites without solution
    df = df[df["50% yield cMCS size"].map(lambda x: isinstance(x, (int, float)))]
    print("Contain 50% yield cMCS:\t", df.shape[0])
    # Only keep one compartment version of each metabolite, with the perference: e > c > p
    metids = df["Metabolite ID"]
    metid_keep = []
    for metid_nc in metids.map(lambda x: re.sub("_[e,c,p]","",x)).unique():
        cand_met = metids[metids.map(lambda x: metid_nc == re.sub("_[e,c,p]","",x))]
        for candid in cand_met:
            if candid.endswith("_e"):
                metid_keep.append(candid)
                break;
            elif candid.endswith("_c"):
                metid_keep.append(candid)
                break;
            elif candid.endswith("_p"):
                metid_keep.append(candid)
            else:
                raise ValueError("Unexpected")
    df = df[df["Metabolite ID"].isin(metid_keep)]
    print("Unique compartment:\t", df.shape[0])

    # Keep target columns and modify metabolite ids
    df = df[["Metabolite ID", "Metabolite name", "50% yield cMCS knockouts"]]
    df["Metabolite ID"] = df["Metabolite ID"].map(lambda x: x.replace("M_", "") )
    df["50% yield cMCS knockouts"] = df["50% yield cMCS knockouts"].map(lambda x: re.findall("R_(.*?) ",x))
    return df

print("Anaerobic------")
df = pd.read_excel("ncomms15956-s1.xlsx", sheet_name="E. coli anaerobic", header=0)
df = parse_frame(df)
df.to_csv('anaerobic_cands.csv', index=False)
print("Aerobic--------")
df = pd.read_excel("ncomms15956-s1.xlsx", sheet_name="E. coli aerobic", header=2)
df = parse_frame(df)
df.to_csv('aerobic_cands.csv', index=False)
