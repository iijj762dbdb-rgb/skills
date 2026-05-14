# markdown-query CLI リファレンス

すべてローカル実行。`mdq <subcommand>` 形式（`python -m mdq <subcommand>` も可）。

## 共通オプション
- `--db PATH`: SQLite 索引ファイル。既定 `.mdq/index.sqlite`。

## index — 索引作成 / 更新

```
mdq index [--root PATH ...] [options]
```

| オプション | 既定 | 説明 |
|---|---|---|
| `--root` | カレントディレクトリ（再帰） | 索引対象ルート。繰り返し指定可。 |
| `--rebuild` | off | SHA-1 が同一でも強制再索引。 |
| `--exclude GLOB` | なし | 既定除外に追加する除外パターン。複数指定可。 |
| `--no-default-excludes` | off | 既定除外（下記）を無効化。 |
| `--respect-gitignore` / `--no-respect-gitignore` | on | `.gitignore` を尊重するかどうか。 |
| `--ext` | `.md`, `.markdown` | 索引対象拡張子。繰り返し指定で追加。 |
| `--follow-symlinks` | off | シンボリックリンクを辿る。 |
| `--no-prune` | off | ディスク上に存在しないファイルのチャンク削除を抑止。 |

**既定除外**: `.git`, `node_modules`, `.venv`, `venv`, `__pycache__`, `.mdq`, `dist`, `build`, `.next`, `.cache`

出力（JSON）: `{"files_indexed": N, "files_skipped": M, "chunks_written": K, "roots": [...]}`

## search — 検索

```
mdq search --q "..." [options]
```

| オプション | 既定 | 説明 |
|---|---|---|
| `--mode` | `bm25` | `bm25` または `grep`（正規表現エスケープした完全一致） |
| `--top-k` | `5` | 返却ヒット件数上限 |
| `--max-tokens` | `800` | 全 snippet 合計の概算トークン上限（超過時打ち切り） |
| `--paths` | なし | `fnmatch` 形式の path glob を複数指定可（例: `docs/**` `**/README.md`） |
| `--tags` | なし | frontmatter `tags` で AND 絞り込み |
| `--snippet-radius` | `2` | マッチ行の前後何行を snippet に含めるか |
| `--format` | `jsonl` | `jsonl` または `compact`（人間可読） |

JSONL 1行スキーマ:
```json
{"chunk_id":"<sha1>","path":"...","heading_path":"...","lines":[start,end],"score":0.0,"snippet":"..."}
```

## get — 単一チャンク取得

```
mdq get --chunk-id <ID>
```

`search` で返った `chunk_id` を渡すと、本文を含む完全なチャンクを返す。

## list — 見出し一覧

```
mdq list [--paths GLOB ...] [--heading-level N] [--limit 200]
```

ファイル / 見出し階層の俯瞰に使用。

## stats — 索引統計

```
mdq stats
```

`{"files": N, "chunks": M}` を返す。

## watch — リアルタイム索引（任意機能）

```
mdq watch [--root PATH ...] [--poll]
```

ファイルシステムイベントで `.md` / `.markdown` の追加・更新・削除を検知して索引を逐次更新する。`watchdog` の導入が必要（`pip install watchdog`）。`--poll` でイベント API を使わずポーリングフォールバックに切替可能。

## 終了コード
- `0`: 正常
- `1`: `get` で `chunk_id` が見つからない等の汎用エラー
- `2`: 索引未作成（`.mdq/index.sqlite` が存在しない状態で `search` / `get` / `list` / `stats` が呼ばれた）
