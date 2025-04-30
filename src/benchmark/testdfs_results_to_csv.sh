#!/bin/bash

INPUT_FILE="$1"

if [ -z "$INPUT_FILE" ]; then
  echo "使い方: $0 <TestDFSIO出力ファイル>"
  exit 1
fi

OUTPUT_DIR=$(dirname "$INPUT_FILE")
OUTPUT_FILE="${OUTPUT_DIR}/output.csv"

# ヘッダ出力（既にあればスキップ）
if [ ! -f "$OUTPUT_FILE" ]; then
  echo "type,date,num_files,total_MB,throughput,avg_io_rate,io_stddev,exec_time" > "$OUTPUT_FILE"
fi

# 処理
buffer=()
capture=false

while IFS= read -r line || [[ -n "$line" ]]; do
  if echo "$line" | grep -q -- "----- TestDFSIO ----- :"; then
    buffer=()
    buffer+=("$line")
    capture=true
    continue
  fi

  if $capture; then
    buffer+=("$line")
    if [ "${#buffer[@]}" -eq 8 ]; then
      # 正確に値を抽出（sedでログ部分を除去）
      type=$(echo "${buffer[0]}" | sed -n 's/.*----- TestDFSIO ----- : //p' | xargs)
      date=$(echo "${buffer[1]}" | sed -n 's/.*Date & time: //p' | xargs)
      num_files=$(echo "${buffer[2]}" | sed -n 's/.*Number of files: //p' | xargs)
      total_MB=$(echo "${buffer[3]}" | sed -n 's/.*Total MBytes processed: //p' | xargs)
      throughput=$(echo "${buffer[4]}" | sed -n 's/.*Throughput mb\/sec: //p' | xargs)
      avg_io_rate=$(echo "${buffer[5]}" | sed -n 's/.*Average IO rate mb\/sec: //p' | xargs)
      io_stddev=$(echo "${buffer[6]}" | sed -n 's/.*IO rate std deviation: //p' | xargs)
      exec_time=$(echo "${buffer[7]}" | sed -n 's/.*Test exec time sec: //p' | xargs)

      echo "$type,\"$date\",$num_files,$total_MB,$throughput,$avg_io_rate,$io_stddev,$exec_time" >> "$OUTPUT_FILE"

      capture=false
    fi
  fi
done < "$INPUT_FILE"
