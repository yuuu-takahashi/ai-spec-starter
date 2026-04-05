---
paths:
  - '**/app/**/*.tsx'
  - '**/app/**/*.ts'
---

# Next.js ルーティング・レイアウト規約

## ファイル規約

- `page.tsx`: ルートの UI。ルートを公開するために必須
- `layout.tsx`: 子ルート間で共有するレイアウト。ナビゲーションで再レンダリングされない
- `loading.tsx`: Suspense ベースのローディング UI
- `error.tsx`: Error Boundary ベースのエラー UI（`'use client'` 必須）
- `not-found.tsx`: 404 時の UI
- `route.ts`: API エンドポイント（`page.tsx` と同じセグメントに置かない）

## レイアウト

- 共通 UI（ヘッダー、サイドバー等）は `layout.tsx` に配置する
- レイアウトはネストされ、子レイアウトをラップする
- レイアウトは `searchParams` にアクセスできない（ナビゲーション時に再レンダリングされないため）

## 動的ルート

- `[slug]` で動的セグメントを定義する
- `generateStaticParams` で静的生成するパラメータを事前定義する
- `[...slug]` のキャッチオールルートは必要な場合のみ使う

## ナビゲーション

- `<Link>` コンポーネントでクライアントサイドナビゲーションする
- `<Link>` はビューポート内に入ると自動的にプリフェッチする
- プログラム的なナビゲーションは `useRouter` を使う（Client Component 内のみ）
- Server Component からのリダイレクトは `redirect()` を使う

## Route Groups

- `(groupName)` で URL に影響せずルートを整理する
- レイアウトの共有範囲を制御するために活用する

## DO NOT

- `page.tsx` と `route.ts` を同じセグメントに置かない
- レイアウトで `searchParams` に依存しない（再レンダリングされないため）
- 動的ルートや並列ルートを必要以上に複雑にしない
- Route Handler を UI 層と混在させない
- `<a>` タグで内部リンクしない（`<Link>` を使う）
