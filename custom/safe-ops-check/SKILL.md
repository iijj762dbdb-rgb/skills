---
name: safe-ops-check
description: Use before operations that may affect real files, backups, archives, systemd workers, deletes, moves, restores, or irreversible data.
---

# safe-ops-check

## Purpose

Document Inbox MVP の実ファイル・バックアップ・pCloud・sora archive・削除系・復元系の作業で、安全方針を確認するためのスキルです。

## When to use

- pCloud import / cleanup / formal archive 登録
- backup / restore
- physical delete / trash permanent delete
- sora archive へのコピー
- rsync / rclone を使う作業
- systemd timer / worker がファイルを処理する作業
- 原本やバックアップに影響する可能性がある作業

## Golden rules

- 原本不変
- copy-first
- 自動削除禁止
- `rsync --delete` 禁止
- `rclone sync` は原則禁止
- pCloud import は `rclone copy` のみ
- pcloud-import 元ファイルは削除しない
- cleanup execute は別フェーズ
- 物理削除は dry-run / 候補表示 / 明示確認が必須
- restore は本番 data_root へ直接上書きしない
- DB更新とファイル操作の順序に注意する
- 失敗時は削除ではなく停止・除外・再試行・手動復旧を優先する

## Pre-flight checklist

作業前に確認すること:

1. 作業対象パスは正しいか
2. source と destination は逆になっていないか
3. delete / purge / sync / move / overwrite が含まれていないか
4. dry-run がある場合は先に実行したか
5. 件数・容量・サンプルを確認したか
6. backup または別保全があるか
7. timer / service が意図せず並行実行されていないか
8. ADMIN_TOKEN や秘密情報をログに出していないか
9. 失敗しても再実行可能か
10. rollback または手動復旧の道があるか

## Dangerous words

以下が出てきたら必ず立ち止まる:

- `rm`
- `delete`
- `purge`
- `cleanup execute`
- `rsync --delete`
- `rclone sync`
- `mv`
- `overwrite`
- `DROP TABLE`
- `DELETE FROM`
- production `data_root`
- `/mnt/archive`
- `/mnt/inbox`
- `pcloud-import`

## Safe command preference

優先する確認:

```bash
systemctl --user status <unit> --no-pager -l
journalctl --user -u <unit> -n 120 --no-pager -l
find <path> -maxdepth 2 -type f | head
df -h
ls -la
git diff --check

優先する操作:

copy
copy2
rclone copy
dry-run
read-only inventory
candidate review
checksum verification
Output format
Safety verdict: OK / caution / stop
Why
Checked risks
Commands to run
Commands to avoid
Remaining risks
