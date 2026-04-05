---
title: 複雑性
impact: MEDIUM
tags: rails, review-code, complexity
---

<!-- markdownlint-disable MD024 -->

## 複雑性

ルールの詳細は以下に記載します。

## チェックリスト

### コードレベルの複雑性

#### 一行レベルの複雑性

一行レベルの複雑性を確認すること：

- [ ] **単純な式**: 1行に複数の複雑な操作を詰め込んでいないことを確認すること
- [ ] **三項演算子**: 三項演算子は単純なケースのみで使用していることを確認すること
- [ ] **ネストした三項演算子**: ネストした三項演算子を避けていることを確認すること
- [ ] **複雑な正規表現**: 複雑な正規表現はコメント付きで説明されていることを確認すること

#### メソッドレベルの複雑性

##### メソッドの長さ

メソッドの長さを確認すること：

- [ ] **20行以内**: メソッドが20行以内に収まっていることを確認すること（一度に理解できる長さ）
- [ ] **即座の理解**: メソッド全体を読んですぐに理解できることを確認すること
- [ ] **単一責任（重要）**: メソッドが単一の責任のみを持っていることを確認すること。メソッド名から処理内容が明確に推測でき、1つの目的のみを達成していることを確認すること。複数の責任がある場合は、メソッド分割を提案すること
- [ ] **分割**: 長いメソッドは適切に分割されていることを確認すること
- [ ] **可読性**: メソッド名から処理内容が明確であることを確認すること

##### メソッドの引数

メソッドの引数を確認すること：

- [ ] **3個以内**: 引数が3個以内に収まっていることを確認すること
- [ ] **キーワード引数**: 多くの引数はキーワード引数を使用していることを確認すること
- [ ] **オプション引数**: オプション引数はハッシュまたはキーワード引数で渡していることを確認すること
- [ ] **デフォルト値**: 適切なデフォルト値が設定されていることを確認すること

##### ネストの深さ

ネストの深さを確認すること：

- [ ] **3階層以内**: ネストが3階層以内に収まっていることを確認すること（理解しやすい深さ）
- [ ] **認知的負荷**: ネストの深さが認知的負荷を高めていないことを確認すること
- [ ] **早期リターン**: 早期リターン（ガード節）を使用していることを確認すること
- [ ] **ネスト削減**: 不要なネストは削減されていることを確認すること

##### 循環的複雑度

循環的複雑度を確認すること：

- [ ] **McCabe複雑度**: McCabe循環的複雑度が10以下であることを確認すること（理解可能な複雑度）
- [ ] **テストの困難さ**: 複雑度が高いとテストケースが指数的に増加することを認識していることを確認すること
- [ ] **条件分岐**: 条件分岐が少ないことを確認すること
- [ ] **ループ**: ループが単純であることを確認すること
- [ ] **switch/case**: 長いswitch/caseはポリモーフィズムで置き換えられないか確認すること

#### クラスレベルの複雑性

##### クラスの大きさ

クラスの大きさを確認すること：

- [ ] **100行以内**: クラスが100行以内に収まっていることを確認すること（目安）
- [ ] **責任の分離**: クラスが単一の責任のみを持っていることを確認すること
- [ ] **Fat Modelの回避**: Fat Modelを避け、適切にレイヤーを分割していることを確認すること

##### クラスの責任

**特に重要**: クラスの単一責任は設計の根幹であり、コードレビュー時に最優先で確認すべき項目です。

クラスの責任を確認すること：

- [ ] **単一責任の原則（最重要）**: 1つのクラスが1つの責任のみを持っていることを確認すること。クラス名から責任が明確に推測でき、1つの目的のみを達成していることを確認すること。複数の責任がある場合は、クラス分割を提案すること
- [ ] **変更理由**: クラスを変更する理由が1つであることを確認すること。複数の変更理由がある場合は、単一責任の原則に違反している可能性が高いため、クラス分割を検討すること
- [ ] **凝集度**: クラスの凝集度が高いことを確認すること。クラス内のメソッドが互いに関連し、単一の責任を達成するために協力していることを確認すること
- [ ] **責任の明確性**: クラスの責任が明確に定義されていることを確認すること。責任が曖昧な場合は、クラス名の見直しや分割を検討すること

##### publicメソッドの数

publicメソッドの数を確認すること：

- [ ] **7個以内**: publicメソッドが7個以内に収まっていることを確認すること
- [ ] **インターフェース**: 公開インターフェースが明確であることを確認すること
- [ ] **private活用**: 内部メソッドは適切にprivateになっていることを確認すること

### 条件分岐とループの複雑性

#### 条件分岐の複雑性

##### if/else

if/elseの複雑性を確認すること：

- [ ] **単純な条件**: 条件式が単純で理解しやすいことを確認すること
- [ ] **多段if/else**: 多段のif/elseは避けられていることを確認すること
- [ ] **早期リターン**: 早期リターンで条件分岐を減らしていることを確認すること
- [ ] **ガード節**: ガード節を使って正常系を明確にしていることを確認すること

##### case/when

case/whenの複雑性を確認すること：

- [ ] **適切な使用**: case/whenが適切に使用されていることを確認すること
- [ ] **ポリモーフィズム**: 長いcase/whenはポリモーフィズムで置き換えられないか確認すること
- [ ] **状態パターン**: 状態による分岐はState Patternを検討していることを確認すること

##### 論理演算子

論理演算子の複雑性を確認すること：

- [ ] **単純な条件**: 複雑な論理演算子の組み合わせを避けていることを確認すること
- [ ] **変数抽出**: 複雑な条件は変数に抽出していることを確認すること
- [ ] **メソッド抽出**: 複雑な条件はメソッドに抽出していることを確認すること
- [ ] **De Morganの法則**: 否定条件は適切に変換されていることを確認すること

#### ループの複雑性

##### ループの種類

ループの種類を確認すること：

