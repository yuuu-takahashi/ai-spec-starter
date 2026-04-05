---
paths:
  - '**/*.test.tsx'
  - '**/*.spec.tsx'
---

# コンポーネントテスト規約（React Testing Library）

## テスト対象

- コンポーネントの描画結果とユーザーインタラクション
- Props に応じた表示の出し分け
- loading / error / empty の各状態
- フォーム入力・送信・バリデーションエラー表示

## テスト設計

- ユーザー視点の振る舞いを検証する。実装詳細に依存しない
- 重要な成功系・失敗系・境界条件をカバーする
- 4 層設計に合わせる: Primitive は見た目、Feature 表示は描画、Section は統合

## クエリの優先順位

- `getByRole` / `getByLabelText` を最優先（アクセシビリティ準拠）
- `getByText` / `getByPlaceholderText` を次点
- `getByTestId` は他に手段がない場合のみ
- `querySelector` は使わない

## ユーザー操作

- `@testing-library/user-event` の `userEvent` を使う（`fireEvent` より実際に近い）
- クリック、入力、キーボード操作をユーザーと同じ手順で再現する

## 非同期テスト

- 非同期の描画更新には `findBy` / `waitFor` で待機する
- `screen.findByText` 等で要素の出現を待つ
- タイマー依存は `vi.useFakeTimers` で固定する

## モック

- API 呼び出しはモックするが、コンポーネント内部のロジックはモックしない
- hooks のモックより、Props を直接渡してテストする方が安定する
- `vi.mock` のスコープとリセットを適切に管理する

## サンプルコード（何が確認できるか）

次の例は、**ロール／ラベルで要素を特定する**・**user-event で操作を再現する**・**props による表示差分**・**非同期表示は findBy で待つ**、という観点をまとめた最小サンプルである。ファイル名・コンポーネント名はプロジェクトに合わせて置き換える。

```tsx
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";
import { describe, expect, it, vi } from "vitest";
import { SearchForm } from "./SearchForm";
import { TipPanel } from "./TipPanel";

describe("SearchForm", () => {
  it("キーワードを入力して検索すると onSearch に渡る", async () => {
    const user = userEvent.setup();
    const onSearch = vi.fn();
    render(<SearchForm onSearch={onSearch} />);

    await user.type(screen.getByRole("textbox", { name: /キーワード/i }), "react");
    await user.click(screen.getByRole("button", { name: /検索/i }));

    expect(onSearch).toHaveBeenCalledWith("react");
  });

  it("送信中はボタンが disabled になる", () => {
    render(<SearchForm onSearch={vi.fn()} isSubmitting />);
    expect(screen.getByRole("button", { name: /検索/i })).toBeDisabled();
  });
});

describe("TipPanel", () => {
  it("操作後に遅れて出る領域は findBy で待ってから検証する", async () => {
    const user = userEvent.setup();
    render(<TipPanel />);
    await user.click(screen.getByRole("button", { name: /ヒントを表示/i }));

    expect(await screen.findByRole("region", { name: /入力のコツ/i })).toBeInTheDocument();
  });
});
```

## DO NOT

- DOM 構造（クラス名・タグ構造）に依存したテストを書かない
- スナップショットだけで本質的な振る舞いを確認しない
- 実装詳細に寄ったモックで安心しない（実装変更で壊れる）
- `act` 警告を無視しない（非同期処理の待機漏れを疑う）
- 不安定なテスト（flaky）を放置しない
