#!/bin/bash

INPUT_FILE="$1"

if [ -z "$INPUT_FILE" ]; then
  echo "使い方: $0 <TestDFSIO出力ファイル>"
  exit 1
fi

# 出力先CSVファイル（入力ファイルと同じディレクトリにoutput.csv）
OUTPUT_DIR=$(dirname "$INPUT_FILE")
OUTPUT_FILE="${OUTPUT_DIR}/output.csv"

# ヘッダがまだなければ追加
if [ ! -f "$OUTPUT_FILE" ]; then
  echo "type,date,num_files,total_MB,throughput,avg_io_rate,io_stddev,exec_time" > "$OUTPUT_FILE"
fi

# 初期化
type=""
date=""
num_files=""
total_MB=""
throughput=""
avg_io_rate=""
io_stddev=""
exec_time=""

while IFS= read -r line || [[ -n "$line" ]]; do
  line=$(echo "$line" | tr -d '\r')  # CR削除
  case "$line" in
    "----- TestDFSIO ----- :"*)
      type=$(echo "$line" | awk '{print $5}')
      ;;
    " "*Date*"time:"*)
      date=$(echo "$line" | cut -d: -f2- | sed 's/^ *//' | tr -d '\r\n')
      ;;
    " "*Number\ of\ files:*)
      num_files=$(echo "$line" | awk '{print $NF}' | tr -d '\r\n')
      ;;
    " "*Total\ MBytes\ processed:*)
      total_MB=$(echo "$line" | awk '{print $NF}' | tr -d '\r\n')
      ;;
    " "*Throughput\ mb/sec:*)
      throughput=$(echo "$line" | awk '{print $NF}' | tr -d '\r\n')
      ;;
    " "*Average\ IO\ rate\ mb/sec:*)
      avg_io_rate=$(echo "$line" | awk '{print $NF}' | tr -d '\r\n')
      ;;
    " "*IO\ rate\ std\ deviation:*)
      io_stddev=$(echo "$line" | awk '{print $NF}' | tr -d '\r\n')
      ;;
    " "*Test\ exec\ time\ sec:*)
      exec_time=$(echo "$line" | awk '{print $NF}' | tr -d '\r\n')
      echo "$type,\"$date\",$num_files,$total_MB,$throughput,$avg_io_rate,$io_stddev,$exec_time" >> "$OUTPUT_FILE"
      ;;
  esac
done < "$INPUT_FILE"
