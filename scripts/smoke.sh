#!/usr/bin/env bash
# 轻量冒烟：文档站文件齐全 + 生成 chatDoc.json + PHP 起站探测
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

fail() { echo "✗ $1" >&2; exit 1; }
ok() { echo "✓ $1"; }

command -v php >/dev/null || fail "需要 PHP"
[[ -f index.html ]] || fail "缺少 index.html"
[[ -f chatDoc/chatDoc.php ]] || fail "缺少 chatDoc/chatDoc.php"
[[ -d chatDoc ]] || fail "缺少 chatDoc/"
ok "核心文件齐全"

# 在 chatDoc 目录生成索引 JSON
( cd chatDoc && php chatDoc.php >/dev/null )
[[ -f chatDoc/chatDoc.json ]] || fail "chatDoc.json 未生成"
grep -q '"count"' chatDoc/chatDoc.json || fail "chatDoc.json 格式异常"
ok "chatDoc.json 已生成"

PORT="${SMOKE_PORT:-18090}"
php -S "127.0.0.1:${PORT}" -t "$ROOT" >/tmp/ai-weekly-smoke.log 2>&1 &
PID=$!
cleanup() { kill "$PID" 2>/dev/null || true; }
trap cleanup EXIT

for i in $(seq 1 30); do
  if curl -sf "http://127.0.0.1:${PORT}/" >/dev/null 2>&1; then break; fi
  sleep 0.2
done

curl -sf "http://127.0.0.1:${PORT}/" | grep -qi 'html' || fail "首页无响应"
ok "首页 200"
curl -sf "http://127.0.0.1:${PORT}/chatDoc/chatDoc.json" | grep -q 'count' || fail "JSON 不可读"
ok "chatDoc.json 可读"

echo ""
echo "smoke: ok"
