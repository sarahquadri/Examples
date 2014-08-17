__author__ = 'kjoseph'

import os
from collections import defaultdict
import numpy as np

DATA_DIR = "~/datathon/data/output"
network_file = open(os.path.join(DATA_DIR,"neighb_net.csv"))
network_file.readline()
income_disp_file = open(os.path.join(DATA_DIR,"hh_inc.csv"))
income_disp_file.readline()

network = defaultdict(set)
for line in network_file:
    line_spl = line.strip().replace("\"","").split(",")
    network[line_spl[1]].add(line_spl[0])
    network[line_spl[0]].add(line_spl[1])

income_val = {}
for line in income_disp_file:
    line_spl = line.strip().replace("\"","").split(",")
    income_val[line_spl[0]] = float(line_spl[1])

output_fil = open(os.path.join(DATA_DIR,"income_disparity.csv"),"w")
output_fil.write("hood,disparity_sum,disparity_mean,disparity_median,n_neigh\n")
for hood, hood_income in income_val.iteritems():
    disparity = []

    for neighbor in network[hood]:
        disparity.append(hood_income-income_val[neighbor])

    output_fil.write(",".join([hood,
                               str(sum(disparity)),
                               str(np.mean(disparity)),
                               str(np.median(disparity)),
                               str(len(network[hood]))])+"\n")

output_fil.close()
network_file.close()
income_disp_file.close()
