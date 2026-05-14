# `markdown-query` Skill ベンチマーク

`markdown-query` Skill は Context Window 最小化のためだけに存在します。
別の retrieval 手段（例: ネイティブ検索、埋め込みベース RAG）が提供された
時点で、このディレクトリ配下の CLI を使って **撤去判断のための数値** を
取得できます。

## 対象スクリプト

[`benchmark.py`](./benchmark.py) — 同一プロセス内で次の 3 シナリオを同一クエリ
集合に対して計測します。

| シナリオ | 内容 | 入力に想定する Context |
|---|---|---|
| `baseline_full` | mdq 不使用、全文投入を想定 | 索引対象 root 配下の `*.md` 全文 |
| `mdq_bm25` | mdq BM25 検索結果のみを投入 | `search(mode="bm25")` の Hit JSON |
| `mdq_grep` | mdq grep 検索結果のみを投入 | `search(mode="grep")` の Hit JSON |

## 前提条件

- Python 3.11+。
- `mdq` CLI 導入済（[`setup/setup-markdown-query.ps1`](../../setup/setup-markdown-query.ps1) / [`setup/setup-markdown-query.sh`](../../setup/setup-markdown-query.sh) を実行）。
- 索引が存在する（`mdq index` 実行済、または `python -m mdq index`）。あるいは `--ensure-index` を指定。

## 実行例

```bash
# サンプル 5 クエリを既定設定でベンチ
python tools/markdown-query/benchmark.py \
  --queries-file tools/markdown-query/queries.sample.txt \
  --top-k 5 --max-tokens 800 --repeat 3 --ensure-index

# パスを絞って比較
python tools/markdown-query/benchmark.py \
  --queries-file tools/markdown-query/queries.sample.txt \
  --paths "docs/**" "**/README.md" --repeat 5

# BM25 のみ計測（grep を除外）
python tools/markdown-query/benchmark.py \
  --queries-file tools/markdown-query/queries.sample.txt \
  --scenarios mdq_bm25 --top-k 3

# coverage_proxy を出すための期待パス付き JSON（queries.json は同梱しないため自作）
python tools/markdown-query/benchmark.py \
  --queries-json tools/markdown-query/queries.json --repeat 3
```

### `--queries-json` の書式

```json
[
  {"q": "業務要件 概要", "expected_paths": ["docs/business-requirement.md"]},
  {"q": "ARD",          "expected_paths": ["users-guide/01-business-requirement.md"]}
]
```

`expected_paths` 未指定の要素は coverage 計測対象外（`coverage_proxy: null`）。

## 出力

実行ごとに `tools/markdown-query/results/bench-<UTCタイムスタンプ>.{json,md}` が
生成されます。`results/` は `.gitignore` 済（コミット禁止）。

### JSON レポート構造

| キー | 内容 |
|---|---|
| `env.tokenizer` | `tiktoken/cl100k_base` または `fallback(chars/4)` |
| `env.python` / `env.platform` / `env.commit` | 再現性メタデータ |
| `params.*` | コマンドライン引数 |
| `index` | `--ensure-index` 指定時の索引作成 summary（`index_ms` 含む） |
| `baseline_full` | files / chars / tokens |
| `scenarios.<name>.avg_response_tokens` | クエリ平均応答トークン |
| `scenarios.<name>.avg_vs_baseline_savings_pct` | ベースライン比削減率 (%) |
| `scenarios.<name>.latency_ms_all` | 全クエリ × `--repeat` 回の mean/p50/p95/min/max |
| `scenarios.<name>.per_query[]` | クエリごとの hits / tokens / 削減率 / latency / coverage |

### Markdown サマリ

人手レビュー用。`--no-markdown-report` で抑止可。

## 既知の限界（捏造防止のための明示）

- **LLM API は呼ばない**。end-to-end の RAG 品質評価ではなく、Context Window 投入量と検索 wall-clock の代理指標に留まる。
- **絶対値はマシン依存**。`latency_ms` は同一マシン・同一コミット内での A/B 比較にのみ用いる。
- **coverage_proxy は最低限の代理指標**。期待パスが Hit に含まれる割合のみで、recall/precision を保証しない。
- **トークナイザは tiktoken cl100k_base 固定**。他トークナイザでの絶対値比較は不可。fallback 時は `env.tokenizer` を必ず確認すること。
- **撤去判断の閾値は本ツールでは提示しない**。数値を見て利用者が判断する。
