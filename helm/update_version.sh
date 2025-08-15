#!/bin/bash

# MD3 API 版本更新腳本


set -e

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color


# 更新版本並重新部署腳本


echo "=== 開始更新 md3-admin-web 版本 ==="

# 解析腳本與專案根目錄，支援任意工作目錄執行
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
REPO_ROOT=$(cd "$SCRIPT_DIR/.." && pwd)
echo "Repo root: $REPO_ROOT"

# 0. 重新構建 web 映像檔
echo "0. 重新構建 flutter web..."
cd "$REPO_ROOT"

flutter clean
flutter pub get
echo -e "${BLUE}🚀 MD3 Admin Web Flutter更新開始${NC}"
if flutter build web -h | grep -q "web-renderer"; then
  flutter build web --release \
    --dart-define=API_URL=https://md3-api.uirapuka.com \
    --dart-define=PROXY_URL=https://md3-api.uirapuka.com \
    --web-renderer canvaskit \
    --pwa-strategy=none \
    --dart-define=FLUTTER_WEB_CANVASKIT_URL=/canvaskit/
else
  flutter build web --release \
    --dart-define=API_URL=https://md3-api.uirapuka.com \
    --dart-define=PROXY_URL=https://md3-api.uirapuka.com \
    --pwa-strategy=none \
    --dart-define=FLUTTER_WEB_USE_SKIA=true \
    --dart-define=FLUTTER_WEB_CANVASKIT_URL=/canvaskit/
fi

# 0.1 補上空的 sourcemap（有效 JSON），避免瀏覽器對 404 產生噪音
echo '{"version":3,"file":"flutter.js","sources":[],"names":[],"mappings":""}' > build/web/flutter.js.map
echo '{"version":3,"file":"main.dart.js","sources":[],"names":[],"mappings":""}' > build/web/main.dart.js.map


echo -e "${BLUE}🚀 MD3 Admin Web Flutter更新完成${NC}"
echo ""

# 1. 重新構建映像檔
echo "1. 重新構建 production 映像檔..."
cd "$REPO_ROOT/Docker"

# 更新 Docker 基礎映像檔以避免簽章問題
echo "1.1 更新 Docker 基礎映像檔..."

# 更新 Docker 映像檔
perl production.pl

# 2. 獲取新版本號
NEW_VERSION=$(cat "$REPO_ROOT/Docker/Version/production.ver")
echo "2. 新版本號: $NEW_VERSION"
# 2.1 檢查Image 是否已經存在 Docker Hub
echo "2.1 檢查Image 是否已經存在 Docker Hub..."
docker manifest inspect kt71020/md3-admin:${NEW_VERSION} > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}版本 ${NEW_VERSION} 已經存在 Docker Hub${NC}"
    echo ""
else
    echo "Image 不存在 Docker Hub"
    echo -e "${RED}版本 ${NEW_VERSION} 不存在 Docker Hub${NC}"
    echo -e "${RED}請先更新版本號，並重新執行腳本${NC}"
    echo ""
    exit 1
fi

# 3. 更新 k8s 配置文件  
echo "3. 更新 Helm 配置文件..."
cd "$REPO_ROOT/helm"

# 查找當前使用的版本
APP_VERSION=$(helm show chart "$REPO_ROOT/helm/md3-admin-web" | awk -F': *' '/^appVersion:/ {print $2; exit}')
CURRENT_VERSION=$APP_VERSION

echo -e "${BLUE}🚀 MD3 Admin Web 版本更新開始${NC}"
echo -e "${BLUE}目前版本: ${CURRENT_VERSION}${NC}"
echo -e "${BLUE}新版本: ${NEW_VERSION}${NC}"
echo ""

echo -e "${BLUE}更新 Helm 版本: ${NEW_VERSION}${NC}"
helm upgrade --install md3-admin-web md3-admin-web -n adm-md3-web --set image.tag=${NEW_VERSION}




echo "部署完成"
