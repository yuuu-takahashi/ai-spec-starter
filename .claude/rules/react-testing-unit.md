---
paths:
  - '**/*.test.ts'
  - '**/*.spec.ts'
---

# 関数テスト規約（Vitest）

## テスト対象

- 純粋関数・ユーティリティ関数・バリデーション・変換ロジック
- カスタム Hook（`renderHook` を使用）
- 状態遷移ロジック（reducer 等）

## テスト設計

- 入力と出力の対応を明確にテストする
- 正常系・異常系・境界値を網羅する
- 1 テスト = 1 アサーション を基本とし、検証意図を明確にする

## テストの書き方

- Arrange / Act / Assert を明確に分離する
- テストケース名だけで仕様が読み取れるようにする
- 曖昧な名前（`works`、`success`、`correctly`）は禁止。具体的な振る舞いを書く
- パラメタライズドテスト（`it.each`）で同種の入出力パターンをまとめる

## モック

- 外部依存（API クライアント、日時等）のみモックする
- 純粋関数はモックなしでテストする
- `vi.useFakeTimers` で日時依存を固定する

## カスタム Hook のテスト

- `@testing-library/react` の `renderHook` を使う
- Hook の返り値と状態変化を検証する
- 副作用を持つ Hook は `act` でラップする

## サンプルコード（何が確認できるか）

### 純粋関数（入力と出力・境界値）

`it.each` で表形式の仕様をまとめ、`describe` / `it` の文言で意図を読ませる例。

```ts
import { describe, expect, it } from "vitest";

function clamp(value: number, min: number, max: number): number {
  return Math.min(max, Math.max(min, value));
}

describe("clamp", () => {
  it("上限を超えたら max を返す", () => {
    expect(clamp(150, 0, 100)).toBe(100);
  });

  it.each([
    [5, 0, 10, 5],
    [-5, 0, 10, 0],
    [10, 0, 10, 10],
  ] as const)("clamp(%d, %d, %d) は %d を返す", (value, min, max, expected) => {
    expect(clamp(value, min, max)).toBe(expected);
  });
});
```

### カスタム Hook（renderHook + act）

返り値の変化を検証する例。実際のプロジェクトでは `./useCounter` など既存の hook に差し替える。

```ts
import { renderHook, act } from "@testing-library/react";
import { describe, expect, it } from "vitest";
import { useCounter } from "./useCounter";

describe("useCounter", () => {
  it("increment すると count が増える", () => {
    const { result } = renderHook(() => useCounter(0));

    act(() => {
      result.current.increment();
    });

    expect(result.current.count).toBe(1);
  });
});
```

## DO NOT

- 実装の内部構造（private 関数の呼び出し順等）をテストしない
- テスト間で状態を共有しない（各テストは独立に実行可能にする）
- テストデータをマジックナンバーで書かない（意図がわかる変数名を使う）
- モックのリセット忘れで他テストに影響を与えない
