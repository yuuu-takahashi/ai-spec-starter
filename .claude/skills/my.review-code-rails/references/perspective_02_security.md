---
title: セキュリティ
impact: MEDIUM
tags: rails, review-code, security
---

<!-- markdownlint-disable MD036 -->

## セキュリティ

レビュー時のセキュリティ確認チェックリスト。
実装規約の詳細は `.claude/rules/rails-security.md` を参照。

> **注記**: より詳細なセキュリティレビューが必要な場合は別途実施してください。

### 入力検証

- [ ] **SQLインジェクション**: 文字列補間による SQL 構築がないか
- [ ] **XSS**: `html_safe` / `raw` がユーザー入力に使われていないか
- [ ] **CSRF**: `protect_from_forgery` が有効か、API は適切にトークン検証しているか
- [ ] **Strong Parameters**: `permit` でホワイトリスト方式が徹底されているか

### 認証・認可

- [ ] **認証**: 認証が必要なアクションで `before_action` が設定されているか
- [ ] **認可**: リソースの所有者チェックが行われているか
- [ ] **権限**: `skip_before_action` で認証を外している箇所に理由コメントがあるか
- [ ] **セッション**: Cookie フラグ（secure, httponly, SameSite）が適切か

### データ保護

- [ ] **機密情報**: パスワード・トークンが平文で保存されていないか
- [ ] **ログ**: `filter_parameters` で機密パラメータがマスクされているか
- [ ] **エラーメッセージ**: スタックトレースや内部情報がユーザーに見えないか

### Rails 固有の確認（perspective でのみ言及）

以下は `rails-security.md` でカバーされていない補足観点:

- [ ] **ファイルアップロード**: ActiveStorage 使用時、content_type・サイズのバリデーションがあるか
- [ ] **Open Redirect**: `redirect_to params[:url]` のようなユーザー入力ベースのリダイレクトがないか
- [ ] **依存関係**: `bundle audit` が CI で実行されているか
- [ ] **HTTP Security Headers**: CSP が設定されているか
- [ ] **DoS**: Rack::Timeout / Rack::Attack が本番で有効か
- [ ] **正規表現 DoS**: 複雑な正規表現にユーザー入力が渡されていないか
