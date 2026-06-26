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
- fork / remote / force push を含む Git 操作

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
- `git push --force` はユーザーが明示しない限り禁止

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

## Git / Fork safety

fork、remote、push、force push を扱う前に確認すること:

1. `git remote -v` で remote を確認する。
2. `origin` が自分の repo か、本家 repo かを確認する。
3. `upstream` がある場合は本家 repo として扱う。
4. push 前に `git fetch origin` を実行する。
5. `git log --oneline --left-right --graph --cherry-pick HEAD...origin/main` などでローカル / リモート差分を見る。
6. remote にだけあるコミットがある場合は force push しない。
7. 必要ならまず `git pull --rebase origin main` を検討する。
8. 実 push 前に `git push --dry-run` を実行する。
9. `git push --force` はユーザーが明示しない限り実行しない。

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
- `git push --force`
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
git remote -v
git fetch origin
git log --oneline --left-right --graph --cherry-pick HEAD...origin/main
git push --dry-run
```

優先する操作:

- copy
- copy2
- rclone copy
- dry-run
- read-only inventory
- candidate review
- checksum verification

## Output format

- Safety verdict: OK / caution / stop
- Why
- Checked risks
- Commands to run
- Commands to avoid
- Remaining risks
