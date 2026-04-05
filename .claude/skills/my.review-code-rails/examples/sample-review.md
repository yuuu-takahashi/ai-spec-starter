<!-- markdownlint-disable MD024 -->

# Rails コードレビュー サンプル出力

## 対象ファイル

- `app/models/order.rb`
- `app/services/checkout_service.rb`

---

## 各観点のレビュー結果

### 設計

#### ✅ Good Points

- Service Object でチェックアウトロジックを Model から分離している
- トランザクション境界が明確

#### ⚠️ Moderate Concerns

- `CheckoutService` が支払い処理と在庫更新の両方を担っており、責務が 2 つに見える。将来的に分離を検討

#### 🔴 Issues Found

- なし

---

### セキュリティ

#### ✅ Good Points

- Strong Parameters で許可する属性を明示している

#### ⚠️ Moderate Concerns

- なし

#### 🔴 Issues Found

- なし

---

### パフォーマンス

#### ✅ Good Points

- `includes` で関連レコードを事前読み込みしている

#### ⚠️ Moderate Concerns

- なし

#### 🔴 Issues Found

- **対象コード** (`app/services/checkout_service.rb` 25-30行目):

  ```ruby
  order.line_items.each do |item|
    item.product.update!(stock: item.product.stock - item.quantity)
  end
  ```

- [must] N+1 クエリ + 個別 UPDATE

  理由: `line_items.each` 内で `product` を個別にロード・更新しており、件数分の SELECT + UPDATE が発行される。
  修正案: `includes(:product)` で事前読み込みし、`update_all` またはバルク更新に変更する。

---

## 優先度付きレコメンデーション

| 優先度 | 観点           | 内容                                                 |
| ------ | -------------- | ---------------------------------------------------- |
| must   | パフォーマンス | line_items の在庫更新を N+1 からバルク更新へ         |
| want   | 設計           | CheckoutService の支払い・在庫責務を将来的に分離     |
