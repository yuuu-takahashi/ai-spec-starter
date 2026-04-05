---
paths:
  - '**/app/**/*.tsx'
  - '**/app/**/*.ts'
---

# Next.js データ取得・キャッシュ規約

## データ取得の場所

- Server Component 内で `fetch` や ORM を直接呼び出す
- Client でのデータ取得が必要な場合は SWR / React Query を使う
- async Server Component で取得したデータを Props 経由で Client Component に渡す

## 並列取得

- 独立したデータ取得は `Promise.all` で並列化する（ウォーターフォール回避）
- `preload` パターンで取得開始タイミングを早める
- 親で取得して子に渡すか、子で並列取得するかをデータ依存関係で判断する

## キャッシュ戦略

- `fetch` の `cache` / `next.revalidate` オプションを明示的に設定する
- `cacheTag` でタグ付けし、`revalidateTag` でピンポイント再検証する
- `revalidatePath` でルート単位の再検証を行う
- 動的データには `no-store` を設定する

## Server Actions（mutation）

- フォーム送信やデータ変更は Server Actions で処理する
- Server Actions 内で入力値を必ずバリデーションする（Zod 等）
- mutation 後は `revalidatePath` / `revalidateTag` で関連キャッシュを無効化する
- `useActionState` で pending / error 状態を管理する

## Streaming

- `loading.tsx` でルート単位のローディング UI を提供する
- `<Suspense>` で部分的にストリーミングし、重いデータ取得をブロックしない
- 重要なコンテンツを先に表示し、補助的なコンテンツを遅延ロードする

## DO NOT

- Server で取得すべきデータを Client の `useEffect` で取得しない
- 独立したデータ取得を直列（ウォーターフォール）で実行しない
- キャッシュ設定を省略してデフォルト任せにしない
- Server Actions の入力をバリデーションなしで信頼しない
- `loading.tsx` も `<Suspense>` もなしでデータ取得しない（画面が固まる）
