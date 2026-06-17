#!/usr/bin/env bash
set -u

HOME_DIR="${1:-$HOME}"

print_section() {
  printf '\n## %s\n\n' "$1"
}

top_du() {
  local depth="$1"
  local path="$2"
  local limit="${3:-30}"

  if [ -d "$path" ]; then
    du -xhd "$depth" "$path" 2>/dev/null | sort -h | tail -n "$limit"
  else
    printf 'missing\t%s\n' "$path"
  fi
}

size_paths() {
  for path in "$@"; do
    if [ -e "$path" ]; then
      du -sh "$path" 2>/dev/null
    fi
  done
}

print_section "Disk Space"
df -h / "$HOME_DIR" 2>/dev/null

print_section "Top Home Folders"
top_du 1 "$HOME_DIR" 35

print_section "Top Library Areas"
top_du 1 "$HOME_DIR/Library" 35

print_section "Top User Caches"
top_du 1 "$HOME_DIR/Library/Caches" 40

print_section "Developer Caches"
size_paths \
  "$HOME_DIR/.npm" \
  "$HOME_DIR/.npm/_cacache" \
  "$HOME_DIR/Library/pnpm" \
  "$HOME_DIR/.cache" \
  "$HOME_DIR/.cache/uv" \
  "$HOME_DIR/Library/Caches/pip" \
  "$HOME_DIR/Library/Caches/node-gyp" \
  "$HOME_DIR/Library/Caches/Homebrew" \
  "$HOME_DIR/Library/Caches/ms-playwright"

print_section "Application Support"
top_du 1 "$HOME_DIR/Library/Application Support" 40

print_section "Largest Containers"
top_du 1 "$HOME_DIR/Library/Containers" 40

print_section "Common Chat And Work Apps"
size_paths \
  "$HOME_DIR/Library/Containers/com.bytedance.macos.feishu" \
  "$HOME_DIR/Library/Containers/com.tencent.xinWeChat" \
  "$HOME_DIR/Library/Containers/com.tencent.WeWorkMac" \
  "$HOME_DIR/Library/Containers/com.tencent.qq" \
  "$HOME_DIR/Library/Containers/com.alibaba.DingTalkMac" \
  "$HOME_DIR/Library/Application Support/DingTalkMac" \
  "$HOME_DIR/Library/Application Support/discord" \
  "$HOME_DIR/Library/Containers/com.microsoft.Outlook"

print_section "Feishu Detail"
size_paths \
  "$HOME_DIR/Library/Containers/com.bytedance.macos.feishu/Data/Library/Application Support/LarkShell/iron/users" \
  "$HOME_DIR/Library/Containers/com.bytedance.macos.feishu/Data/Library/Application Support/LarkShell/aha/users" \
  "$HOME_DIR/Library/Containers/com.bytedance.macos.feishu/Data/Library/Application Support/LarkShell/PC_Gadget" \
  "$HOME_DIR/Library/Containers/com.bytedance.macos.feishu/Data/Library/Application Support/LarkShell/sdk_storage/log" \
  "$HOME_DIR/Library/Containers/com.bytedance.macos.feishu/Data/Library/Application Support/LarkShell/Cache" \
  "$HOME_DIR/Library/Containers/com.bytedance.macos.feishu/Data/Library/Application Support/LarkShell/CodeCache"

print_section "WeChat Detail"
size_paths \
  "$HOME_DIR/Library/Containers/com.tencent.xinWeChat/Data/.wxapplet" \
  "$HOME_DIR/Library/Containers/com.tencent.xinWeChat/Data/Documents/app_data/log" \
  "$HOME_DIR/Library/Containers/com.tencent.xinWeChat/Data/Documents/xwechat_files" \
  "$HOME_DIR/Library/Containers/com.tencent.xinWeChat/Data/Documents/xwechat_files"/*/cache \
  "$HOME_DIR/Library/Containers/com.tencent.xinWeChat/Data/Documents/xwechat_files"/*/msg \
  "$HOME_DIR/Library/Containers/com.tencent.xinWeChat/Data/Library/Application Support/com.tencent.xinWeChat"

print_section "Large Files Outside Library"
find "$HOME_DIR" -xdev -type f -size +500M \
  -not -path "$HOME_DIR/Library/*" \
  -print0 2>/dev/null | xargs -0 ls -lh 2>/dev/null | awk '{print $5 "\t" $9}'

print_section "Local Time Machine Snapshots"
tmutil listlocalsnapshots / 2>/dev/null || true
