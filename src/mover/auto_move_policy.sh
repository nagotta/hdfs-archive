#!/bin/bash

move_path="/"
target_type="$1"  # "ssd" または "hdd" を指定して実行する

# 対応するストレージポリシーを設定
if [ "$target_type" == "hdd" ]; then
  valid_policy="HOT"
elif [ "$target_type" == "ssd" ]; then
  valid_policy="ALL_SSD"
else
  echo "エラー: 第一引数には 'ssd' または 'hdd' を指定してください"
  exit 1
fi

# 現在のデータノードタイプを確認
current_type=$(./check_datanodes.sh)

if [ "$target_type" != "$current_type" ]; then
  echo "現在の構成は '$current_type'、目標は '$target_type' です。ストレージポリシーを変更します。"

  # ストレージポリシーを変更
  hdfs storagepolicies -setStoragePolicy -path "$move_path" -policy "$valid_policy"
  if [ $? -ne 0 ]; then
    echo "エラー: ストレージポリシーの設定に失敗しました"
    exit 1
  fi

  # ストレージを移動（同期的に完了まで待つ）
  hdfs mover -p "$move_path"
  if [ $? -ne 0 ]; then
    echo "エラー: ストレージ移動に失敗しました"
    exit 1
  fi

  echo "ストレージポリシーの変更と移行が完了しました"
else
  echo "現在のデータノード構成 '$current_type' はすでに一致しています。変更は不要です。"
fi
