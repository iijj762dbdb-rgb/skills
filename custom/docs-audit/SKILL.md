---
name: docs-audit
description: Use when auditing project docs for stale content, contradictions, duplication, or unclear source-of-truth boundaries before editing or indexing.
---

# docs-audit

## Purpose

Document Inbox MVP の docs を監査し、古い記述、矛盾、表記ゆれ、重複、正本の混在を見つけるためのスキルです。

## When to use

- docs を整理する前
- mdq index 前にノイズを減らしたいとき
- AI が古い Phase メモを最新仕様として誤読しそうなとき
- mvp-status.md / remaining-tasks.md / architecture.md / data-model.md / processing-pipeline.md / operations-*.md の整合性を確認したいとき

## Rules

- まず `mdq search --paths "docs/**"` を使い、docs全文を最初から読まない
- 正本 docs を優先する
  - 現在状態: `docs/mvp-status.md`
  - 未実装: `docs/remaining-tasks.md`
  - 構成: `docs/architecture.md`
  - データ構造: `docs/data-model.md`
  - 処理の流れ: `docs/processing-pipeline.md`
  - 運用手順: `docs/operations-*.md`
- 古い Phase 名は現在仕様として扱わない
- 迷う内容は削除せず「要確認」に分類する
- 実装ファイルは変更しない

## Audit checklist

確認する観点:

1. 現在の実装・方針と矛盾していそうな記述
2. 古い Phase / 実装履歴が現在仕様のように残っていないか
3. 日本語・英語の表記ゆれ
4. 同じ内容が複数docsに重複していないか
5. docsごとの役割が曖昧になっていないか
6. mdq検索時にノイズになる見出しや古い記述
7. 残すべき安全方針が消えていないか

## Must preserve

- 原本不変
- copy-first
- 自動削除禁止
- 物理削除は dry-run / confirm 必須
- `rsync --delete` 禁止
- pCloud / sora / backup の確認なしに削除しない
- pCloud import は `pcloud-import` 元ファイルを残す
- cleanup execute は別フェーズ

## Output format

- Summary
- 対象docs
- 問題点
- 矛盾・古い可能性がある記述
- 表記ゆれ
- 正本に残すべき情報
- 整理方針案
- 次に編集する優先順
