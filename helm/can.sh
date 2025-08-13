#!/usr/bin/env bash

set -euo pipefail

# 專案路徑
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TARGET_DIR="$PROJECT_ROOT/web/canvaskit"

echo "[can.sh] 專案根目錄: $PROJECT_ROOT"

# 1) 取得 flutter 可執行檔
FLUTTER_BIN="$(command -v flutter || true)"
if [[ -z "${FLUTTER_BIN}" ]]; then
  echo "[can.sh] 找不到 flutter 可執行檔，請先將 Flutter 加入 PATH，或安裝/設定 fvm 後重試。"
  echo "例如：brew install fvm && fvm install stable && fvm global stable"
  exit 1
fi
echo "[can.sh] flutter 可執行檔: $FLUTTER_BIN"

# 2) 嘗試定位 canvaskit 來源資料夾
# Flutter SDK 典型結構: <flutter>/bin/cache/flutter_web_sdk/canvaskit
FLUTTER_BIN_DIR="$(cd "$(dirname "$FLUTTER_BIN")" && pwd)"
FLUTTER_ROOT="$(cd "$FLUTTER_BIN_DIR/.." && pwd)"

CANDIDATE_1="$FLUTTER_ROOT/bin/cache/flutter_web_sdk/canvaskit"
CANDIDATE_2="$FLUTTER_BIN_DIR/cache/flutter_web_sdk/canvaskit"

SRC_DIR=""
if [[ -d "$CANDIDATE_1" ]]; then
  SRC_DIR="$CANDIDATE_1"
elif [[ -d "$CANDIDATE_2" ]]; then
  SRC_DIR="$(cd "$CANDIDATE_2" && pwd)"
else
  # 最後再嘗試搜尋
  echo "[can.sh] 直接路徑找不到，嘗試搜尋 canvaskit..."
  SEARCH_BASE="$FLUTTER_ROOT"
  FOUND_PATH="$(
    find "$SEARCH_BASE" -type d -name canvaskit -path "*/flutter_web_sdk/canvaskit" 2>/dev/null | head -n 1 || true
  )"
  if [[ -n "$FOUND_PATH" && -d "$FOUND_PATH" ]]; then
    SRC_DIR="$FOUND_PATH"
  fi
fi

if [[ -z "$SRC_DIR" ]]; then
  echo "[can.sh] 找不到 canvaskit 資料夾。請先下載 web 相關快取："
  echo "  flutter precache --web"
  echo "或先執行一次 web build："
  echo "  flutter build web --web-renderer canvaskit"
  exit 2
fi

echo "[can.sh] 來源 canvaskit 目錄: $SRC_DIR"

# 3) 複製到專案 web/canvaskit
mkdir -p "$TARGET_DIR"
rm -rf "$TARGET_DIR"/*
cp -R "$SRC_DIR"/* "$TARGET_DIR"/

echo "[can.sh] 已將 canvaskit 複製到: $TARGET_DIR"
echo "[can.sh] 完成"
