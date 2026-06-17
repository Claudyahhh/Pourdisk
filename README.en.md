# Pourdisk

Pourdisk is a safety-first Codex skill for cleaning macOS disk space.

It is designed for situations where a user's Mac is running out of storage and needs help finding what can be removed without accidentally deleting personal data.

## How It Works

Pourdisk follows a five-step workflow:

1. **Audit**
   Check available disk space and scan the biggest local storage areas, including `~/Library/Caches`, `~/Library/Containers`, `~/Library/Application Support`, developer caches, and common chat/work apps.

2. **Classify**
   Group cleanup candidates by risk:
   - Green: rebuildable caches and logs
   - Yellow: app caches or offline app data that may need to reload
   - Red: personal files, chat history, local documents, or anything that should not be removed without explicit review

3. **Confirm**
   Show the user paths, sizes, risk labels, and expected impact. Nothing is deleted until the user explicitly approves the listed items.

4. **Clean**
   Delete only the approved paths. The skill avoids broad destructive commands and preserves user data by default.

5. **Verify**
   Re-check free space and affected app folders, then explain what changed and what the user may notice on first launch.

## Included Script

The audit script is read-only:

```bash
./scripts/macos_storage_audit.sh
```

It prints a Markdown-style storage report that Codex can use to prepare a cleanup plan.

## Safety Defaults

Pourdisk does not delete these by default:

- Desktop, Documents, Downloads, Photos, or iCloud Drive
- Source code repositories
- Obsidian vaults
- Mail or Outlook stores
- WeChat `msg` folders or local chat history
- Any app data that looks like user-created content

The core rule is simple: audit first, classify clearly, ask before deleting, verify after cleaning.
