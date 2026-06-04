#!/bin/bash

# Copyright (C) 2026 Marco Tusa
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License.

# Given the query:
# while true; do mysql -u<> -p<> -h <> -e "SELECT a.MEMBER_ROLE, a.MEMBER_ID, a.MEMBER_HOST, b.COUNT_TRANSACTIONS_IN_QUEUE AS certifier_queue, b.COUNT_TRANSACTIONS_REMOTE_IN_APPLIER_QUEUE AS applier_queue, ROUND((b.COUNT_TRANSACTIONS_REMOTE_IN_APPLIER_QUEUE / NULLIF(@@GLOBAL.group_replication_flow_control_applier_threshold, 0)) * 100, 2) AS threshold_pct, b.COUNT_TRANSACTIONS_LOCAL_PROPOSED AS proposed, b.COUNT_TRANSACTIONS_REMOTE_APPLIED AS applied FROM performance_schema.replication_group_members AS a JOIN performance_schema.replication_group_member_stats AS b ON a.MEMBER_ID = b.MEMBER_ID;" |tee -a `pwd`/members_lag.log;sleep 1;done;



if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <input_file> <output_file>"
    echo "Example: $0 queues_log.txt output.csv"
    exit 1
fi

INPUT_FILE="$1"
OUTPUT_FILE="$2"

if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file '$INPUT_FILE' not found!"
    exit 1
fi

awk '
BEGIN {
    OFS="," 
}

# 1. Detect header line to trigger a new block
/^MEMBER_ROLE/ {
    block_num++
    
    # Reset the per-block role counters
    for (r in role_count) role_count[r] = 0
    
    # Dynamically find the column indexes including MEMBER_HOST
    for (i = 1; i <= NF; i++) {
        if ($i == "MEMBER_ROLE") role_idx = i
        if ($i == "MEMBER_HOST") host_idx = i
        if ($i == "certifier_queue") cert_idx = i
        if ($i == "applier_queue") app_idx = i
    }
    next
}

# 2. Process actual data rows
NF >= 5 && role_idx > 0 {
    role = $role_idx
    role_count[role]++
    
    # Create a unique column prefix for this node (e.g., PRIMARY_1, SECONDARY_1)
    col_prefix = role "_" role_count[role]
    
    # If we discover a new Nth node for this role, register it for the header
    if (role_count[role] > max_role_count[role]) {
        max_role_count[role] = role_count[role]
        ordered_cols[++col_idx] = col_prefix
    }
    
    # Buffer the data in a 2D array
    data[block_num, col_prefix, "host"] = $host_idx
    data[block_num, col_prefix, "cert"] = $cert_idx
    data[block_num, col_prefix, "app"] = $app_idx
}

# 3. End of file: Print the dynamically built header, then all buffered rows
END {
    if (block_num == 0) exit
    
    # --- Print Header Row ---
    for (i = 1; i <= col_idx; i++) {
        prefix = ordered_cols[i]
        
        # Only add the MEMBER_HOST header for PRIMARY nodes
        if (prefix ~ /^PRIMARY/) {
            printf "\"%s_MEMBER_HOST\",\"%s_certifier_queue\",\"%s_applier_queue\"%s", prefix, prefix, prefix, (i == col_idx ? ORS : ",")
        } else {
            printf "\"%s_certifier_queue\",\"%s_applier_queue\"%s", prefix, prefix, (i == col_idx ? ORS : ",")
        }
    }
    
    # --- Print Data Rows ---
    for (b = 1; b <= block_num; b++) {
        for (i = 1; i <= col_idx; i++) {
            prefix = ordered_cols[i]
            
            # Fetch queue values (fallback to 0 if a node was temporarily missing)
            c_val = (data[b, prefix, "cert"] != "") ? data[b, prefix, "cert"] : "0"
            a_val = (data[b, prefix, "app"] != "") ? data[b, prefix, "app"] : "0"
            
            # Only print the host data for PRIMARY nodes
            if (prefix ~ /^PRIMARY/) {
                h_val = (data[b, prefix, "host"] != "") ? data[b, prefix, "host"] : "N/A"
                printf "\"%s\",\"%s\",\"%s\"%s", h_val, c_val, a_val, (i == col_idx ? ORS : ",")
            } else {
                printf "\"%s\",\"%s\"%s", c_val, a_val, (i == col_idx ? ORS : ",")
            }
        }
    }
}
' "$INPUT_FILE" > "$OUTPUT_FILE"

echo "Extraction complete! Data saved to '$OUTPUT_FILE'."