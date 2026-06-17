---
name: pourdisk
description: Safety-first local storage cleanup for macOS. Use when Codex needs to help a user recover disk space, audit large local folders, classify app caches and application data, clean browser/developer caches, inspect macOS Library/Containers, or safely remove storage-heavy app data only after explicit user confirmation.
---

# Pourdisk

Pourdisk helps recover macOS disk space without treating deletion as the first move. Audit first, classify risk, ask for confirmation, delete only approved paths, then verify the result.

## Core Rules

- Say "storage" or "disk space" unless the user is truly asking about RAM.
- Never delete before showing a candidate list and receiving explicit approval.
- Prefer app-provided cleanup UI for user data when available. Use filesystem deletion mainly for caches, logs, temporary files, and user-approved app containers.
- Preserve user data by default: Desktop, Documents, Downloads, Photos, iCloud Drive, Obsidian vaults, source repos, email stores, chat message databases, and anything named `msg`, `Message`, `Documents`, `Photos Library`, `Mobile Documents`, or `xwechat_files/.../msg`.
- Do not use `sudo` unless the user specifically asks and understands the risk.
- If a command requires escalated filesystem access, request approval and explain exactly which paths will be removed.
- After deletion, run `df -h` and re-check the affected directories.

## Workflow

1. **Triage**
   - Run `df -h / "$HOME"` to determine urgency.
   - If free space is below 2 GB, prioritize large safe wins and avoid long scans across the whole disk.

2. **Audit**
   - Run `scripts/macos_storage_audit.sh` when available.
   - If the script is not usable, manually inspect with `du -xhd 1 "$HOME"`, `~/Library`, `~/Library/Caches`, `~/Library/Containers`, `~/Library/Application Support`, `~/.cache`, `~/.npm`, and `~/Downloads`.

3. **Classify**
   - Green: rebuildable caches and logs. Examples: browser caches, `~/Library/Caches/*`, `~/.npm/_cacache`, `~/Library/pnpm`, `~/.cache/uv`, pip cache, node-gyp cache, Homebrew cache.
   - Yellow: app storage that can affect offline state or require re-login/re-download. Examples: Feishu/Lark Service Worker caches, WeChat mini-program packages, non-persistent stickers, app-specific temporary files.
   - Red: personal data or local history. Examples: WeChat `xwechat_files/.../msg`, Mail/Outlook stores, Photos libraries, synced document folders, project repos, downloaded files not reviewed by the user.

4. **Confirm**
   - Show paths, sizes, risk labels, and expected impact.
   - Ask the user which groups to delete. A broad "yes" applies only to the listed candidates, not to new paths discovered later.

5. **Delete**
   - Delete only confirmed paths.
   - Quote paths carefully. Avoid wildcards in destructive commands unless the expanded paths have already been shown.
   - For stuck permissions in cache directories, stop and report leftovers instead of escalating automatically.

6. **Verify**
   - Show before/after free space.
   - Re-run `du -sh` for changed app containers.
   - Mention likely first-run effects: apps may reload caches, webviews may be slower, and offline content may need to download again.

## macOS Targets

### Usually Safe After Confirmation

- `~/Library/Caches/Google`
- `~/Library/Caches/Homebrew`
- `~/.npm/_cacache`
- `~/Library/pnpm`
- `~/.cache/uv`
- `~/Library/Caches/pip`
- `~/Library/Caches/node-gyp`
- `~/Library/Logs`

### Feishu/Lark Candidates

Inspect `~/Library/Containers/com.bytedance.macos.feishu`.

Prioritize:

- `Data/Library/Application Support/LarkShell/**/Service Worker`
- `Data/Library/Application Support/LarkShell/PC_Gadget`
- `Data/Library/Application Support/LarkShell/sdk_storage/log`
- `Data/Library/Application Support/LarkShell/Cache`
- `Data/Library/Application Support/LarkShell/CodeCache`
- `Data/Library/Application Support/LarkShell/GPUCache`
- `Data/Library/Application Support/LarkShell/ShaderCache`

Expected impact: Feishu webviews, docs, mini-apps, and offline pages rebuild caches. Cloud chat data should remain, but users may see slower first launch or app re-login prompts.

### WeChat Candidates

Inspect `~/Library/Containers/com.tencent.xinWeChat`.

Prioritize:

- `Data/Library/Application Support/com.tencent.xinWeChat/*/*/Stickers/NonPersistence`
- `Data/.wxapplet`
- `Data/Documents/xwechat_files/*/cache`
- `Data/Documents/app_data/log`
- `Data/Library/Application Support/com.tencent.xinWeChat/*/*/Message/MessageTemp`
- `Data/Library/Application Support/com.tencent.xinWeChat/*/MMResourceMgr`

Avoid unless the user explicitly accepts local chat media/history loss:

- `Data/Documents/xwechat_files/*/msg`
- `Data/Documents/xwechat_files`
- `Data/Library/Application Support/com.tencent.xinWeChat/*/*/Message`
- `Favorites`, `Contact`, `Group`, persistent stickers, downloaded files

## Script

Use:

```bash
./scripts/macos_storage_audit.sh
```

The script is read-only. It prints disk usage, top user folders, top Library areas, common developer caches, and large app containers. Use its output to prepare the confirmation list.
