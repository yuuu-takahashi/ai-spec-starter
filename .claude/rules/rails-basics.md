---
paths:
  - '**/*.rb'
---

# Rails 基本規約

## 命名規則

- 変数・メソッド・シンボル・ファイル名は `snake_case`、クラス・モジュールは `CamelCase`、定数は `SCREAMING_SNAKE_CASE`
- boolean を返すメソッドには `?` を付ける。`is_`/`has_`/`can_` は使わない（例: `admin?`, `active?`）
- 破壊的メソッドには `!` を付け、非破壊版も用意する
- getter は名詞（`name`）、action は動詞（`activate`）で始める
- モデル名は名詞の単数形。動詞は避ける（`Pay` → `Payment`）

## モデルの定義順序

1. 定数
2. アソシエーション（`belongs_to` → `has_one` → `has_many`）
3. バリデーション
4. スコープ
5. コールバック
6. クラスメソッド（public）
7. インスタンスメソッド（public）
8. `private` メソッド

## コントローラ

- RESTful 7アクション（index/show/new/create/edit/update/destroy）を優先する
- カスタムアクションは標準アクションの後に置く
- `private` で `strong parameters` を分離する

## スコープ

- 形容詞・状態語で命名する（`active`, `published`, `recent`）
- 並び順は `by_` 接頭辞（`by_created_at`）
- チェーン可能な設計にする（`User.active.verified.recent`）

## DO NOT

- コールバックメソッドを public にしない
- ルーティングのネストを 2 階層超にしない
- `get_xxx` / `set_xxx` メソッドを定義しない（Ruby のアクセサを使う）
