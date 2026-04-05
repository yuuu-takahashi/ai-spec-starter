---
paths:
  - '**/*.rb'
---

# ActiveRecord / クエリ設計規約

## N+1 問題の防止

- 関連データは `includes` / `preload` / `eager_load` で事前読み込みする
- `includes`: デフォルト選択。条件分岐を含む参照に対応
- `preload`: シンプルな関連の別クエリ読み込み
- `eager_load`: 関連テーブルの条件で絞り込みが必要な場合（LEFT OUTER JOIN）

## クエリ最適化

- 集計は Ruby ではなく DB で行う（`count`, `sum`, `average`, `group`）
- 必要なカラムのみ `select` / `pluck` で取得する。BLOB/TEXT は不要時に除外
- `where` 条件にはインデックス付きカラムを使う
- 大量レコードは `find_each(batch_size: 1000)` でバッチ処理する

## スコープ

- 再利用可能なクエリ条件はスコープ化する
- チェーン可能に設計する（`User.active.verified.recent`）
- 複雑な WHERE 条件は Query Object に抽出する

## default_scope

- `default_scope` は原則使わない。暗黙的なフィルターで予期しない挙動を招く
- やむを得ず使う場合は `unscoped` でスコープ解除できることをテストする

## DO NOT

- 文字列補間で SQL を組み立てない（`where("name = '#{name}'")`）
- `map` / `select` で AR リレーションを Ruby 配列に変換して絞り込まない（DB で絞る）
- 論理削除（`deleted_at`）を使う場合、全クエリで考慮漏れがないか確認する
- 不要な JOIN を残さない
