---
paths:
  - '**/*.rb'
---

# エラーハンドリング規約

## 例外処理の集約

- 各アクションに個別の `rescue` を書かない。`rescue_from` で `ApplicationController` に集約する
- 共通のエラーレスポンス生成は Concern（`ErrorRenderable` 等）に切り出す

## 業務例外とシステム例外の区別

- **業務例外**（バリデーション失敗、認可拒否、リソース未発見）→ 適切なステータスコードとメッセージを返す。ログレベルは info / warn
- **システム例外**（DB 接続エラー、外部 API タイムアウト）→ 500 を返し、アラート通知。ログレベルは error / fatal

## カスタム例外クラス

- アプリケーション固有のエラーは `ApplicationError < StandardError` を基底に定義する
- 例外クラスに HTTP ステータスコードを持たせると `rescue_from` での変換が簡潔になる

```ruby
class BusinessError < ApplicationError
  def initialize(msg = nil, status: :unprocessable_entity)
    @status = status
    super(msg)
  end
end
```

## API エラーレスポンス

- エラーレスポンスの JSON 構造をプロジェクト内で統一する
- 複数エラーの同時返却に対応する（バリデーションエラー等）
- ユーザーに内部情報（スタックトレース、SQL）を返さない

## Service Object のエラー戦略

- 「起きてはいけない異常事態」→ 例外を raise
- 「業務上ありえる失敗」→ Result オブジェクトで返す
- プロジェクト内でどちらのパターンを使うか統一する

## DO NOT

- `rescue => e` で全例外を雑にキャッチしない（例外の種類を指定する）
- `rescue` でエラーを握りつぶさない（最低限ログに記録する）
- トランザクション内で副作用を実行してから `rescue` で巻き戻そうとしない
- 業務例外に `500 Internal Server Error` を返さない（適切なステータスコードを使う）
