#!/bin/bash

report=$(hdfs dfsadmin -report)

# Check number of live datanodes
live_nodes=$(echo "$report" | grep -c "^Name:")
if [ "$live_nodes" -ne 4 ]; then
  echo "エラー: Live datanodes の数が $live_nodes 台です（4台である必要があります）"
  exit 1
fi

# Prepare to extract block info and type
node_types=()
zero_block_count=0

# Parse the report
while IFS= read -r line; do
  if [[ "$line" == Name:* ]]; then
    # Extract hostname
    host=$(echo "$line" | sed -n 's/.*(\(.*\)).*/\1/p')
  fi

  if [[ "$line" == "Num of Blocks:"* ]]; then
    block_count=$(echo "$line" | awk '{print $NF}')
    if [[ "$block_count" -eq 0 ]]; then
      zero_block_count=$((zero_block_count + 1))
    else
      # Judge ssd or hdd by hostname
      if [[ "$host" == *ssd* ]]; then
        node_types+=("ssd")
      elif [[ "$host" == *hdd* ]]; then
        node_types+=("hdd")
      else
        node_types+=("unknown")
      fi
    fi
  fi
done <<< "$report"

# Check that exactly two nodes have 0 blocks
if [[ "$zero_block_count" -ne 2 ]]; then
  echo "エラー: Num of Blocks が 0 のノードが2台ではありません（現在: $zero_block_count 台）"
  exit 1
fi

# Check consistency of remaining node types
if [[ "${#node_types[@]}" -ne 2 ]]; then
  echo "エラー: Num of Blocks ≠ 0 のノードが2台でない"
  exit 1
fi

if [[ "${node_types[0]}" == "${node_types[1]}" ]]; then
  echo "${node_types[0]}"
else
  echo "エラー: 残りの2ノードが ssd と hdd に分かれています"
  exit 1
fi
