---
title: Rails 実装パターン別レビューガイド
tags: rails, patterns, review
---

<!-- markdownlint-disable MD024 MD025 -->

## Rails 実装パターン別レビューガイド

Rails 開発でよく遭遇するパターン別に、**どの観点を優先的にレビューするか**を示します。

## Pattern 1: Model ロジックのレビュー

### よくある課題

- コールバック（`before_save`, `after_create` など）の副作用が大きい
- バリデーション忘れ
- スコープが他のスコープとチェーン不可
- 重複ロジック

### 優先度

1. **設計** → モデルの責務は単一か？
2. **テスト** → テストケースは十分か？
3. **複雑性** → メソッドが長くないか？

### チェック観点と参照ファイル

| 観点       | チェック項目                                                   | 参照ファイル                                     |
| ---------- | -------------------------------------------------------------- | ------------------------------------------------ |
| **設計**   | 単一責任か？DDD パターンで責務分離されているか？               | `perspective_01_design.md` + `pattern_06_ddd.md` |
| **テスト** | コールバック処理のテストはあるか？                             | `perspective_04_testing.md`                      |
| **命名**   | メソッド名は形容詞か？スコープは明確か？                       | `perspective_05_naming.md`                       |

### チェックリスト例

```ruby
# ❌ 悪い例
class User < ApplicationRecord
  after_create :send_welcome_email
  after_create :initialize_profile

  def send_welcome_email
    UserMailer.welcome_email(self).deliver_now  # トランザクション内での外部API呼び出し
  end
end

# ✅ 良い例
class User < ApplicationRecord
  after_commit :send_welcome_email, on: :create

  def send_welcome_email
    UserMailer.welcome_email(self).deliver_later  # 非同期に
  end
end
```

---

## Pattern 2: トランザクション管理のレビュー

### よくある課題

- トランザクション境界が不明確
- ロック戦略がない（悲観的 vs 楽観的）
- コールバック内で外部 API 呼び出し
- 関連操作が同じトランザクション内でない

### 優先度

1. **設計** → データ整合性が保証されているか？
2. **セキュリティ** → 競合状態がないか？
3. **テスト** → 並行実行でテストしているか？

### チェック観点と参照ファイル

| 観点               | チェック項目                                                            | 参照ファイル                 |
| ------------------ | ----------------------------------------------------------------------- | ---------------------------- |
| **設計**           | transaction ブロックで囲まれているか？ロック戦略は適切か？              | `perspective_01_design.md`   |
| **セキュリティ**   | エッジケース（同時アクセス）でもデータ整合性が保たれるか？              | `perspective_02_security.md` |

### チェックリスト例

```ruby
# ❌ 悪い例
class OrderService
  def create_order(user_id, items, payment_info)
    ActiveRecord::Base.transaction do
      order = Order.create!(user_id: user_id, status: 'pending')
      items.each { |item| OrderItem.create!(order_id: order.id, **item) }
      payment = PaymentService.charge(payment_info, order.total_amount)  # 🔴 トランザクション内で外部API
      order.update!(status: 'confirmed', payment_id: payment.id)
    end
  end
end

# ✅ 良い例
class OrderService
  def create_order(user_id, items, payment_info)
    order = nil
    ActiveRecord::Base.transaction(isolation: :serializable) do
      order = Order.create!(user_id: user_id, status: 'pending')
      items.each { |item| OrderItem.create!(order_id: order.id, **item) }
    end

    # トランザクション外で外部 API 呼び出し
    payment = PaymentService.charge(payment_info, order.total_amount)
    order.update!(status: 'confirmed', payment_id: payment.id)
  rescue StandardError
    order&.destroy
    raise
  end
end
```

---

## Pattern 3: API エンドポイントのレビュー

### よくある課題

- 入力検証不足（Strong Parameters のみ）
- 認可チェック忘れ
- エラーハンドリング不備
- レスポンスフォーマットが不一貫

### 優先度

1. **セキュリティ** → 認証・認可・入力検証
2. **設計** → エッジケース対応・API 仕様の一貫性

### チェック観点と参照ファイル

| 観点             | チェック項目                            | 参照ファイル                                              |
| ---------------- | --------------------------------------- | --------------------------------------------------------- |
| **セキュリティ** | 認可（Pundit/CanCanCan）がいるか？      | `perspective_02_security.md`                              |
| **設計**         | バリデーション + Strong Parameters か？ | `perspective_02_security.md` + `perspective_01_design.md` |