- [ ] **適切な選択**: `each`、`map`、`select`など適切なイテレータを使用していることを確認すること
- [ ] **ループの簡潔さ**: ループ内の処理が簡潔であることを確認すること
- [ ] **ネストループ**: ネストしたループを避けていることを確認すること
- [ ] **break/next**: `break`や`next`の使用が適切であることを確認すること

##### 配列操作

配列操作の複雑性を確認すること：

- [ ] **Enumerableの活用**: Enumerableメソッドを活用していることを確認すること
- [ ] **メソッドチェーン**: メソッドチェーンが長すぎないことを確認すること
- [ ] **一時変数**: 複雑な処理は一時変数を使って分割していることを確認すること

### Ruby特有の複雑性

#### ブロックの複雑性

ブロックの複雑性を確認すること：

- [ ] **単純なブロック**: ブロック内の処理が単純であることを確認すること
- [ ] **ブロック長**: ブロックが長すぎないことを確認すること（5行以内推奨）
- [ ] **ブロック引数**: ブロック引数が明確であることを確認すること
- [ ] **メソッド抽出**: 複雑なブロックはメソッドに抽出されていることを確認すること

#### メタプログラミング

メタプログラミングの使用を確認すること：

- [ ] **必要性**: メタプログラミングが本当に必要であることを確認すること
- [ ] **可読性**: メタプログラミングのコードが理解しやすいことを確認すること
- [ ] **ドキュメント**: 複雑なメタプログラミングはドキュメント化されていることを確認すること
- [ ] **代替案**: よりシンプルな代替案がないか確認すること

#### DSL

DSLの使用を確認すること：

- [ ] **明確性**: DSLの意図が明確であることを確認すること
- [ ] **学習コスト**: DSLの学習コストが妥当であることを確認すること
- [ ] **一貫性**: DSLが一貫していることを確認すること
- [ ] **必要性**: DSLが本当に必要であることを確認すること

### Rails特有の複雑性

#### Controllerの複雑性

Controllerの複雑性を確認すること：

- [ ] **Skinny Controller**: Controllerが薄いことを確認すること
- [ ] **ビジネスロジック**: ビジネスロジックがService層に分離されていることを確認すること
- [ ] **RESTful**: RESTfulな設計に従っていることを確認すること
- [ ] **アクション数**: 標準的な7アクション以外が少ないことを確認すること

#### Modelの複雑性

Modelの複雑性を確認すること：

- [ ] **Fat Modelの回避**: Modelにビジネスロジックを詰め込みすぎていないことを確認すること
- [ ] **Service層**: 複雑なビジネスロジックはService層に分離されていることを確認すること
- [ ] **Concern**: 横断的関心事はConcernで共通化されていることを確認すること
- [ ] **コールバック**: コールバックが複雑すぎないことを確認すること

#### Viewの複雑性

Viewの複雑性を確認すること：

- [ ] **ロジック排除**: Viewにビジネスロジックが含まれていないことを確認すること
- [ ] **Helper活用**: 複雑な表示ロジックはHelperに抽出されていることを確認すること
- [ ] **Presenter活用**: 複雑なプレゼンテーションロジックはPresenterに抽出されていることを確認すること
- [ ] **部分テンプレート**: 長いテンプレートは部分テンプレートに分割されていることを確認すること

### 認知的複雑度

#### コードの理解しやすさ

コードの理解しやすさを確認すること：

- [ ] **直感的**: コードが直感的に理解できることを確認すること
- [ ] **驚き最小の原則**: 驚き最小の原則に従っていることを確認すること
- [ ] **慣習**: Rubyの慣習に従っていることを確認すること
- [ ] **パターン**: 一般的なデザインパターンを使用していることを確認すること

#### コードの自己説明性

コードの自己説明性を確認すること：

- [ ] **自己説明的**: コードが自己説明的であることを確認すること
- [ ] **命名**: 変数名やメソッド名で意図が明確であることを確認すること
- [ ] **コメント**: 複雑な処理にはコメントがあることを確認すること（「なぜ」を説明）

##### コメントの原則

開発者はわかりやすい英語で明確なコメントを書きましたか？ すべてのコメントは実際に必要でしょうか？ コメントは普通、あるコードが「なぜ」存在するのかを説明するのに役立ちますが、コードが「何」をしているのかを説明すべきではありません。 コードがそれ自身を説明するほど明確でないのなら、コードをもっとシンプルにすべきです。

###### 「なぜ」を説明する

- [ ] **決定の背景**: 設計判断の理由が説明されていることを確認すること
- [ ] **ビジネス要件**: ビジネス要件が記載されていることを確認すること
- [ ] **技術的制約**: 技術的な制約や制限事項が説明されていることを確認すること
- [ ] **トレードオフ**: なぜその実装を選んだのか、トレードオフが説明されていることを確認すること

###### 「何」を説明しない

- [ ] **自明なコメント**: コードを読めばわかることをコメントで繰り返していないことを確認すること
- [ ] **実装の説明**: 「何」をしているかではなく「なぜ」をしているかを説明していることを確認すること
- [ ] **冗長なコメント**: メソッド名や変数名で十分説明できることをコメントしていないことを確認すること

##### 必要なコメント

複雑な処理にはコメントが必要です。以下の場合にコメントを確認すること：

###### ビジネスロジックの説明

- [ ] **複雑な計算**: 複雑な計算式や計算ロジックに説明があることを確認すること
- [ ] **特殊なルール**: ビジネス特有のルールや例外処理に説明があることを確認すること
- [ ] **外部仕様**: 外部API、サードパーティライブラリとの連携に説明があることを確認すること
- [ ] **データ制約**: データベース制約や外部システムの制限に説明があることを確認すること

###### 技術的な判断

- [ ] **パフォーマンス最適化**: 最適化の理由が説明されていることを確認すること
- [ ] **セキュリティ対策**: セキュリティ上の理由が説明されていることを確認すること
- [ ] **互換性維持**: 後方互換性や既存システムとの互換性の理由が説明されていることを確認すること
- [ ] **回避策**: 回避策（ワークアラウンド）の理由と背景が説明されていることを確認すること

