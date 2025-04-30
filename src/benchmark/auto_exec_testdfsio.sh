#!/bin/bash

# 引数の取得
process=$1      # read or write
filenum=$2      # 数字のみ（例: 10）
filesize=$3     # サイズ（例: 64MB, 128GB）
target_type=$4  # ssd または hdd
batch_num=$5    # 実行回数

# サポートされている操作
valid_processes=("read" "write")

# ホストマシンのIPアドレス(ドメイン/SSH用)
host_machine="host_machine"

# 引数チェック
if [[ ! " ${valid_processes[@]} " =~ " ${process} " ]]; then
  echo "エラー: 無効な操作モードです（read または write を指定してください）"
  exit 1
fi

# target_typeのチェック
if [[ "$target_type" != "ssd" && "$target_type" != "hdd" ]]; then
  echo "エラー: target_type は ssd または hdd を指定してください"
  exit 1
fi

# auto_move_policy.shを実行
bash auto_move_policy.sh "$target_type"
if [ $? -ne 0 ]; then
  echo "エラー: ストレージポリシーの変更に失敗しました"
  exit 1
fi

# 出力パスの生成
timestamp=$(date +%Y%m%d_%H%M%S)
output_path="logs/$process/${target_type}_$timestamp"
mkdir -p "$(dirname "$output_path")"

# 実行処理
if [[ "$process" == "write" ]]; then
  for ((i = 0; i < batch_num; i++)); do
    bash exec_testdfsio.sh -clean
    ssh $host_machine "echo 3 | tee /proc/sys/vm/drop_caches > /dev/null"
    if [ $? -ne 0 ]; then
        echo "警告: ホスト側のキャッシュ削除に失敗しました"
    fi
    bash exec_testdfsio.sh -$process $filenum $filesize >> "$output_path" 2>&1
  done
elif [[ "$process" == "read" ]]; then
  bash exec_testdfsio.sh -clean
  bash exec_testdfsio.sh -write $filenum $filesize >> "$output_path" 2>&1
  for ((i = 0; i < batch_num; i++)); do
    ssh $host_machine "echo 3 | tee /proc/sys/vm/drop_caches > /dev/null"
    if [ $? -ne 0 ]; then
        echo "警告: ホスト側のキャッシュ削除に失敗しました"
    fi
    bash exec_testdfsio.sh -$process $filenum $filesize >> "$output_path" 2>&1
  done
else
  echo "エラー: 不明なエラーが発生しました。"
  exit 1
fi
