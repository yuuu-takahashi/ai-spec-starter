---
paths:
  - '**/*.tsx'
  - '**/*.ts'
---

# パフォーマンス規約

## 再レンダリング制御

- 不要な再レンダリングが発生していないか確認する
- `memo` / `useMemo` / `useCallback` は計測に基づき必要な箇所に限定する
- 重い処理をレンダーパス内に置かない

## データ取得の最適化

- Server Component でデータ取得を行い、Client 側の fetch を減らす
- 並列取得が可能な場合は `Promise.all` でウォーターフォールを避ける
- 過剰な再取得を避け、キャッシュ戦略を意識する
- Streaming（`loading.tsx` / Suspense）で初期表示を高速化する

## 画像・アセット

- `next/image` を使い画像を最適化する
- LCP（Largest Contentful Paint）に影響する画像は `priority` を設定する
- 大きいアセットを無自覚に配信しない
- `next/font` でフォントを最適化する

## バンドルサイズ

- 不要な依存を追加しない。ライブラリの tree-shaking を確認する
- 動的 import（`next/dynamic` / `React.lazy`）で初期バンドルを軽量化する
- Server Component を活用し、Client バンドルに含まれるコードを減らす

## DO NOT

- 計測なしで `useMemo` / `useCallback` を乱用しない（早すぎる最適化）
- レンダーパス内でオブジェクト・配列を毎回新規生成しない
- 巨大なライブラリを丸ごとインポートしない（named import を使う）
- 画像を `<img>` タグで直接配信しない（`next/image` を使う）
- データ取得をウォーターフォールにしない（並列化を検討する）
