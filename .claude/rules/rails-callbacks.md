---
paths:
  - '**/*.rb'
---

# コールバック / 副作用管理規約

## 基本方針

- コールバックは必要最小限にする。ビジネスロジックはコールバックに埋め込まない
- `save` の副作用として予期しない処理が実行される設計を避ける
- 複雑な処理は Service Object に移す

## 使い分け

- `before_validation`: データの正規化（downcase、trim 等）
- `before_save` / `before_create`: 保存前のデータ準備のみ
- `after_commit`: 外部 I/O（メール送信、API 呼び出し、キャッシュ無効化、イベント発行）
- `after_save` ではなく `after_commit` を使う（トランザクション確定後に実行するため）

## 外部 I/O の非同期化

```ruby
# ❌ 同期実行：失敗時にロールバック対象
after_create :send_notification_email

# ✅ 非同期実行：トランザクション確定後にジョブ投入
after_commit :enqueue_notification, on: :create
```

## 条件付きコールバック

- `if:` / `unless:` で不要な実行を制御する
- 条件が複雑なら Proc やメソッド参照で可読性を保つ

## Concern の使い方

- 関連コールバックを Concern にまとめてよいが、1 モデルに大量の Concern を include しない
- Concern 名は責務を表す（`Publishable`, `Searchable`）

## DO NOT

- コールバックメソッドを public にしない（`private` で宣言する）
- コールバックで制御フローを変更しない（`return false` で save を中断 → `validate` を使う）
- トランザクション内で外部 API を呼ばない（デッドロック・不整合の原因）
- `save` が隠れた副作用を持つ設計にしない。副作用は明示的に呼び出す
