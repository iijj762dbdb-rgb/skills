# handoff-summary

## Purpose

Document Inbox MVP の作業結果を、次のチャット・Codex・Gemini・人間の確認に渡しやすい形で要約するためのスキルです。

## When to use

- Codex / Gemini の作業完了後
- チャットを移動する前
- 実装・docs整理・運用確認の結果を正本メモ化したいとき
- 長いログや変更内容を短く引き継ぎたいとき

## Rules

- 事実ベースで書く
- 推測と確認済みを分ける
- 成功した確認コマンドを明記する
- 失敗や残リスクも隠さない
- 変更ファイルを必ず列挙する
- 安全方針に関わる変更は明示する
- 不要に長くしない
- 本文は日本語中心
- コマンド、ファイル名、API名、unit名、状態名は英語のまま

## Preferred output format

### Summary
何をしたかを短くまとめる。

### Changed files
- `path/to/file`

### What changed
実際の変更点を箇条書きでまとめる。

### Build/Test result
実行した確認コマンドと結果を書く。

例:
- `python3 -m pytest`: passed
- `npm run typecheck`: passed
- `npm run build`: passed
- `python3 -m compileall backend scripts`: passed
- `git diff --check`: passed

### Remaining risks
未確認事項、残課題、実機確認が必要な点を書く。

### Next candidates
次にやるとよい作業を最大3つまで書く。

## For operations incidents

運用障害の場合は以下も含める。

- 発生日時
- 影響範囲
- 症状
- 原因
- 対応
- 復旧確認
- 再発時の確認ポイント
- docsに残した場所

## Must mention if relevant

- 原本不変
- copy-first
- cleanup / delete は未実行
- dry-run のみ
- timer / service の状態
- Monitor 表示の状態
