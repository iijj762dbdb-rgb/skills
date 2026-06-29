---
name: project-status-update
description: 発動条件：実装完了後・進捗更新・docs更新・dashboard更新が必要なとき。作業後に各プロジェクトのdocsと中央のダッシュボードを同期するためのスキルです。
---

# project-status-update

## Purpose
複数プロジェクト間で「実装だけ進んで記録が追いつかない」ことを防ぐため、実装完了時に必ず対象repo内docsと、中央の `ai-dev-memory` ダッシュボードをセットで更新する運用を強制します。

## Prerequisites
* 実装作業（コード変更・機能追加・バグ修正など）が完了していること。

## Execution Steps

1. **対象repo内のdocsを確認・更新する**:
    * 実装内容を、対象repoの `README.md`, `docs/status.md`, `handoff`, `remaining-tasks` 等へ適切に反映してください。
    * 適切なファイルが存在しない場合は、既存の構成に合わせて最小限の記録先を選んでください。

2. **中央のダッシュボードを更新する**:
    * `/home/okota/code/ai-dev-memory/docs/project-status-dashboard.md` を更新し、今回の実装内容や「次回やること」を反映してください。
    * 同様に HTML版 `/home/okota/code/ai-dev-memory/docs/project-status-dashboard.html` が存在する場合は、同期して更新してください。
    * 中央dashboard更新のために他repoを変更する場合でも、対象を明示し、必要最小限の変更にとどめてください。
    * 変更できない場合（他作業のコンフリクト等）は、「Dashboard update pending」として理由を明記してください。

3. **最後の報告**:
    * 報告の文末等に、以下のアサーションを必ず含めてください:
        - `Docs updated` (repo内のドキュメント更新完了)
        - `Dashboard updated` (中央ダッシュボード更新完了)

## Safety Constraints
* 実データ、データベース (DB / schema)、バックアップ、archive、systemd など、危険領域には勝手に触らないでください。
