#!/bin/bash

if [ $# -lt 1 ]; then
  echo usage: "$0" N
  echo where N is the length of the HP sequences to test
  exit 1
fi

FOLDER=./hp_folder

# Set the length of HP sequences to test
N="$1"

# Output folders
mkdir -p all_structures

# Total sequences: 2^N
TOTAL=$((1 << N))
echo "Testing all $TOTAL sequences of length $N..."

for ((i=0; i<TOTAL; i++)); do
  # Convert to N-digit binary string (e.g., 000101)
  BIN=$(printf "%0${N}d" "$(echo "obase=2; $i" | bc)")

  # Convert binary to HP sequence (0→H, 1→P)
  SEQ=$(echo "$BIN" | tr '01' 'HP')

  # Skip bad conversions
  if [[ -z "$SEQ" || ${#SEQ} -ne $N ]]; then
    continue
  fi

  # Run the sequence
  OUTPUT=$("$FOLDER" "$SEQ" 2>&1)

  if echo "$OUTPUT" | grep -q "Found 1 optimal solutions"; then
    echo "✅ Unique: $SEQ"
    echo "$SEQ" >> all_unique.txt

    # Save the fold structure
    STRUCT=$(echo "$OUTPUT" | awk '/---/{f=1} f; /---/{if (++count==2) exit}')
    mkdir -p "all_structures/${N}"
    echo "$STRUCT" > "all_structures/${N}/${SEQ}.txt"
  else
    echo "❌ Non-unique: $SEQ"
  fi
done

