---
name: react-state-safe-edit
description: Use when editing React/TypeScript state, useState, array state, Set/Map, selection UI, event handlers, or TSX UI behavior.
---

# react-state-safe-edit

## Purpose

React / TypeScript / TSX の state 更新や選択 UI を、安全に壊さず修正するためのスキルです。

## When to use

- React state / `useState` を変更するとき
- 配列 state、`Set`、`Map` を更新するとき
- 複数選択、単一選択、選択解除を扱うとき
- event handler や TSX UI 修正で state が絡むとき
- 削除、編集、選択状態の導線に影響する変更をするとき

## Rules

- state を直接破壊的に変更しない。
- 配列、`Set`、`Map` は新しいインスタンスを作って更新する。
- setter の callback 形式を使い、古い closure に依存しない。
- 複数選択と単一選択の仕様を先に確認する。
- 既存の選択、削除、編集導線を壊さない。
- 削除後やフィルタ変更後に、選択済み id が残り続けないか確認する。
- TypeScript / TSX コードを bash に直接貼らない。
- ターミナルから修正する場合は、対象ファイルを明示し、安全な置換方法を使う。
- 大きな一括置換より、対象箇所を読んで小さく変更する。

## State update patterns

配列 state:

```tsx
setItems((prev) => prev.filter((item) => item.id !== removedId));
setItems((prev) => prev.map((item) => item.id === next.id ? next : item));
```

`Set` state:

```tsx
setSelectedIds((prev) => {
  const next = new Set(prev);
  next.add(id);
  return next;
});
```

選択解除:

```tsx
setSelectedIds((prev) => {
  const next = new Set(prev);
  next.delete(id);
  return next;
});
```

## Checks after editing

- 変更した event handler が既存 UI から呼ばれているか確認する。
- 単一選択 / 複数選択の期待動作を手元で読み直す。
- 削除、編集、キャンセル、フィルタ、ページ遷移後の選択状態を確認する。
- `npm run typecheck` を実行する。
- `npm run build` を実行する。

## Output format

- Summary
- Changed files
- State behavior checked
- Verification
- Remaining risks
