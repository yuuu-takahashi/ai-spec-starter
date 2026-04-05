---
paths:
  - '**/*.rb'
---

# Rails セキュリティ規約

## 入力検証

- SQL に文字列補間を使わない。プレースホルダー (`where('name = ?', name)`) またはハッシュ (`where(name: name)`) を使う
- `html_safe` / `raw` は必要最小限に。ユーザー入力には絶対に使わない（XSS）
- Strong Parameters でホワイトリスト形式のパラメータ許可を徹底する

## 認証・認可

- 認証が必要なアクションには `before_action :authenticate_user!` 等を設定する
- リソースへのアクセスは必ず認可チェックする（`current_user.id == resource.user_id` 等）
- `skip_before_action` で認証を外す場合は理由をコメントする

## データ保護

- 機密情報（パスワード、トークン、API キー）をログに出さない。`filter_parameters` に追加する
- エラーメッセージにスタックトレースや内部情報を含めない
- 機密データは `credentials` または環境変数で管理する。コードにハードコードしない

## CSRF / セッション

- API 以外のコントローラで `protect_from_forgery` を無効化しない
- セッションに大きなオブジェクトや機密情報を格納しない

## DO NOT

- `params.permit!` を使わない（Mass Assignment）
- `send(params[:method])` のようにユーザー入力でメソッドを動的呼び出ししない
- `eval` / `constantize` にユーザー入力を渡さない
