import os
import re
import csv

def parse_ascii_list(path):
    if not os.path.exists(path):
        return None
    with open(path, "r", errors="ignore") as f:
        content = f.read()
    # Find block of numbers inside parentheses
    match = re.search(r"nonuniform List<scalar>\s*\d+\s*\(([\s\S]*?)\)\s*;", content)
    if not match:
        match_uni = re.search(r"internalField\s+uniform\s+([\d\.\-e]+);", content)
        if match_uni:
            return float(match_uni.group(1))
        return None
    data_str = match.group(1)
    # Split by whitespace and convert to float list
    return [float(x) for x in data_str.split()]

def extract_case_scour(case_dir):
    cx_path = os.path.join(case_dir, "0/Cx")
    cy_path = os.path.join(case_dir, "0/Cy")
    
    # If the file names are lowercase
    if not os.path.exists(cx_path):
        cx_path = os.path.join(case_dir, "0/cx")
        cy_path = os.path.join(case_dir, "0/cy")
        
    cx = parse_ascii_list(cx_path)
    cy = parse_ascii_list(cy_path)
    
    if cx is None or cy is None:
        print(f"[{case_dir}] Cell center coordinates not found.")
        return
        
    time_dirs = sorted([d for d in os.listdir(case_dir) if os.path.isdir(os.path.join(case_dir, d)) and d.replace('.','',1).isdigit()], key=float)
    
    for t_dir in time_dirs:
        alpha_path = os.path.join(case_dir, t_dir, "alpha.a")
        alpha = parse_ascii_list(alpha_path)
        if alpha is not None:
            # Group by unique x coordinate and find the maximum y coordinate where alpha.a >= 0.3
            # To handle floating point precision in x, we round to 4 decimals
            bed_points = {}
            for i in range(len(cx)):
                x_val = round(cx[i], 4)
                y_val = cy[i]
                a_val = alpha[i] if isinstance(alpha, list) else alpha
                
                # Bed interface is where there is sediment (alpha.a <= 0.9)
                if a_val <= 0.9:
                    if x_val not in bed_points:
                        bed_points[x_val] = y_val
                    else:
                        bed_points[x_val] = max(bed_points[x_val], y_val)
            
            if bed_points:
                # Find maximum scour depth (minimum y coordinate at the bed surface)
                # Compare it against initial bed level y=0.0
                max_scour_x = min(bed_points, key=bed_points.get)
                max_scour_y = bed_points[max_scour_x]
                scour_depth = -max_scour_y # Scour depth below y=0
                # Filter out values that are above the initial bed level (e.g. deposition)
                if scour_depth < 0:
                    scour_depth = 0.0
                print(f"[{case_dir}] Time {t_dir}s: Max Scour Depth = {scour_depth*1000:.2f} mm at x = {max_scour_x:.3f} m")

print("Extracting scour details...")
extract_case_scour("Exp_01a_UnderDeckScour")
extract_case_scour("Exp_03b_DownstreamScour")
