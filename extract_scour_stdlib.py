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
    
    # Try latest time if 0/ doesn't have it
    time_dirs = sorted([d for d in os.listdir(case_dir) if os.path.isdir(os.path.join(case_dir, d)) and d.replace('.','',1).isdigit()], key=float)
    if not os.path.exists(cx_path) and time_dirs:
        latest_time = time_dirs[-1]
        cx_path = os.path.join(case_dir, latest_time, "Cx")
        cy_path = os.path.join(case_dir, latest_time, "Cy")
        
    if not os.path.exists(cx_path):
        cx_path = os.path.join(case_dir, "0/cx")
        cy_path = os.path.join(case_dir, "0/cy")
        if not os.path.exists(cx_path) and time_dirs:
            latest_time = time_dirs[-1]
            cx_path = os.path.join(case_dir, latest_time, "cx")
            cy_path = os.path.join(case_dir, latest_time, "cy")
        
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
                
                # Bed interface is where there is sediment (alpha.a >= 0.3)
                if a_val >= 0.3:
                    if x_val not in bed_points:
                        bed_points[x_val] = y_val
                    else:
                        bed_points[x_val] = max(bed_points[x_val], y_val)
            
            if bed_points:
                # Filter points to test section (x >= -0.1 m) to avoid inlet boundary artifacts
                test_section_points = {x: y for x, y in bed_points.items() if x >= -0.1}
                if test_section_points:
                    max_scour_x = min(test_section_points, key=test_section_points.get)
                    max_scour_y = test_section_points[max_scour_x]
                    scour_depth = -max_scour_y
                    if scour_depth < 0:
                        scour_depth = 0.0
                    print(f"[{case_dir}] Time {t_dir}s: Max Scour Depth (x >= -0.1m) = {scour_depth*1000:.2f} mm at x = {max_scour_x:.3f} m")
                    
                    # Write profile to CSV
                    csv_name = f"{case_dir}_bed_profile_{t_dir}.csv"
                    with open(csv_name, "w", newline="") as csvfile:
                        writer = csv.writer(csvfile)
                        writer.writerow(["x_m", "y_bed_m", "scour_depth_mm"])
                        for x_val in sorted(bed_points.keys()):
                            y_bed = bed_points[x_val]
                            writer.writerow([x_val, y_bed, max(-y_bed * 1000, 0.0)])
                    print(f"[{case_dir}] Saved bed profile to {csv_name}")

print("Extracting scour details...")
extract_case_scour("Exp_01a_UnderDeckScour")
extract_case_scour("Exp_03b_DownstreamScour")
