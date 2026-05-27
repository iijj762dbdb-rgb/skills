# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- `README.md` を大幅に拡充し、`skills-markdown-query.md` の汎用機能解説を取り込み統合。
  初めて利用するエンジニア向けに、上から順に「概要 → アーキテクチャ → インストール →
  使用方法 → Chunking Strategy と言語選択 → クエリルーティング → 索引データファイル
  → ベンチマーク → 利用統計レポート → 他リポジトリへの移植チェックリスト」の流れに
  再構成。Mermaid によるアーキテクチャ図、5 つの Chunking Strategy 比較表、
  `--strategy auto` の 7 ルーティングルール、SCHEMA v6 までの索引データ構造、
  `.mdq/usage.jsonl` ベースの利用統計指標一覧を追加。

### Removed

- `skills-markdown-query.md`（HVE リポジトリ固有のリファレンスとして書かれていたが、
  汎用部分を `README.md` に統合したため削除）。HVE 固有機能（`target_folders` /
  Orchestrator 連携 / GUI 一括ビルド / `session-state` ベースの完了率指標など）は
  本プラグインの対象外として除外。
