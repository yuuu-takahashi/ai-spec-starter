---
paths:
  - '**/app/**/*.tsx'
  - '**/app/**/*.ts'
---

# Next.js セキュリティ規約

## Server / Client の境界

- 機密ロジック（認証・認可・DB アクセス）は Server Component / Server Actions に閉じる
- サーバー専用モジュールには `server-only` パッケージで Client への混入を防ぐ
- Server Component から Client Component に渡すデータは必要最小限にする

## 環境変数

- `NEXT_PUBLIC_` 付き環境変数には機密情報を入れない
- API キー・DB 接続文字列はサーバーサイドでのみ使用する
- ランタイム環境変数とビルド時環境変数の違いを意識する

## Server Actions のセキュリティ

- Server Actions 内で認証・認可チェックを必ず行う
- 入力値は信頼せず、Zod 等でバリデーションする
- Server Actions は公開エンドポイントとして扱う（誰でも呼べる前提）
- クロージャで機密データをキャプチャしない（暗号化されるが意図しない露出リスク）

## XSS 対策

- React の JSX エスケープを活用する（`dangerouslySetInnerHTML` は最終手段）
- ユーザー入力を URL やスクリプトにそのまま埋め込まない
- Content Security Policy（CSP）ヘッダーを設定する

## データアクセス層

- DB アクセスは Data Access Layer（DAL）に集約する
- DAL 内で認証チェックを行い、未認証アクセスを防ぐ
- API レスポンスに不要な内部情報を含めない

## DO NOT

- 機密情報を `NEXT_PUBLIC_` 付き環境変数に入れない
- Server Actions 内で認証チェックを省略しない
- `dangerouslySetInnerHTML` をバリデーションなしで使わない
- Client Component に DB 接続情報やシークレットを渡さない
- Server Actions のクロージャで機密データをキャプチャしない
