---
paths:
  - '**/*.rb'
---

# ログ・監視規約

## ログレベル

- `DEBUG`: 開発時の詳細情報（クエリ、パラメータ）
- `INFO`: アプリケーションイベント（リクエスト開始/終了、ビジネスイベント）
- `WARN`: 異常兆候（非推奨機能の使用、リトライ発生）
- `ERROR`: 例外発生、処理失敗（スタックトレースとコンテキストを含める）

## 構造化ログ

- JSON 形式で出力し、検索・集約可能にする
- `trace_id`, `user_id`, `timestamp`, `level` を含める
- ビジネスイベント（ユーザー作成、支払い処理等）はログに記録する

## 機密情報のフィルタリング

- `filter_parameters` にパスワード、トークン、API キー、カード番号を追加する
- ログに `params` を丸ごと出力しない。必要なフィールドだけ明示的に出力する
- エラーメッセージにスタックトレースや内部情報をユーザーに返さない

## エラーハンドリング

```ruby
# ❌ エラーを握りつぶす
begin
  user.save!
rescue StandardError
end

# ✅ ログに記録して再 raise
begin
  user.save!
rescue StandardError => e
  Rails.logger.error("Failed to save user", exception: e.class.name, message: e.message)
  raise
end
```

## DO NOT

- `rescue` でエラーを握りつぶさない（最低限ログに記録する）
- ループ内で毎行ログ出力しない（開始と終了のみ）
- 機密情報（パスワード、トークン）をログに含めない
