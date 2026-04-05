<!-- markdownlint-disable MD024 -->

# Next.js/React コードレビュー サンプル出力

## 対象ファイル

- `app/dashboard/page.tsx`
- `components/UserList.tsx`

---

## 各観点のレビュー結果

### 設計 (Good Points / Moderate Concerns / Issues Found)

#### ✅ Good Points

- コンポーネントの責務が明確に分離されている（データ取得と表示が分離）
- Server Component と Client Component の境界が適切

#### ⚠️ Moderate Concerns

- `UserList` が `use client` である必要があるか検討の余地あり。インタラクティブな部分のみを Client Component に切り出すとバンドルサイズ削減に繋がる

#### 🔴 Issues Found

- なし

---

### パフォーマンス (Good Points / Moderate Concerns / Issues Found)

#### ✅ Good Points

- `next/image` が適切に使用されている

#### ⚠️ Moderate Concerns

- なし

#### 🔴 Issues Found

- **対象コード** (`app/dashboard/page.tsx` 15-20行目):

  ```tsx
  const users = await fetch('https://api.example.com/users').then((r) => r.json());
  ```

- [must] キャッシュ戦略が未設定

  理由: fetch に `cache` や `next: { revalidate }` が指定されておらず、毎リクエストで API が呼ばれる。静的・準静的なデータならキャッシュすることでパフォーマンスと API 負荷を改善できる。
  修正案: `fetch('https://api.example.com/users', { next: { revalidate: 60 } })` のように revalidate を設定するか、`cache: 'force-cache'` で静的取得する。
  参考: データフェッチング、キャッシュ戦略

---

### セキュリティ (Good Points / Moderate Concerns / Issues Found)

#### ✅ Good Points

- ユーザー入力のサニタイズが行われている

#### ⚠️ Moderate Concerns

- なし

#### 🔴 Issues Found

- なし

---

## 優先度付きレコメンデーション

| 優先度 | 観点           | 内容                                      |
| ------ | -------------- | ----------------------------------------- |
| must   | パフォーマンス | fetch にキャッシュ戦略を設定する          |
| want   | 設計           | UserList の `use client` 範囲を最小化する |

---

## 対象コード抜粋（パフォーマンス指摘箇所）

```tsx
// app/dashboard/page.tsx
export default async function DashboardPage() {
  const users = await fetch('https://api.example.com/users').then((r) => r.json());

  return (
    <div>
      <UserList users={users} />
    </div>
  );
}
```