###### 複雑なアルゴリズム

- [ ] **アルゴリズムの説明**: 複雑なアルゴリズムの概要が説明されていることを確認すること
- [ ] **正規表現**: 複雑な正規表現に説明があることを確認すること
- [ ] **ステップの説明**: 複雑な処理のステップが説明されていることを確認すること
- [ ] **エッジケース**: エッジケースや境界条件の処理が説明されていることを確認すること

##### 不要なコメント

コードで十分説明できる場合、コメントは不要です。以下の点を確認すること：

###### 自己説明的なコード

- [ ] **メソッド名で説明**: メソッド名で十分説明できるコメントがないかを確認すること
- [ ] **変数名で説明**: 変数名で十分説明できるコメントがないかを確認すること
- [ ] **明白な処理**: 誰が読んでも理解できる処理にコメントがないかを確認すること

###### 時代遅れのコメント

- [ ] **古いコメント**: 実装と一致しない古いコメントがないかを確認すること
- [ ] **削除されるべきTODO**: 完了したTODOコメントが削除されているかを確認すること
- [ ] **無効なFIXME**: 修正済みのFIXMEコメントが削除されているかを確認すること
- [ ] **意味のないコメント**: 意味のない、役に立たないコメントがないかを確認すること

##### TODOとFIXME

TODOやFIXMEを使用する場合は、以下の情報を含めること：

###### 適切な使用

- [ ] **理由の記載**: TODOやFIXMEに理由が書かれていることを確認すること
- [ ] **担当者の記載**: 複数人で開発している場合や、長期にわたるTODO/FIXMEの場合、担当者や作成者が記載されていることを確認すること
- [ ] **期限の記載**: 緊急性がある場合、期限が記載されていることを確認すること
- [ ] **チケット参照**: Issue番号やチケット番号が記載されていることを確認すること

###### 管理

- [ ] **定期的な見直し**: 古いTODO/FIXMEが定期的に見直されていることを確認すること
- [ ] **対応状況**: 対応が必要なTODO/FIXMEがトラッキングされていることを確認すること
- [ ] **完了時の削除**: 完了したTODO/FIXMEが適切に削除されていることを確認すること

##### コメントよりコード

コメントが必要な場合は、コードを改善できないか検討すること：

###### リファクタリングの検討

- [ ] **メソッド抽出**: 複雑な処理をメソッドに抽出できないか確認すること
- [ ] **変数の命名改善**: より説明的な変数名にできないか確認すること
- [ ] **クラス分割**: クラスを分割して責任を明確にできないか確認すること
- [ ] **条件の明確化**: 複雑な条件式をメソッドに抽出できないか確認すること

###### コメントよりコードで表現

- [ ] **コードで表現**: コメントで説明するのではなく、コードで意図を表現できないか確認すること
- [ ] **命名の改善**: コメントが必要な理由が命名の問題ではないか確認すること
- [ ] **構造の改善**: コメントが必要な理由がコード構造の問題ではないか確認すること

### 複雑性の測定基準

#### 定量的な基準

定量的な基準で複雑性を測定すること：

- [ ] **メソッドの長さ**: 20行以内
- [ ] **クラスの長さ**: 100行以内（目安）
- [ ] **ネストの深さ**: 3階層以内
- [ ] **引数の数**: 3個以内
- [ ] **McCabe複雑度**: 10以下
- [ ] **publicメソッド**: 7個以内

#### 定性的な基準

定性的な基準で複雑性を測定すること：

- [ ] **可読性**: 読みやすいことを確認すること
- [ ] **保守性**: 保守しやすいことを確認すること
- [ ] **テスタビリティ**: テストしやすいことを確認すること
- [ ] **拡張性**: 拡張しやすいことを確認すること

### リファクタリングの必要性

#### 複雑性のサイン

複雑性のサインを確認すること：

- [ ] **理解困難**: コードを理解するのに時間がかかることを確認すること
- [ ] **修正困難**: コードを修正するのに時間がかかることを確認すること
- [ ] **テスト困難**: テストを書くのが困難であることを確認すること
- [ ] **重複**: 似たようなコードが複数箇所にあることを確認すること

#### リファクタリングの提案

リファクタリングの提案を確認すること：

- [ ] **単一責任の確認**: クラスやメソッドが複数の責任を持っていないか確認し、単一責任の原則に従うよう分割を提案すること
- [ ] **メソッド抽出**: 長いメソッドを小さなメソッドに分割できないか確認すること。各メソッドが単一の責任を持つようにすること
- [ ] **クラス抽出**: 大きなクラスを複数のクラスに分割できないか確認すること。各クラスが単一の責任を持つようにすること
- [ ] **ポリモーフィズム**: 条件分岐をポリモーフィズムで置き換えられないか確認すること
- [ ] **パターン適用**: デザインパターンを適用できないか確認すること
- [ ] **レイヤー分離**: 適切なレイヤー（Service、Form Object、Query Objectなど）を導入できないか確認すること。各レイヤーが単一の責任を持つようにすること

## 詳細解説

ルールの詳細は以下に記載します。

CLが必要以上に複雑になっていないでしょうか？ CLのあらゆるレベルで確認してください。 「複雑すぎる」とは普通、「コードを読んですぐに理解できない」という意味です。 あるいは、「開発者がこのコードを呼び出したり修正したりしようとするときに不具合を生み出す可能性がある」という意味でもあります。

### 目次

