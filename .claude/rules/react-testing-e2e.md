---
paths:
  - '**/e2e/**/*.ts'
  - '**/e2e/**/*.spec.ts'
  - '**/tests/**/*.spec.ts'
  - '**/playwright/**/*.ts'
---

# E2E テスト規約（Playwright）

## テスト対象

- ユーザーフロー全体（サインアップ、ログイン、購入、設定変更等）
- ページ遷移とナビゲーション
- フォーム送信からサーバー処理・画面反映までの一連の流れ
- async Server Component を含む画面（Vitest では未対応のため E2E で検証）

## テスト設計

- ユーザーが実際に行う操作手順をそのまま再現する
- 1 テスト = 1 ユーザーフロー。複数フローを 1 テストに詰め込まない
- 重要な業務フローと回帰リスクの高い箇所を優先する
- テストデータのセットアップとクリーンアップを確実に行う

## ロケーターの優先順位

- `page.getByRole` / `page.getByLabel` を最優先
- `page.getByText` / `page.getByPlaceholder` を次点
- `page.getByTestId` は他に手段がない場合のみ
- CSS セレクタ / XPath は最終手段

## 待機と安定性

- 明示的な待機を使う（`expect(locator).toBeVisible()` 等）
- `page.waitForURL` でナビゲーション完了を待つ
- 固定の `page.waitForTimeout` は使わない（flaky の原因）
- ネットワーク応答の待機は `page.waitForResponse` を使う

## 環境・設定

- `baseURL` を `playwright.config.ts` に設定し、テスト内では相対パスを使う
- `webServer` 設定でテスト実行時にサーバーを自動起動する
- CI ではヘッドレスモードで実行する
- テスト間の独立性を保つ（ブラウザコンテキストの分離）

## 認証フローの効率化

- ログイン状態の再利用は `storageState` で保存・復元する
- 全テストでログインフローを繰り返さない

## サンプルコード（何が確認できるか）

次の例は、**1 フロー＝1 テスト**・**getByRole / getByLabel**・**遷移完了は waitForURL**・**表示は expect(locator).toBeVisible()** で待つ、という観点の最小サンプルである。URL・ラベル文言はプロジェクトに合わせて置き換える。

```ts
import { test, expect } from "@playwright/test";

test("ログインしてダッシュボードが表示される", async ({ page }) => {
  await page.goto("/login");

  await page.getByLabel("メールアドレス").fill("user@example.com");
  await page.getByLabel("パスワード").fill("correct-horse-battery-staple");
  await page.getByRole("button", { name: /ログイン/i }).click();

  await page.waitForURL("**/dashboard");
  await expect(page.getByRole("heading", { name: /ダッシュボード/i })).toBeVisible();
});
```

API 完了を待つ場合は、`page.waitForResponse` で特定のリクエストを挟む（規約の「待機と安定性」参照）。

## DO NOT

- `page.waitForTimeout` で固定時間待機しない（`waitFor` 系を使う）
- テスト間で状態を共有しない（各テストは独立に実行可能にする）
- 本番環境に対して E2E テストを実行しない（ステージング環境を使う）
- UI の細かいスタイル（色、フォントサイズ等）を E2E で検証しない
- ユニットテストで済む検証を E2E で行わない（実行コストが高い）
