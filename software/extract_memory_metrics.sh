#!/bin/bash

# Copyright (C) 2026 Marco Tusa
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# Given the query below:
# while true; do mysql -u<> -p<> -h <> -e "SELECT EVENT_NAME,CURRENT_NUMBER_OF_BYTES_USED / 1024 / 1024 AS current_usage_mb FROM performance_schema.memory_summary_global_by_event_name WHERE EVENT_NAME like 'memory/%' and EVENT_NAME not like 'memory/performance%'  order by current_usage_mb desc limit 25;" | tee -a `pwd`/memory_usage.log;sleep 5;done

# The code below will allow to generate a csv file 
# Parameters are FILEIN FILEOUT



# Check if exactly two arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <input_file> <output_file>"
    echo "Example: $0 metrics.txt output.csv"
    exit 1
fi

INPUT_FILE="$1"
OUTPUT_FILE="$2"

# Check if the input file exists and is readable
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file '$INPUT_FILE' not found or cannot be read!"
    exit 1
fi

# Run the awk script to parse and pivot the data
awk '
# When we see the header line starting with EVENT_NAME, trigger a new block
/^EVENT_NAME/ {
    if (in_block) print_block()
    in_block = 1
    val_count = 0
    next
}

# Process data rows (any line inside a block with at least 2 columns)
in_block && NF >= 2 {
    key = $1
    val = $2
    
    val_count++
    # Save column headers only during the first block
    if (block_num == 0) keys[val_count] = key
    vals[val_count] = val
}

# Function to print the transposed row
function print_block() {
    # If this is the first block, print the header row first
    if (block_num == 0) {
        for (i = 1; i <= val_count; i++) {
            printf "\"%s\"%s", keys[i], (i == val_count ? ORS : ",")
        }
    }
    # Print the data values for the current block
    for (i = 1; i <= val_count; i++) {
        printf "\"%s\"%s", vals[i], (i == val_count ? ORS : ",")
    }
    block_num++
}

# Ensure the last block is printed when the file ends
END {
    if (in_block) print_block()
}
' "$INPUT_FILE" > "$OUTPUT_FILE"

echo "Success! Extraction complete. Data saved to '$OUTPUT_FILE'."