#!/bin/bash
# 使い方: bash batch_auto_exec_testdfsio.sh read ssd 10 1 0 3 4

process=$1        # read or write
target_type=$2    # ssd or hdd
filenum=$3        # 数字のみ（例: 10）
shift 3           # 上記3つをshiftして、残りを実行回数のリストとして扱う

# ファイルサイズと実行回数のリスト
filesize_list=("64MB" "128MB" "256MB" "512MB")
exec_num_list=("$@")

# チェック: 実行回数の数がファイルサイズと一致しているか
if [ "${#filesize_list[@]}" -ne "${#exec_num_list[@]}" ]; then
  echo "エラー: ファイルサイズリストと実行回数リストの長さが一致しません。"
  exit 1
fi

# 実行ループ
for i in "${!filesize_list[@]}"; do
  exec_num=${exec_num_list[$i]}
  filesize=${filesize_list[$i]}

  if [ "$exec_num" -gt 0 ]; then
    echo "=== ${exec_num} 回実行: $process $filenum $filesize on $target_type ==="
    bash auto_exec_testdfsio.sh "$process" "$filenum" "$filesize" "$target_type" "$exec_num"
  fi
done
