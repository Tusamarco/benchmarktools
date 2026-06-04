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
    echo "Example: $0 log.txt output.csv"
    exit 1
fi

INPUT_FILE="$1"
OUTPUT_FILE="$2"

if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file '$INPUT_FILE' not found!"
    exit 1
fi

awk -F '\t' '
BEGIN {
    # Output Field Separator for standard CSV
    OFS="," 
}

# 1. Detect header line which indicates the start of a NEW block
/^channel_name/ {
    # If we have collected data from a previous block, print its averages now
    if (has_data) print_block()
    
    cols = NF
    for (i = 1; i <= NF; i++) {
        gsub(/\r$/, "", $i)
        header[i] = $i
        
        if ($i == "SQL_thread") sql_col_idx = i
        if ($i == "channel_name") chan_idx = i
    }
    if (!chan_idx) chan_idx = 1
    
    # Print the CSV header row only the very first time we see it
    if (!header_printed) {
        for (i = 1; i <= cols; i++) {
            printf "\"%s\"%s", header[i], (i == cols ? ORS : ",")
        }
        header_printed = 1
    }
    
    # Reset accumulators for the new block
    has_data = 0
    chan_count = 0
    delete count
    delete sum
    delete val
    delete chan_list
    next
}

# 2. Ignore garbage lines (like the mysql Warning) or empty lines
/^mysql:/ || NF < 2 { 
    next 
}

# 3. Process actual data rows
{
    gsub(/\r$/, "", $NF)
    
    # Only process if the SQL_thread column is "ON"
    if (sql_col_idx > 0 && $sql_col_idx == "ON") {
        has_data = 1
        c = $chan_idx
        
        if (!(c in count)) {
            chan_list[++chan_count] = c
        }
        
        count[c]++
        
        for (i = 1; i <= cols; i++) {
            if (count[c] == 1) val[c, i] = $i
            
            # If numeric, add to the sum
            if ($i ~ /^-?([0-9]+|[0-9]*\.[0-9]+)$/) {
                sum[c, i] += $i
                is_num[i] = 1
            }
        }
    }
}

# Function to print the averaged row for the current block
function print_block() {
    for (j = 1; j <= chan_count; j++) {
        c = chan_list[j]
        for (i = 1; i <= cols; i++) {
            if (is_num[i] && i != chan_idx) {
                avg = sum[c, i] / count[c]
                printf "\"%s\"%s", avg, (i == cols ? ORS : ",")
            } else {
                printf "\"%s\"%s", val[c, i], (i == cols ? ORS : ",")
            }
        }
    }
}

# 4. End of file: ensure the final block gets printed
END {
    if (has_data) print_block()
}
' "$INPUT_FILE" > "$OUTPUT_FILE"

echo "Extraction complete! Averaged block data saved to '$OUTPUT_FILE'."