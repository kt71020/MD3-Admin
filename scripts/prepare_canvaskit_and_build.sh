#!/usr/bin/env bash
set -euo pipefail

echo "[1/5] 檢查 flutter 與 canvaskit 來源..."
if ! command -v flutter >/dev/null 2>&1; then
  echo "找不到 flutter 指令，請先安裝/加入 PATH" >&2
  exit 1
fi

FLUTTER_BIN="$(command -v flutter)"
BASE1="$(cd "$(dirname "$FLUTTER_BIN")"/../cache 2>/dev/null && pwd || true)"
BASE2="$(cd "$(dirname "$FLUTTER_BIN")"/cache 2>/dev/null && pwd || true)"

CANVASKIT_SRC=""
for BASE in "$BASE1" "$BASE2"; do
  if [ -d "$BASE" ]; then
    # 常見路徑
    if [ -d "$BASE/flutter_web_sdk/canvaskit" ]; then
      CANVASKIT_SRC="$BASE/flutter_web_sdk/canvaskit"
      break
    fi
    # fallback 搜尋
    FOUND="$(find "$BASE" -type d -name canvaskit -maxdepth 5 -print -quit 2>/dev/null || true)"
    if [ -n "$FOUND" ] && [ -d "$FOUND" ]; then
      CANVASKIT_SRC="$FOUND"
      break
    fi
  fi
done

if [ -z "$CANVASKIT_SRC" ] || [ ! -d "$CANVASKIT_SRC" ]; then
  echo "找不到 canvaskit 目錄，先執行 flutter precache --web..."
  flutter precache --web
  # 再找一次
  for BASE in "$BASE1" "$BASE2"; do
    if [ -d "$BASE/flutter_web_sdk/canvaskit" ]; then
      CANVASKIT_SRC="$BASE/flutter_web_sdk/canvaskit"
      break
    fi
  done
fi

if [ -z "$CANVASKIT_SRC" ] || [ ! -d "$CANVASKIT_SRC" ]; then
  echo "仍找不到 canvaskit 來源，請手動指定" >&2
  exit 1
fi

echo "[2/5] 複製 CanvasKit 到 web/canvaskit ..."
mkdir -p web/canvaskit
rsync -a --delete "$CANVASKIT_SRC/" web/canvaskit/

echo "[3/5] 以 CanvasKit 建置 Flutter Web（停用 PWA）..."
flutter clean
if flutter build web -h | grep -q "web-renderer"; then
  flutter build web \
    --release \
    --web-renderer canvaskit \
    --pwa-strategy=none \
    --dart-define=FLUTTER_WEB_CANVASKIT_URL=/canvaskit/
else
  # 舊版 Flutter：以 Skia 引擎等價方式啟用 CanvasKit
  flutter build web \
    --release \
    --pwa-strategy=none \
    --dart-define=FLUTTER_WEB_USE_SKIA=true \
    --dart-define=FLUTTER_WEB_CANVASKIT_URL=/canvaskit/
fi

echo "[4/5] 建置 Docker 映像..."
docker build -f Dockerfile/production.Dockerfile -t md3-admin:web-canvaskit .

echo "[5/5] 啟動容器（http://localhost:8080）..."
docker rm -f md3-admin-web >/dev/null 2>&1 || true
docker run -d --rm -p 8080:80 --name md3-admin-web md3-admin:web-canvaskit
docker ps --filter name=md3-admin-web

echo "完成。請以 Safari 開啟 http://localhost:8080 測試。若之前有部署舊版，請清除該網域的網站資料（含 Service Worker）。"


