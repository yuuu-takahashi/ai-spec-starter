---
paths:
  - '**/*.tsx'
  - '**/*.ts'
---

# Next.js 規約

## Server / Client コンポーネント

- Server Component をデフォルトにする。`use client` は必要な部分に限定する
- `use client` の範囲を最小限にし、インタラクティブな部分だけを Client Component に切り出す
- Server Component から Client Component へは props でデータを渡す（シリアライズ可能な値のみ）
- Suspense / Error Boundary の配置を適切にする
- サーバー専用コードには `server-only` パッケージで Client への混入を防ぐ

## ルーティング

- App Router の規約に沿う（`page.tsx` / `layout.tsx` / `loading.tsx` / `error.tsx`）
- 動的ルートや並列ルートを必要以上に複雑にしない
- Route Handler を UI 層と混在させない
- `<Link>` コンポーネントでプリフェッチを活用する

## データ取得

- Server Component 内で `fetch` や ORM で直接データを取得する
- Client でのデータ取得が必要な場合は SWR / React Query を使う
- mutation は Server Actions で処理し、`revalidatePath` / `revalidateTag` で再検証する
- loading / error state を漏れなく実装する（`loading.tsx` / Suspense）
- 並列データ取得が可能な場合は `Promise.all` でウォーターフォールを避ける

## キャッシュ・再検証

- `fetch` の `cache` / `next.revalidate` オプションを意図的に設定する
- `cacheTag` でタグ付けし、`revalidateTag` でピンポイント再検証する
- stale データや過剰再取得のリスクを確認する

## Server Actions

- フォーム送信は Server Actions で処理する
- 入力値は Server Actions 内で必ずバリデーションする（Zod 等）
- `useActionState` で pending / error 状態を管理する
- Server Actions 内で認証・認可チェックを行う

## 環境変数

- `NEXT_PUBLIC_` を付けるべき値と付けてはいけない値を分ける
- 機密値が Client に漏れないようにする
- ランタイム環境変数とビルド時環境変数の違いを意識する

## SEO / メタデータ

- 公開ページに `metadata` / `generateMetadata` を設定する
- 必要に応じて OG 画像・sitemap・robots.txt を用意する

## エラーハンドリング

- `error.tsx` で想定外エラーの UI と回復導線を提供する
- `not-found.tsx` で 404 を専用 UI で処理する
- Server Actions の業務エラーは例外ではなく戻り値で返す
- ネストした Error Boundary で影響範囲を局所化する

## DO NOT

- `use client` をページ全体に付けない（Server Component の利点を失う）
- Server で取得すべきデータを Client の `useEffect` で取得しない
- 機密情報を `NEXT_PUBLIC_` 付き環境変数に入れない
- Server Actions の入力をバリデーションなしで信頼しない
- キャッシュ設定を省略してデフォルト任せにしない
- レンダリング中に副作用（データ変更・リダイレクト等）を実行しない
