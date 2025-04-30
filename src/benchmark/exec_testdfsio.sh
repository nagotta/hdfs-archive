#!/bin/bash

# これはTestDFSIOを実行するためのスクリプト
# 実行時に処理を行うパスが目的とあっているかの確認が必要

# ベースコマンド
io_hdfs_path="/user/mapred/benchmarks/TestDFSIO"
base_cmd="${HADOOP_HOME}/bin/hadoop jar ${HADOOP_HOME}/share/hadoop/mapreduce/hadoop-mapreduce-client-jobclient-3.4.1-tests.jar TestDFSIO -D test.build.data=$io_hdfs_path"

# 有効なオプション
valid_options=("-clean" "-write" "-read")
valid_units=("KB" "MB" "GB")

# 入力チェック
input_option="$1"
num_files="$2"
file_size="$3"

# オプションが有効かどうか確認
is_valid_option=false
for opt in "${valid_options[@]}"; do
  if [[ "$input_option" == "$opt" ]]; then
    is_valid_option=true
    break
  fi
done

if ! $is_valid_option; then
  echo "エラー: 無効なオプションです。-clean, -write, -read のいずれかを指定してください。"
  exit 1
fi

# -clean の場合はそれだけで実行
if [[ "$input_option" == "-clean" ]]; then
  eval "$base_cmd $input_option"
  exit 0
fi

# -write または -read の場合は nrFiles と fileSize のチェックが必要
# nrFiles は整数である必要あり
if ! [[ "$num_files" =~ ^[0-9]+$ ]]; then
  echo "エラー: 第2引数はファイル数の整数を指定してください。"
  exit 1
fi

# fileSize は整数＋単位（KB, MB, GB）である必要あり
unit_valid=false
for unit in "${valid_units[@]}"; do
  if [[ "$file_size" =~ ^[0-9]+$unit$ ]]; then
    unit_valid=true
    break
  fi
done

if ! $unit_valid; then
  echo "エラー: 第3引数はファイルサイズとして数値+単位（KB, MB, GB）の形式で指定してください。例: 256MB"
  exit 1
fi

# コマンドを組み立てて実行
cmd="$base_cmd $input_option -nrFiles $num_files -fileSize $file_size"
eval "$cmd"

