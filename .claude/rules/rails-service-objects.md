---
paths:
  - '**/*.rb'
---

# Service Object / 設計パターン規約

## ロジックの配置先

| ロジックの性質                   | 配置先                    |
| -------------------------------- | ------------------------- |
| 単一モデルのバリデーション       | Model (`validates`)       |
| 複数モデルのフォーム入力         | Form Object               |
| 複雑なクエリ                     | Query Object / Scope      |
| 認可ロジック                     | Policy Object (Pundit 等) |
| 表示ロジック                     | Decorator / View Object   |
| 複数モデルにまたがるビジネス処理 | Service Object            |
| 外部 API 連携                    | Service Object / Client   |

## Service Object の設計原則

- **1 Service = 1 操作**。`UserService` のような複数責務クラスを作らない
- **命名は「動詞 + 名詞」**（`RegisterUser`, `ProcessPayment`）。`〜Service` / `〜Manager` は避ける
- 公開メソッドは `call` のみ。`initialize` でパラメータを受け取る
- 結果の返し方（例外 / Result / dry-monads）はプロジェクト内で統一する
- トランザクションが必要な場合は Service 内で `ActiveRecord::Base.transaction` を使う

## Service Object を使わない場面

- 単純な CRUD → コントローラで直接実行
- 単一モデルのバリデーション → Model の `validates` に任せる
- モデルのバリデーションを Service で重複実装しない

## DO NOT

- コントローラにビジネスロジックを書かない（Fat Controller）
- モデルを肥大化させない（Service / Form / Query に分離する）
- Service 内で別の Service を深くネストしない（依存を浅く保つ）
- 「とりあえず Service に切り出す」をしない。配置先マトリクスを確認する
