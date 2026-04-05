---
paths:
  - '**/*.tsx'
  - '**/*.ts'
---

# TypeScript 規約

## 型安全性

- `any` を使わない。型が不明な場合は `unknown` を使い、型ガードで絞り込む
- 強引な型アサーション（`as`）を避ける。やむを得ない場合はコメントで理由を残す
- route params や API レスポンスの型を正確に定義する
- Server Actions の入力は Zod 等でランタイムバリデーションする

## 型で責務境界を表現する

- コンポーネントの Props は `type` または `interface` で明示的に定義する
- Props を見ただけでコンポーネントの責務がわかる型設計にする
- API 状態型（`loading` / `error` / `success`）は Page / Section 層で扱う
- Feature 表示層はデータ型のみ受け取り、API 状態に依存しない
- Primitive が業務型（`role` / `plan` 等）を受け取っていたら責務逸脱を疑う

## 型の活用

- discriminated union で分岐を型安全にする
- Generics を活用して再利用可能な型を定義する
- Utility Types（`Pick` / `Omit` / `Partial` / `Required`）を適切に使う
- `ComponentProps<'button'>` 等で HTML 要素の型を継承する

## Strict モード

- `strict: true` を有効にする
- `strictNullChecks` による null / undefined チェックを省略しない
- 暗黙の `any` を許容しない（`noImplicitAny: true`）

## DO NOT

- `any` で型チェックを回避しない
- `as` で型を強引にキャストしない（型ガードを使う）
- `@ts-ignore` / `@ts-expect-error` を安易に使わない
- API レスポンスを `any` のまま使わない（型を定義してバリデーションする）
- エッジケース対応で型をアドホックに歪めない（型自体を見直す）
