# mdq 0.1.0 リリース手順

`mdq` を Python パッケージ (version `0.1.0`) としてリリースするための公式手順。

## 0. 前提

- Python 3.11+ がローカルにインストール済み
- `main` ブランチが緑 (全テスト pass)
- PyPI / TestPyPI アカウント (公開する場合) と API トークン

## 1. バージョン番号を 0.1.0 に揃える

現在 [mdq/__init__.py](mdq/__init__.py#L9) は `__version__ = "0.5.0"` になっているため `0.1.0` に変更します。

```python
# mdq/__init__.py
__version__ = "0.1.0"
```

`tools/markdown-query/vendor/mdq/__init__.py` (ベンダコピー) も同じ値に揃える、または vendor ディレクトリを再同期する。

## 2. ルート `pyproject.toml` の追加

リポジトリルートに以下を新規作成 (PEP 621 準拠):

```toml
[build-system]
requires = ["setuptools>=68", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "mdq"
version = "0.1.0"
description = "Local-only Markdown cross-file query toolkit (BM25 + semantic, stdlib-first)"
readme = "README.md"
requires-python = ">=3.11"
license = { text = "MIT" }
authors = [{ name = "dahatake" }]
keywords = ["markdown", "search", "bm25", "semantic-search", "rag", "local"]
classifiers = [
  "Development Status :: 4 - Beta",
  "License :: OSI Approved :: MIT License",
  "Programming Language :: Python :: 3.11",
  "Programming Language :: Python :: 3.12",
  "Topic :: Text Processing :: Indexing",
  "Operating System :: OS Independent",
]
dependencies = [
  "rank_bm25>=0.2.2",
  "tiktoken>=0.7.0",
]

[project.optional-dependencies]
semantic = ["fastembed>=0.3", "numpy>=1.26"]
watch    = ["watchdog>=4.0"]
gui      = ["PySide6>=6.6"]
dev      = ["pytest>=8", "build>=1.2", "twine>=5.0"]

[project.scripts]
mdq = "mdq.__main__:main"

[project.urls]
Homepage   = "https://github.com/dahatake/skills"
Repository = "https://github.com/dahatake/skills"
Issues     = "https://github.com/dahatake/skills/issues"

[tool.setuptools.packages.find]
where = ["."]
include = ["mdq*"]
exclude = ["mdq.tests*", "tools*", "sample*", "skills*", "setup*"]
```

> `mdq/__main__.py` の `main()` がコンソールから呼べることを確認。なければ `if __name__ == "__main__":` ブロックを `def main(): ...` に切り出す。

## 3. パッケージ同梱ファイルの整理

- `LICENSE` がルートにあることを確認 (`setuptools` が自動同梱)
- `README.md` をパッケージ説明として使用 (`readme = "README.md"`)
- 不要ファイルを除外するため `MANIFEST.in` を作成 (任意):

```
include README.md LICENSE
recursive-exclude mdq/tests *
recursive-exclude tools *
recursive-exclude sample *
```

## 4. ローカル検証

```powershell
# クリーンな仮想環境
py -3.11 -m venv .venv
.\.venv\Scripts\Activate.ps1

# 開発インストール + テスト
pip install -e ".[dev,semantic,watch]"
pytest mdq/tests -q

# CLI 動作確認
mdq --help
mdq --version  # 0.1.0 が表示されること
```

`mdq --version` が無い場合は `mdq/cli.py` に追加:

```python
parser.add_argument("--version", action="version", version=f"mdq {__version__}")
```

## 5. ビルド

```powershell
pip install build
python -m build
```

`dist/` に以下が生成されることを確認:
- `mdq-0.1.0-py3-none-any.whl`
- `mdq-0.1.0.tar.gz`

中身確認:
```powershell
python -m zipfile -l dist/mdq-0.1.0-py3-none-any.whl
```
→ `mdq/` のソースのみ含み、`tools/` `sample/` `tests/` が混入していないこと。

## 6. 別環境でのインストール検証

```powershell
deactivate
py -3.11 -m venv .venv-test
.\.venv-test\Scripts\Activate.ps1
pip install dist\mdq-0.1.0-py3-none-any.whl
mdq --version
```

## 7. (任意) TestPyPI で予行演習

```powershell
pip install twine
python -m twine upload --repository testpypi dist/*

# 別環境で取得
pip install --index-url https://test.pypi.org/simple/ mdq==0.1.0
```

## 8. PyPI 公開

```powershell
python -m twine upload dist/*
```
認証は API トークン (`__token__` / `pypi-...`) を推奨。`~/.pypirc` か環境変数 `TWINE_USERNAME` / `TWINE_PASSWORD` で設定。

## 9. Git タグ付け & GitHub Release

```powershell
git add mdq/__init__.py pyproject.toml MANIFEST.in RELEASE.md
git commit -m "chore(release): mdq 0.1.0"
git tag -a v0.1.0 -m "mdq 0.1.0"
git push origin main --tags
```

GitHub UI から `v0.1.0` タグで Release を作成し、`dist/*.whl` と `*.tar.gz` を添付。リリースノートには以下を記載:
- 主な機能 (BM25 / semantic / PageIndex / watcher / GUI)
- 既知の制限事項
- 動作要件 (Python 3.11+)

## 10. リリース後

- `mdq/__init__.py` を次の開発バージョン (例 `0.2.0.dev0`) に更新
- `CHANGELOG.md` を新規作成し、0.1.0 のエントリを追記 (未作成の場合)

## チェックリスト

- [ ] `__version__` を `0.1.0` に変更
- [ ] ルート `pyproject.toml` 追加
- [ ] `MANIFEST.in` 追加 (任意)
- [ ] `mdq --version` 実装
- [ ] `pytest` 全 pass
- [ ] `python -m build` 成功
- [ ] wheel 中身検証 OK
- [ ] 別環境インストール検証 OK
- [ ] TestPyPI で確認 (任意)
- [ ] PyPI へアップロード
- [ ] `v0.1.0` タグ作成 & GitHub Release
- [ ] 次バージョンへバンプ
