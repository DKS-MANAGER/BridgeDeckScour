import os
import re
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

def parse_ascii_list(path):
    if not os.path.exists(path):
        return None
    with open(path, "r", errors="ignore") as f:
        content = f.read()
    # Find block of numbers inside parentheses
    match = re.search(r"nonuniform List<scalar>\s*\d+\s*\(([\s\S]*?)\);", content)
    if not match:
        # Check uniform
        match_uni = re.search(r"internalField\s+uniform\s+([\d\.\-e]+);", content)
        if match_uni:
            return float(match_uni.group(1))
        return None
    data_str = match.group(1)
    return np.fromstring(data_str, sep="\n")

def read_cell_centers():
    # If cell centers were dumped, parse them
    cc_x_path = "postProcessing/writeCellCentres/0/cx"
    cc_y_path = "postProcessing/writeCellCentres/0/cy"
    if os.path.exists(cc_x_path) and os.path.exists(cc_y_path):
        return parse_ascii_list(cc_x_path), parse_ascii_list(cc_y_path)
    # Default fallback to grid approximation if no post-processed coordinates found
    return None, None

# Process time directories
time_dirs = sorted([d for d in os.listdir('.') if os.path.isdir(d) and d.replace('.','',1).isdigit()], key=float)
records = []

cx, cy = read_cell_centers()
if cx is not None and cy is not None:
    y0 = 0.12 # initial water depth for Exp-01a
    for t_dir in time_dirs:
        alpha_path = os.path.join(t_dir, "alpha.a")
        alpha = parse_ascii_list(alpha_path)
        if alpha is not None:
            # Locate y_bed(x) where alpha.a >= 0.30
            # For each unique x-coordinate, find max y cell where alpha >= 0.30
            df = pd.DataFrame({'x': cx, 'y': cy, 'alpha': alpha})
            bed = df[df['alpha'] >= 0.30].groupby('x')['y'].max().reset_index()
            if not bed.empty:
                deepest_idx = bed['y'].idxmin()
                x_maxscour = bed.loc[deepest_idx, 'x']
                S_max = -bed.loc[deepest_idx, 'y'] # Scour depth below y=0
                records.append({
                    "time": float(t_dir),
                    "x_maxscour": x_maxscour,
                    "S_max_over_y0": S_max / y0
                })

if records:
    df_out = pd.DataFrame(records)
    df_out.to_csv("scour_location.csv", index=False)
    print("Scour data extracted and saved to scour_location.csv")
else:
    print("No time directories with alpha.a found yet.")
