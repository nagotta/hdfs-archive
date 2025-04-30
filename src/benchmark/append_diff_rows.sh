#!/bin/bash

file_a="$1"  # 追記先
file_b="$2"  # 差分元（新しいはずのファイル）

# 存在確認
if [[ ! -f "$file_a" || ! -f "$file_b" ]]; then
    echo "どちらかのファイルが存在しません。"
    exit 1
fi

# タイムスタンプ取得（秒数）
mtime_a=$(stat -c %Y "$file_a")
mtime_b=$(stat -c %Y "$file_b")

# Aの方が新しい場合は確認
if [[ "$mtime_a" -gt "$mtime_b" ]]; then
    echo "⚠️ 注意: $file_a の方が $file_b より新しいです。"
    echo "このまま実行しますか？ [y/N]"
    read -r answer
    if [[ "$answer" != "y" && "$answer" != "Y" ]]; then
        echo "中止しました。"
        exit 0
    fi
fi

# 差分抽出＆追記
tail -n +2 "$file_b" | grep -Fvxf <(tail -n +2 "$file_a") >> "$file_a"

echo "✅ 差分の追記が完了しました。"