### チェックリスト例

```ruby
# ❌ 悪い例
class Api::V1::OrdersController < ApplicationController
  def create
    order = Order.create!(order_params)  # 🔴 認可チェックない、エラーハンドリングない
    render json: { order: order }, status: :created
  end

  private

  def order_params
    params.require(:order).permit(:user_id, :total_amount, :items)  # user_id が外部からセット可能
  end
end

# ✅ 良い例
class Api::V1::OrdersController < ApplicationController
  before_action :authenticate_user!

  def create
    authorize(:order, :create?)  # 認可チェック

    order = current_user.orders.build(order_params)

    if order.save
      render json: { order: OrderSerializer.new(order).to_json }, status: :created
    else
      render json: { errors: order.errors.full_messages }, status: :unprocessable_entity
    end
  rescue Pundit::NotAuthorizedError
    render json: { error: 'Not authorized' }, status: :forbidden
  end

  private

  def order_params
    params.require(:order).permit(:total_amount, items: [:product_id, :quantity])
  end
end
```

---

## Pattern 4: クエリ最適化のレビュー

### よくある課題

- N+1 問題
- 不要なカラム取得
- デフォルトスコープの副作用
- DB 側でできる集計を Ruby で実施

### 優先度

1. **パフォーマンス** → N+1 問題・クエリ効率
2. **複雑性** → Ruby での集計は避ける
3. **テスト** → assert_queries でテスト

### チェック観点と参照ファイル

| 観点               | チェック項目                                           | 参照ファイル                    |
| ------------------ | ------------------------------------------------------ | ------------------------------- |
| **パフォーマンス** | includes/preload/eager_load で事前読み込みしているか？ | `perspective_03_performance.md` |
| **パフォーマンス** | DB 側で集計か？Ruby で配列集計していないか？           | `pattern_08_perf_analysis.md`   |
| **テスト**         | assert_queries で実行クエリ数をテストしているか？      | `perspective_04_testing.md`     |

---

## Pattern 5: マイグレーションのレビュー

### よくある課題

- reversible ではない（ロールバック不可）
- 大量データで lock が長い
- インデックスなし
- ダウンタイムが長い

### 優先度

1. **設計** → データロスないか？reversible か？
2. **パフォーマンス** → ダウンタイム最小化
3. **セキュリティ** → セキュアな削除か？

### チェック観点と参照ファイル

| 観点               | チェック項目                                | 参照ファイル                    |
| ------------------ | ------------------------------------------- | ------------------------------- |
| **設計**           | change / up-down ブロックで reversible か？ | `perspective_01_design.md`      |
| **パフォーマンス** | add_column で lock time 長くないか？        | `perspective_03_performance.md` |

---

## パターン別ワークフロー比較表

| パターン                 | 重点観点                               | 参照ファイル                                                    | 推奨テスト               |
| ------------------------ | -------------------------------------- | --------------------------------------------------------------- | ------------------------ |
| **Model ロジック**       | 設計 > テスト > 複雑性                 | `perspective_01_design.md`                                      | unit test                |
| **トランザクション管理** | 設計 > セキュリティ > テスト           | `perspective_01_design.md`, `perspective_02_security.md`        | integration test         |
| **API エンドポイント**   | セキュリティ > 設計                    | `perspective_02_security.md`, `perspective_01_design.md`        | integration/feature test |
| **クエリ最適化**         | パフォーマンス > 複雑性                | `perspective_03_performance.md`, `pattern_08_perf_analysis.md`  | assert_queries           |
| **マイグレーション**     | 設計 > パフォーマンス > セキュリティ   | `perspective_01_design.md`, `perspective_03_performance.md`     | migration test           |

---

## その他の実装パターン

### パターン6: フォームオブジェクト / Service Object のレビュー

**よくある課題**: Model への処理押し込み、責務混在

**参照**: `perspective_01_design.md`, `perspective_06_complexity.md`

### パターン7: バックグラウンドジョブ（Sidekiq など）のレビュー

**よくある課題**: 長時間実行、retry 戦略不備、idempotency なし

**参照**: `perspective_01_design.md`, `perspective_04_testing.md`

### パターン8: 認証・認可実装のレビュー

**よくある課題**: 認可忘れ、セッション管理不備

**参照**: `perspective_02_security.md`, `perspective_01_design.md`