- [基本原則](#基本原則)
- [一行レベルの複雑性](#一行レベルの複雑性)
- [メソッドレベルの複雑性](#メソッドレベルの複雑性)
- [クラスレベルの複雑性](#クラスレベルの複雑性)
- [条件分岐の複雑性](#条件分岐の複雑性)
- [ループの複雑性](#ループの複雑性)
- [Ruby特有の複雑性](#ruby特有の複雑性)
- [Rails特有の複雑性](#rails特有の複雑性)
- [認知的複雑度](#認知的複雑度)

### 基本原則

#### 複雑性の定義

##### なぜ重要なのか

複雑なコードは：

1. **理解困難**: 読むのに時間がかかる
2. **バグの温床**: 修正時にバグを生みやすい
3. **保守コスト**: メンテナンスコストが高い
4. **拡張困難**: 機能追加が難しい

```ruby
## ❌ 悪い例：複雑すぎて理解困難
def process_order(order)
  if order.items.any? && order.user.active? && order.payment_method.present?
    total = order.items.map { |item| item.price * item.quantity * (1 - (item.discount || 0)) }.sum
    if order.user.premium? && total > 10000
      total *= 0.9
    elsif order.user.vip? && total > 5000
      total *= 0.85
    end
    if order.shipping_address.country == 'JP'
      shipping = total > 5000 ? 0 : 500
    else
      shipping = total > 10000 ? 0 : 1000
    end
    order.update!(total: total + shipping, status: 'processed')
    OrderMailer.confirmation(order).deliver_later
    InventoryService.decrease(order.items)
    PointService.award(order.user, total * 0.01) if order.user.premium?
  end
end

## ✅ 良い例：シンプルで理解しやすい
def process_order(order)
  return unless order.processable?

  order.calculate_total
  order.process!
  notify_order_processed(order)
end

## 複雑な処理は別メソッドに分離
class Order
  def processable?
    items.any? && user.active? && payment_method.present?
  end

  def calculate_total
    item_total = calculate_item_total
    discount = calculate_discount(item_total)
    shipping = calculate_shipping(item_total)
    update!(total: item_total - discount + shipping)
  end

  private

  def calculate_item_total
    items.sum(&:subtotal)
  end

  def calculate_discount(total)
    DiscountCalculator.new(user, total).calculate
  end

  def calculate_shipping(total)
    ShippingCalculator.new(shipping_address, total).calculate
  end
end
```

#### オーバーエンジニアリングの回避

##### なぜ重要なのか

オーバーエンジニアリングは：

1. **不要な複雑性**: 現在必要ない機能で複雑化
2. **YAGNI違反**: You Aren't Gonna Need It（必要になってから作る）
3. **保守負担**: 使われない機能のメンテナンス
4. **理解困難**: 過度な抽象化で理解が困難

```ruby
## ❌ 悪い例：オーバーエンジニアリング
class UserNotifier
  # 将来的に複数の通知方法に対応するための過剰な設計
  def initialize(strategy_factory: NotificationStrategyFactory.new)
    @strategy_factory = strategy_factory
  end

  def notify(user, message, options = {})
    strategy = @strategy_factory.create_strategy(
      notification_type: options[:type] || :email,
      priority: options[:priority] || :normal,
      retry_policy: options[:retry_policy] || default_retry_policy,
      fallback_strategy: options[:fallback_strategy]
    )

    strategy.deliver(
      recipient: user,
      content: message,
      metadata: build_metadata(options)
    )
  end

  private

  def build_metadata(options)
    # 複雑なメタデータ構築（実際は使われていない）
  end

  def default_retry_policy
    # 複雑なリトライポリシー（実際は必要ない）
  end
end

## ✅ 良い例：現在必要なものだけを実装
class UserNotifier
  def notify(user, message)
    UserMailer.notification(user, message).deliver_later
  end
end

## 将来的に複数の通知方法が必要になったら、その時にリファクタリング
```

### 一行レベルの複雑性

#### 行の長さ

##### なぜ重要なのか

長い行は：

1. **視認性**: 横スクロールが必要
2. **可読性**: 一度に理解できる情報量を超える
3. **レビュー**: コードレビューが困難

```ruby
## ❌ 悪い例：長すぎる行
users = User.where(active: true).includes(:profile, :posts).where('posts.published_at > ?', 1.week.ago).order('posts.published_at DESC').limit(10)

## ✅ 良い例：適切に改行
users = User
  .where(active: true)
  .includes(:profile, :posts)
  .where('posts.published_at > ?', 1.week.ago)
  .order('posts.published_at DESC')
  .limit(10)

## または、スコープを活用
users = User
  .active
  .with_associations
  .recently_posted
  .by_post_date
  .limit(10)
```

#### 式の複雑さ

##### なぜ重要なのか

複雑な式は：

1. **理解困難**: 一度で理解できない
2. **デバッグ困難**: 問題箇所の特定が難しい
3. **テスト困難**: テストが書きにくい

```ruby
## ❌ 悪い例：複雑な三項演算子
price = user.premium? ? (order.total > 10000 ? order.total * 0.9 : order.total * 0.95) : order.total

## ✅ 良い例：変数に分割
discount_rate = if user.premium?
  order.total > 10000 ? 0.9 : 0.95
else
  1.0
end
price = order.total * discount_rate

## さらに良い例：メソッドに抽出
price = calculate_discounted_price(order, user)

def calculate_discounted_price(order, user)
  return order.total unless user.premium?

  discount_rate = order.total > 10000 ? 0.9 : 0.95
  order.total * discount_rate
end
```

```ruby
## ❌ 悪い例：複雑な正規表現
if email =~ /\A[a-zA-Z0-9.!\#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*\z/

## ✅ 良い例：定数に抽出してコメント
## RFC 5322準拠のメールアドレス形式
EMAIL_REGEX = /\A[a-zA-Z0-9.!\#$%&'*+\/=?^_`{|}~-]+@
               [a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?
               (?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*\z/x

if email =~ EMAIL_REGEX

## さらに良い例：バリデーションライブラリを使用
if EmailValidator.valid?(email)
```

### メソッドレベルの複雑性

#### メソッドの長さ

##### なぜ重要なのか

長いメソッドは：

1. **理解困難**: 全体像の把握が困難
2. **単一責任違反**: 複数の責任を持つ可能性
3. **テスト困難**: テストケースが多くなる
4. **再利用困難**: 部分的な再利用ができない

```ruby
## ❌ 悪い例：長すぎるメソッド（50行以上）
def create_user_with_setup(params)
  # バリデーション
  if params[:email].blank?
    errors.add(:email, 'を入力してください')
    return false
  end

  if User.exists?(email: params[:email])
    errors.add(:email, 'は既に使用されています')
    return false
  end

  # ユーザー作成
  user = User.new(
    name: params[:name],
    email: params[:email],
    password: params[:password]
  )

  # プロファイル作成
  user.build_profile(
    bio: params[:bio],
    avatar: params[:avatar]
  )

  # 設定作成
  user.build_settings(
    notification_email: true,
    notification_push: false
  )

  # 保存とエラーハンドリング
  begin
    ActiveRecord::Base.transaction do
      user.save!

      # 初期権限付与
      user.permissions.create!(resource: 'posts', action: 'read')
      user.permissions.create!(resource: 'comments', action: 'create')

      # ウェルカムメール送信
      UserMailer.welcome(user).deliver_later

      # 管理者通知
      AdminMailer.new_user(user).deliver_later

      # アナリティクス
      Analytics.track('user_registered', user_id: user.id)
    end
  rescue ActiveRecord::RecordInvalid => e
    errors.add(:base, e.message)
    return false
  end

  true
end

## ✅ 良い例：メソッドを分割（各メソッドが20行以内）
def create_user_with_setup(params)
  return false unless valid_params?(params)

  user = build_user(params)
  return false unless save_user_with_setup(user)

  notify_user_created(user)
  true
end

private

def valid_params?(params)
  if params[:email].blank?
    errors.add(:email, 'を入力してください')
    return false
  end

  if User.exists?(email: params[:email])
    errors.add(:email, 'は既に使用されています')
    return false
  end

  true
end

def build_user(params)
  User.new(name: params[:name], email: params[:email], password: params[:password]).tap do |user|
    user.build_profile(bio: params[:bio], avatar: params[:avatar])
    user.build_settings(notification_email: true, notification_push: false)
  end
end

def save_user_with_setup(user)
  ActiveRecord::Base.transaction do
    user.save!
    setup_initial_permissions(user)
    true
  end
rescue ActiveRecord::RecordInvalid => e
  errors.add(:base, e.message)
  false
end

def setup_initial_permissions(user)
  user.permissions.create!(resource: 'posts', action: 'read')
  user.permissions.create!(resource: 'comments', action: 'create')
end

def notify_user_created(user)
  UserMailer.welcome(user).deliver_later
  AdminMailer.new_user(user).deliver_later
  Analytics.track('user_registered', user_id: user.id)
end
```

#### メソッドの引数

##### なぜ重要なのか

多すぎる引数は：

1. **呼び出し困難**: 引数の順序を覚えにくい
2. **理解困難**: メソッドの責任が不明確
3. **変更困難**: 引数の追加・削除が影響大

```ruby
## ❌ 悪い例：引数が多すぎる
def create_order(user_id, product_id, quantity, price, discount, shipping_address,
                 billing_address, payment_method, gift_message, gift_wrap)
  # 処理
end

## 呼び出し時も複雑
create_order(1, 100, 2, 1000, 0.1, address1, address2, 'credit_card', nil, false)

## ✅ 良い例：キーワード引数を使用
def create_order(user_id:, product_id:, quantity:, price:,
                 discount: 0, shipping_address:, billing_address: nil,
                 payment_method: 'credit_card', gift_message: nil, gift_wrap: false)
  # 処理
end

## 呼び出し時に明確
create_order(
  user_id: 1,
  product_id: 100,
  quantity: 2,
  price: 1000,
  shipping_address: address
)

## さらに良い例：オブジェクトにまとめる
class OrderParams
  attr_accessor :user_id, :product_id, :quantity, :price, :discount,
                :shipping_address, :billing_address, :payment_method,
                :gift_message, :gift_wrap

  def initialize(**attrs)
    attrs.each { |key, value| public_send("#{key}=", value) }
  end
end

def create_order(params)
  # 処理
end

## 呼び出し
params = OrderParams.new(
  user_id: 1,
  product_id: 100,
  quantity: 2,
  price: 1000,
  shipping_address: address
)
create_order(params)
```

#### ネストの深さ

##### なぜ重要なのか

深いネストは：

1. **理解困難**: どのif/elseにいるか把握困難
2. **テスト困難**: 全ての経路をテストするのが困難
3. **保守困難**: 修正時にロジックを追いにくい

```ruby
## ❌ 悪い例：ネストが深い（5階層）
def process_payment(order)
  if order.present?
    if order.user.active?
      if order.payment_method.present?
        if order.payment_method.valid?
          if order.total > 0
            # 支払い処理
            payment = Payment.create(order: order, amount: order.total)
            if payment.persisted?
              order.update(status: 'paid')
              true
            else
              false
            end
          end
        end
      end
    end
  end
end

## ✅ 良い例：ガード節で早期リターン（ネスト1階層）
def process_payment(order)
  return false if order.blank?
  return false unless order.user.active?
  return false if order.payment_method.blank?
  return false unless order.payment_method.valid?
  return false if order.total <= 0

  payment = Payment.create(order: order, amount: order.total)
  return false unless payment.persisted?

  order.update(status: 'paid')
  true
end

## さらに良い例：責任を分離
def process_payment(order)
  return false unless payment_processable?(order)

  payment = create_payment(order)
  return false unless payment

  complete_order(order)
  true
end

private

def payment_processable?(order)
  order.present? &&
    order.user.active? &&
    order.payment_method&.valid? &&
    order.total > 0
end

def create_payment(order)
  Payment.create(order: order, amount: order.total).tap do |payment|
    return nil unless payment.persisted?
  end
end

def complete_order(order)
  order.update(status: 'paid')
end
```

#### 循環的複雑度

##### なぜ重要なのか

高い循環的複雑度は：

1. **テスト困難**: テストケース数が指数的に増加
2. **理解困難**: 分岐が多く流れを追いにくい
3. **バグの温床**: 条件の組み合わせでバグが発生しやすい

```ruby
## ❌ 悪い例：循環的複雑度が高い（15以上）
def calculate_shipping_cost(order)
  cost = 0

  if order.weight > 10
    cost += 1000
  elsif order.weight > 5
    cost += 500
  else
    cost += 300
  end

  if order.destination.country == 'JP'
    if order.destination.prefecture == '東京都'
      cost += 100
    elsif order.destination.prefecture == '大阪府'
      cost += 200
    else
      cost += 300
    end
  elsif order.destination.country == 'US'
    cost += 2000
  else
    cost += 3000
  end

  if order.express_delivery?
    cost *= 1.5
  end

  if order.user.premium?
    cost *= 0.9
  end

  if order.total > 10000
    cost = 0
  end

  cost
end

## ✅ 良い例：複雑度を下げる（各メソッドの複雑度が5以下）
def calculate_shipping_cost(order)
  base_cost = calculate_base_shipping_cost(order.weight)
  destination_cost = calculate_destination_cost(order.destination)
  total_cost = base_cost + destination_cost

  total_cost = apply_express_delivery(total_cost, order)
  total_cost = apply_user_discount(total_cost, order.user)
  total_cost = apply_free_shipping(total_cost, order.total)

  total_cost
end

private

def calculate_base_shipping_cost(weight)
  case weight
  when 0..5 then 300
  when 5..10 then 500
  else 1000
  end
end

def calculate_destination_cost(destination)
  return 0 if destination.country != 'JP'

  case destination.prefecture
  when '東京都' then 100
  when '大阪府' then 200
  else 300
  end
end

def apply_express_delivery(cost, order)
  order.express_delivery? ? cost * 1.5 : cost
end

def apply_user_discount(cost, user)
  user.premium? ? cost * 0.9 : cost
end

def apply_free_shipping(cost, total)
  total > 10000 ? 0 : cost
end
```

### クラスレベルの複雑性

#### クラスの大きさ

##### なぜ重要なのか

大きなクラスは：

1. **理解困難**: 全体像の把握が困難
2. **単一責任違反**: 複数の責任を持つ
3. **変更影響**: 修正の影響範囲が広い
4. **テスト困難**: テストが膨大になる

```ruby
## ❌ 悪い例：大きすぎるクラス（300行以上）
class User < ApplicationRecord
  # 認証関連
  has_secure_password
  validates :email, presence: true, uniqueness: true

  def authenticate_with_otp(code)
    # OTP認証ロジック（20行）
  end

  def reset_password(token)
    # パスワードリセット（30行）
  end

  # プロフィール関連
  def update_profile(params)
    # プロフィール更新（40行）
  end

  def complete_profile?
    # プロフィール完成度チェック（20行）
  end

  # 通知関連
  def send_notification(message)
    # 通知送信（30行）
  end

  def notification_preferences
    # 通知設定（25行）
  end

  # 権限関連
  def has_permission?(resource, action)
    # 権限チェック（40行）
  end

  def grant_permission(resource, action)
    # 権限付与（30行）
  end

  # 統計関連
  def calculate_activity_score
    # アクティビティスコア計算（50行）
  end

  # その他多数のメソッド...
end

## ✅ 良い例：責任を分離（各クラスが100行以内）
class User < ApplicationRecord
  has_secure_password
  validates :email, presence: true, uniqueness: true

  # 認証はAuthenticationServiceに委譲
  def authenticate_with_otp(code)
    AuthenticationService.new(self).authenticate_with_otp(code)
  end

  # プロフィールはUserProfileに委譲
  def update_profile(params)
    UserProfile.new(self).update(params)
  end

  # 通知はNotificationServiceに委譲
  def send_notification(message)
    NotificationService.new(self).send(message)
  end

  # 権限はUserPermissionsに委譲
  def has_permission?(resource, action)
    UserPermissions.new(self).has?(resource, action)
  end
end

## 各サービスクラスは明確な責任を持つ
class AuthenticationService
  def initialize(user)
    @user = user
  end

  def authenticate_with_otp(code)
    # OTP認証ロジック
  end

  def reset_password(token)
    # パスワードリセット
  end
end

class UserProfile
  def initialize(user)
    @user = user
  end

  def update(params)
    # プロフィール更新
  end

  def complete?
    # プロフィール完成度チェック
  end
end
```

#### publicメソッドの数

##### なぜ重要なのか

多すぎるpublicメソッドは：

1. **インターフェース肥大化**: クラスの使い方が複雑
2. **責任不明確**: クラスの責任が不明確
3. **変更困難**: 公開APIの変更が困難

```ruby
## ❌ 悪い例：publicメソッドが多すぎる（15個以上）
class OrderService
  def create_order(params)
  end

  def update_order(order, params)
  end

  def cancel_order(order)
  end

  def calculate_total(order)
  end

  def calculate_discount(order)
  end

  def calculate_shipping(order)
  end

  def apply_coupon(order, coupon)
  end

  def remove_coupon(order)
  end

  def add_item(order, item)
  end

  def remove_item(order, item)
  end

  def update_quantity(order, item, quantity)
  end

  def validate_order(order)
  end

  def send_confirmation(order)
  end

  def process_payment(order)
  end

  def refund_payment(order)
  end
end

## ✅ 良い例：必要最小限のpublicメソッド（7個以内）
class OrderService
  def create(params)
    order = build_order(params)
    save_order(order)
  end

  def update(order, params)
    order.assign_attributes(params)
    recalculate_and_save(order)
  end

  def cancel(order)
    order.cancel!
    notify_cancellation(order)
  end

  def process(order)
    validate_order(order)
    process_payment(order)
    complete_order(order)
  end

  private

  def build_order(params)
    # 内部実装
  end

  def calculate_total(order)
    # 内部実装
  end

  def calculate_discount(order)
    # 内部実装
  end

  # その他の内部メソッド...
end
```

### 条件分岐の複雑性

#### ガード節による早期リターン

##### なぜ重要なのか

ガード節により：

1. **可読性向上**: 正常系が明確
2. **ネスト削減**: ネストが浅くなる
3. **理解容易**: 異常系を先に処理

```ruby
## ❌ 悪い例：ネストが深い
def update_user(user, params)
  if user.present?
    if user.active?
      if params[:email].present?
        if EmailValidator.valid?(params[:email])
          user.update(params)
          true
        else
          errors.add(:email, '形式が不正です')
          false
        end
      else
        errors.add(:email, 'を入力してください')
        false
      end
    else
      errors.add(:base, 'ユーザーが無効です')
      false
    end
  else
    errors.add(:base, 'ユーザーが見つかりません')
    false
  end
end

## ✅ 良い例：ガード節で早期リターン
def update_user(user, params)
  return error('ユーザーが見つかりません') if user.blank?
  return error('ユーザーが無効です') unless user.active?
  return error('メールアドレスを入力してください') if params[:email].blank?
  return error('メールアドレスの形式が不正です') unless EmailValidator.valid?(params[:email])

  user.update(params)
  true
end

private

def error(message)
  errors.add(:base, message)
  false
end
```

#### ポリモーフィズムによる条件分岐の置き換え

##### なぜ重要なのか

ポリモーフィズムにより：

1. **拡張性**: 新しいケースの追加が容易
2. **単一責任**: 各クラスが明確な責任
3. **テスト容易**: 個別にテストできる

```ruby
## ❌ 悪い例：長いcase文
class NotificationService
  def send_notification(user, message, type)
    case type
    when :email
      UserMailer.notification(user, message).deliver_later
    when :sms
      SmsService.send(user.phone, message)
    when :push
      PushNotification.send(user.device_token, message)
    when :slack
      SlackNotifier.notify(user.slack_id, message)
    when :line
      LineBot.push_message(user.line_id, message)
    else
      raise "Unknown notification type: #{type}"
    end
  end
end

## ✅ 良い例：ポリモーフィズム
class NotificationService
  def send_notification(user, message, notifier)
    notifier.send(user, message)
  end
end

## 各通知方法を独立したクラスに
class EmailNotifier
  def send(user, message)
    UserMailer.notification(user, message).deliver_later
  end
end

class SmsNotifier
  def send(user, message)
    SmsService.send(user.phone, message)
  end
end

class PushNotifier
  def send(user, message)
    PushNotification.send(user.device_token, message)
  end
end

## 使用時
notifier = EmailNotifier.new
NotificationService.new.send_notification(user, message, notifier)

## または、Factoryパターンを使用
notifier = NotifierFactory.create(:email)
NotificationService.new.send_notification(user, message, notifier)
```

#### 複雑な条件のメソッド抽出

##### なぜ重要なのか

メソッド抽出により：

1. **可読性**: 条件の意図が明確
2. **再利用**: 他の箇所でも使用可能
3. **テスト容易**: 条件単体でテスト可能

```ruby
## ❌ 悪い例：複雑な条件式
if user.age >= 18 && user.verified? && !user.suspended? &&
   (user.premium? || user.posts_count > 10)
  # 処理
end

## ✅ 良い例：メソッドに抽出
if user.can_post_advanced_content?
  # 処理
end

class User
  def can_post_advanced_content?
    adult? && verified? && !suspended? && active_contributor?
  end

  private

  def adult?
    age >= 18
  end

  def active_contributor?
    premium? || posts_count > 10
  end
end
```

### ループの複雑性

#### Enumerableメソッドの活用

##### なぜ重要なのか

Enumerableメソッドにより：

1. **可読性**: 意図が明確
2. **簡潔性**: コード量が減少
3. **安全性**: 副作用が少ない

```ruby
## ❌ 悪い例：forループ
active_users = []
for user in users
  if user.active?
    active_users << user
  end
end

## ✅ 良い例：selectメソッド
active_users = users.select(&:active?)

## ❌ 悪い例：eachで配列構築
user_names = []
users.each do |user|
  user_names << user.name
end

## ✅ 良い例：mapメソッド
user_names = users.map(&:name)

## ❌ 悪い例：eachで合計計算
total = 0
orders.each do |order|
  total += order.total
end

## ✅ 良い例：sumメソッド
total = orders.sum(&:total)
```

#### ネストループの回避

##### なぜ重要なのか

ネストループは：

1. **パフォーマンス**: O(n²)になりやすい
2. **理解困難**: ロジックが複雑
3. **保守困難**: 修正が困難

```ruby
## ❌ 悪い例：ネストループ
users.each do |user|
  posts.each do |post|
    if post.user_id == user.id
      user_posts << post
    end
  end
end

## ✅ 良い例：ハッシュで最適化
posts_by_user = posts.group_by(&:user_id)
users.each do |user|
  user_posts = posts_by_user[user.id] || []
end

## さらに良い例：ActiveRecordの活用
users.includes(:posts).each do |user|
  user_posts = user.posts
end
```

### Ruby特有の複雑性

#### ブロックの複雑性

##### なぜ重要なのか

複雑なブロックは：

1. **可読性**: ブロック内のロジックが追いにくい
2. **デバッグ困難**: エラーの原因特定が難しい
3. **再利用困難**: ブロックは再利用できない

```ruby
## ❌ 悪い例：複雑なブロック
users.map do |user|
  {
    id: user.id,
    name: user.name,
    email: user.email,
    posts_count: user.posts.count,
    comments_count: user.comments.count,
    last_login: user.last_login_at&.strftime('%Y-%m-%d'),
    status: user.active? ? 'active' : 'inactive',
    premium: user.premium?,
    score: calculate_user_score(user)
  }
end

## ✅ 良い例：メソッドに抽出
users.map { |user| serialize_user(user) }

def serialize_user(user)
  {
    id: user.id,
    name: user.name,
    email: user.email,
    posts_count: user.posts.count,
    comments_count: user.comments.count,
    last_login: format_last_login(user.last_login_at),
    status: user_status(user),
    premium: user.premium?,
    score: calculate_user_score(user)
  }
end

## さらに良い例：Serializerクラスを使用
users.map { |user| UserSerializer.new(user).to_h }
```

#### メタプログラミングの慎重な使用

##### なぜ重要なのか

メタプログラミングは：

1. **理解困難**: 動的なコード生成が追いにくい
2. **デバッグ困難**: エラーの原因特定が難しい
3. **IDEサポート**: 補完が効かない

```ruby
## ❌ 悪い例：過度なメタプログラミング
class User
  %i[name email phone].each do |attr|
    define_method("#{attr}_present?") do
      send(attr).present?
    end

    define_method("#{attr}_valid?") do
      send("#{attr}_present?") && send(attr).length > 3
    end

    define_method("formatted_#{attr}") do
      send(attr)&.titleize
    end
  end
end

## ✅ 良い例：明示的なメソッド定義
class User
  def name_present?
    name.present?
  end

  def name_valid?
    name_present? && name.length > 3
  end

  def formatted_name
    name&.titleize
  end

  # email、phoneも同様に明示的に定義
end

## メタプログラミングが本当に必要な場合のみ使用
## （例：ActiveRecord内部、DSL実装など）
```

### Rails特有の複雑性

#### Skinny Controller

##### なぜ重要なのか

Controllerは：

1. **HTTPの境界**: リクエスト/レスポンスの処理のみ
2. **ビジネスロジック排除**: Service層に委譲
3. **テスト容易**: Controllerのテストが簡潔

```ruby
## ❌ 悪い例：Fat Controller
class OrdersController < ApplicationController
  def create
    # バリデーション
    if params[:items].blank?
      render json: { error: 'Items required' }, status: :bad_request
      return
    end

    # ユーザー取得
    user = User.find(params[:user_id])

    # 注文作成
    order = Order.new(user: user, status: 'pending')

    # 商品追加
    params[:items].each do |item_params|
      product = Product.find(item_params[:product_id])
      order.order_items.build(
        product: product,
        quantity: item_params[:quantity],
        price: product.price
      )
    end

    # 合計計算
    total = order.order_items.sum { |item| item.price * item.quantity }

    # 割引適用
    if user.premium?
      discount = total * 0.1
      total -= discount
    end

    # 送料計算
    shipping = total > 10000 ? 0 : 500
    total += shipping

    order.total = total

    # 保存
    if order.save
      # メール送信
      OrderMailer.confirmation(order).deliver_later

      # 在庫更新
      order.order_items.each do |item|
        item.product.decrement!(:stock, item.quantity)
      end

      render json: order, status: :created
    else
      render json: { errors: order.errors }, status: :unprocessable_entity
    end
  end
end

## ✅ 良い例：Skinny Controller
class OrdersController < ApplicationController
  def create
    result = OrderCreationService.new(order_params).call

    if result.success?
      render json: result.order, status: :created
    else
      render json: { errors: result.errors }, status: :unprocessable_entity
    end
  end

  private

  def order_params
    params.permit(:user_id, items: [:product_id, :quantity])
  end
end

## ビジネスロジックはServiceに
class OrderCreationService
  def initialize(params)
    @params = params
  end

  def call
    validate_params
    return failure if @errors.present?

    order = build_order
    return failure(order.errors) unless order.save

    process_order(order)
    success(order)
  end

  private

  def validate_params
    @errors = []
    @errors << 'Items required' if @params[:items].blank?
  end

  def build_order
    Order.new(user: user, status: 'pending').tap do |order|
      add_items(order)
      calculate_total(order)
    end
  end

  # その他のprivateメソッド...
end
```

#### Fat Modelの回避

##### なぜ重要なのか

Fat Modelは：

1. **責任過多**: 複数の責任を持つ
2. **テスト困難**: テストが膨大
3. **保守困難**: 変更の影響が大きい

```ruby
## ❌ 悪い例：Fat Model
class User < ApplicationRecord
  # 100以上のメソッド...

  def calculate_recommendation_score
    # 複雑な推薦スコア計算（50行）
  end

  def generate_activity_report
    # アクティビティレポート生成（80行）
  end

  def send_weekly_digest
    # 週次ダイジェスト送信（40行）
  end

  def export_to_csv
    # CSV出力（60行）
  end

  # その他多数...
end

## ✅ 良い例：責任を分離
class User < ApplicationRecord
  # ActiveRecordとしての基本的な振る舞いのみ

  def recommendation_score
    RecommendationScoreCalculator.new(self).calculate
  end

  def activity_report
    ActivityReportGenerator.new(self).generate
  end

  def send_weekly_digest
    WeeklyDigestMailer.new(self).deliver
  end

  def to_csv
    UserCsvExporter.new(self).export
  end
end

## 各機能は独立したクラスに
class RecommendationScoreCalculator
  def initialize(user)
    @user = user
  end

  def calculate
    # スコア計算ロジック
  end
end
```

### 認知的複雑度

#### コードの理解しやすさ

##### なぜ重要なのか

理解しやすいコードは：

1. **保守容易**: 修正が簡単
2. **バグ減少**: 理解ミスによるバグが減る
3. **チーム効率**: オンボーディングが早い

```ruby
## ❌ 悪い例：理解困難（驚き最小の原則違反）
class Calculator
  def add(a, b)
    result = a + b
    log_calculation('add', a, b, result)
    send_notification_to_admin(result) if result > 1000
    update_statistics
    result
  end
end

## ✅ 良い例：単純で予測可能
class Calculator
  def add(a, b)
    a + b
  end
end

## 副作用は別の責務
class CalculationLogger
  def log(operation, a, b, result)
    # ログ記録
  end
end
```

### まとめ

複雑性の管理は：

1. **段階的**: 一行、メソッド、クラス、システムの各レベル
2. **測定可能**: 具体的な基準（行数、ネスト、複雑度）
3. **改善可能**: リファクタリングで削減可能
4. **重要**: 長期的な保守性とチーム生産性に直結

適切な複雑性管理により、理解しやすく、保守しやすく、拡張しやすいコードを実現できます。
