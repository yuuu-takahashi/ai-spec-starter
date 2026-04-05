---
title: ドメイン駆動設計
impact: MEDIUM
tags: rails, review-code, ddd
---

<!-- markdownlint-disable MD024 -->

## ドメイン駆動設計

あなたは、このプロジェクトにおけるAIコーディングアシスタントです。
以降のチェックリストに従って、Rails + RSpec のコードレビュー時にドメイン駆動設計の観点から確認します。

## このチェックリストの前提

このチェックリストは、**Rails + RSpec プロジェクトにおけるコードレビュー時**に使用します。

### 確認すべきこと

- 既にDDDの原則が適用されている前提で、その実装が適切かを確認すること
- 既存のアーキテクチャに沿っているかを確認すること
- ドメインロジックが技術的詳細から適切に分離されているかを確認すること

### 確認しないこと

- DDDを適用すべきかどうかを判断すること（これは設計フェーズで決定される）
- アーキテクチャの変更を提案すること（既存のアーキテクチャに沿っているかを確認する）

**重要な原則**: DDDは「適用する/しない」を選ぶものではなく、**設計の原則として常に意識すべきもの**です。このチェックリストは、コードレビュー時にDDDの原則に沿っているかを確認するためのものです。

## 目次

- [概要](#概要)
- [基本原則](#基本原則)
- [値オブジェクト（Value Object）](#値オブジェクトvalue-object)
- [エンティティ（Entity）](#エンティティentity)
- [リポジトリパターン](#リポジトリパターン)
- [アプリケーションサービス（Service Object）](#アプリケーションサービスservice-object)
- [ドメインサービス](#ドメインサービス)
- [Rails固有の実装パターン](#rails固有の実装パターン)
- [アーキテクチャの原則](#アーキテクチャの原則)
- [レビュー時の質問例](#レビュー時の質問例)
- [参考資料](#参考資料)

## 概要

ドメイン駆動設計（Domain-Driven Design, DDD）は、ドメインの知識に焦点を当てた設計手法です。コードレビューでは、以下の点を確認します：

- **ドメインロジックの分離**: ビジネスロジックが技術的詳細から適切に分離されているか
- **ドメインの表現**: ドメインの概念がコードで適切に表現されているか
- **変更への強さ**: ドメインの変更がコードに反映しやすい構造になっているか
- **テスト容易性**: ドメインロジックが独立してテストできる構造になっているか

**重要な原則**: ドメインロジックは技術的詳細（データベース、フレームワーク、UI）から分離され、ドメインの本質に集中できる構造であるべきです。

## 基本原則

### ドメインロジックの分離

- [ ] **技術的詳細の分離**: ドメインロジックがデータベース、フレームワーク、UIから分離されているか
- [ ] **ドメイン層の独立性**: ドメイン層が他の層に依存していないか（依存関係は内側に向いているか）
- [ ] **ビジネスルールの集約**: ビジネスルールがドメインオブジェクトに集約されているか
- [ ] **技術的詳細の隠蔽**: データベース操作やフレームワーク固有の処理がドメイン層に漏れていないか

### ユビキタス言語（Ubiquitous Language）

- [ ] **ドメイン用語の使用**: コードでドメインエキスパートが使う用語を使用しているか
- [ ] **用語の一貫性**: 同じ概念に対して同じ用語を使用しているか
- [ ] **技術用語の回避**: ドメイン層で技術用語（`save`、`update`など）を避け、ドメイン用語（`register`、`change_name`など）を使用しているか
- [ ] **命名の明確性**: クラス名、メソッド名がドメインの概念を明確に表現しているか

### ドメインと技術の分離

- [ ] **ActiveRecordの適切な使用**: ActiveRecordモデルがエンティティとして適切に使用されているか
- [ ] **値オブジェクトの活用**: プリミティブ型の代わりに値オブジェクトを使用しているか
- [ ] **リポジトリパターンの適用**: データストア操作がリポジトリで抽象化されているか
- [ ] **ドメインロジックの漏出防止**: ドメインロジックがControllerやViewに漏れていないか

## 値オブジェクト（Value Object）

### 不変性（Immutable）

#### ルール

- [ ] **attr_readerの使用**: 値オブジェクトで`attr_reader`のみを使用し、`attr_accessor`を使用していないか
- [ ] **変更メソッドの回避**: `change_xxx`のような変更メソッドを定義していないか。代わりに、新しいインスタンスを返す`with_xxx`メソッドを実装すること
- [ ] **with_xxxメソッドの実装**: 変更が必要な場合は、新しいインスタンスを返す`with_xxx`メソッドを実装しているか
- [ ] **attr_readerのみ**: `attr_accessor`ではなく`attr_reader`のみを使用して不変性を保証しているか

#### 例

```ruby
# 良い例：不変な値オブジェクト
class FullName
  attr_reader :first_name, :last_name

  def initialize(first_name, last_name)
    @first_name = first_name
    @last_name = last_name
  end

  def with_last_name(new_last_name)
    FullName.new(@first_name, new_last_name)
  end
end

# 悪い例：可変な値オブジェクト
class FullName
  attr_accessor :first_name, :last_name  # 可変になってしまう

  def change_last_name(new_last_name)
    @last_name = new_last_name  # オブジェクト自体を変更
  end
end
```

### バリデーションの集約

#### ルール

- [ ] **コンストラクタでのバリデーション**: 値オブジェクトのコンストラクタでバリデーションを実行しているか
- [ ] **不正値の排除**: 不正な値がシステム内に存在しないようにしているか（「遅効性の毒」を防ぐ）
- [ ] **ルールの集約**: バリデーションルールが値オブジェクト内に集約され、散在していないか。代わりに、バリデーションロジックを値オブジェクト内に集約すること
- [ ] **エラーメッセージの明確性**: バリデーションエラーのメッセージが明確で、ドメインルールを表現しているか

#### 例

```ruby
# 良い例：バリデーションが集約されている
class UserName
  MIN_LENGTH = 3

  attr_reader :value

  def initialize(value)
    raise ArgumentError, "ユーザ名は#{MIN_LENGTH}文字以上です" if value.nil? || value.length < MIN_LENGTH
    @value = value
  end
end

# 悪い例：バリデーションが散在している
def create_user(name)
  if name.length < 3  # バリデーションが散在
    raise "ユーザ名は3文字以上です"
  end
  User.create(name: name)
end

def update_user(id, name)
  if name.length < 3  # 同じバリデーションが重複
    raise "ユーザ名は3文字以上です"
  end
  User.find(id).update(name: name)
end
```

### 表現力の向上

#### ルール

- [ ] **プリミティブ型の回避**: プリミティブ型（`String`、`Integer`など）の代わりに値オブジェクトを使用しているか。代わりに、ドメイン概念を表現する値オブジェクトを作成すること
- [ ] **自己文書化**: コードを見ただけで、値の意味が明確に分かるか
- [ ] **構造の明確化**: 複数の値から構成される概念が値オブジェクトとして表現されているか

#### 例

```ruby
# 良い例：値オブジェクトで表現力が向上
def create_product(model_number)
  # model_number が ModelNumber 型であることが明確
end

model = ModelNumber.new("a20421", "100", "1")
create_product(model)

# 悪い例：プリミティブ型では意味が伝わらない
def create_product(model_number)
  # model_number が何なのかわからない（文字列？数字？）
end

create_product("a20421-100-1")  # これが正しいのか間違っているのかわからない
```

### 等価性の実装

#### ルール

- [ ] **==メソッドの実装**: 値オブジェクトで`==`メソッドを適切に実装しているか
- [ ] **eql?メソッドの実装**: `eql?`メソッドを`==`と同等に実装しているか（`alias_method :eql?, :==`）
- [ ] **hashメソッドの実装**: `hash`メソッドを実装し、等価なオブジェクトが同じハッシュ値を返すようにしているか
- [ ] **属性による比較**: インスタンスの同一性ではなく、属性の値で等価性を判断しているか

#### 例

```ruby
# 良い例：等価性が適切に実装されている
class FullName
  attr_reader :first_name, :last_name

  def initialize(first_name, last_name)
    @first_name = first_name
    @last_name = last_name
  end

  def ==(other)
    return false unless other.is_a?(FullName)
    @first_name == other.first_name && @last_name == other.last_name
  end

  alias_method :eql?, :==

  def hash
    [@first_name, @last_name].hash
  end
end

# 使用例
name1 = FullName.new("masanobu", "naruse")
name2 = FullName.new("masanobu", "naruse")
name1 == name2  # => true（属性が等しいので）
```

### 値オブジェクトを使う判断基準

- [ ] **ルールの存在**: そこにルール（バリデーション、ビジネスルール）が存在しているか
- [ ] **単独での取り扱い**: それ単体で取り扱いたいか（メソッドの引数や戻り値として単独で渡す）
- [ ] **複数の値の組み合わせ**: 複数の値から構成される概念として扱うか
- [ ] **型安全性の必要性**: 同じプリミティブ型だが意味が異なる値を区別したいか

## エンティティ（Entity）

### 同一性（Identity）

#### ルール

- [ ] **IDによる識別**: エンティティがIDで識別されているか
- [ ] **属性による比較の回避**: エンティティ同士を属性の値で比較していないか。代わりに、IDで比較すること
- [ ] **IDの一意性**: エンティティのIDが一意であることを保証しているか

#### 例

```ruby
# 良い例：IDで識別されるエンティティ
class User
  attr_accessor :id, :name, :email

  def initialize(id, name, email)
    @id = id
    @name = name
    @email = email
  end

  def ==(other)
    @id == other.id  # IDで比較（同一性）
  end
end

# 悪い例：属性で比較している
class User
  def ==(other)
    @name == other.name && @email == other.email  # 属性で比較（等価性）
  end
end
```

### 可変性（Mutable）

#### ルール

- [ ] **可変性の許容**: エンティティが可変であることを理解しているか
- [ ] **ActiveRecordモデルの理解**: ActiveRecordモデルはエンティティであり、可変であることが前提であることを理解しているか
- [ ] **値オブジェクトとの違い**: エンティティと値オブジェクトの違いを理解しているか。エンティティは可変、値オブジェクトは不変であることを理解しているか

#### 例

```ruby
# 良い例：エンティティは可変
class User < ApplicationRecord
  # ActiveRecordモデルはエンティティなので、可変であることが前提
  # attr_accessor を使うのは問題ない
end

user = User.find(1)
user.name = "新しい名前"  # 同じオブジェクトの状態が変わる（可変）

# 値オブジェクトは不変
name1 = FullName.new("太郎", "山田")
name2 = name1.with_last_name("佐藤")  # 新しいオブジェクト（不変）
```

### エンティティと値オブジェクトの使い分け

#### ルール

- [ ] **エンティティの判断**: ライフサイクルがあり、時間の経過とともに状態が変わる「実体」を表現しているか
- [ ] **値オブジェクトの判断**: 不変で、等価性で比較される「値」を表現しているか
- [ ] **組み合わせの活用**: エンティティの中に値オブジェクトを属性として持つことを検討しているか

#### 例

```ruby
# 良い例：エンティティの中に値オブジェクトを持つ
class User < ApplicationRecord
  def name_object
    FullName.new(first_name, last_name) if first_name && last_name
  end

  def name_object=(full_name)
    self.first_name = full_name.first_name
    self.last_name = full_name.last_name
  end
end
```

## リポジトリパターン

### データストアの抽象化

#### ルール

- [ ] **抽象化の実現**: データストアの詳細（SQL、NoSQLなど）が隠蔽されているか
- [ ] **オブジェクト単位での操作**: 個別の更新メソッド（`UpdateName`など）ではなく、オブジェクト単位で操作しているか。代わりに、`userRepository.save(user)`のようにオブジェクト単位で操作すること
- [ ] **意図の明確性**: `userRepository.save(user)`のように、コードの意図が明確になっているか

### Railsでの実装

#### ルール

- [ ] **ActiveRecordの活用**: ActiveRecordが既にリポジトリ的な役割を担っていることを理解しているか
- [ ] **複雑なクエリの集約**: 複雑なクエリロジックがリポジトリクラスまたはモデルのクラスメソッドに集約されているか。代わりに、クエリロジックを散在させず、リポジトリクラスまたはモデルのクラスメソッドに集約すること
- [ ] **値オブジェクトとの変換**: 値オブジェクトとActiveRecordモデルの間の変換が適切に実装されているか

#### 例

```ruby
# 良い例：複雑なクエリロジックを集約
class UserRepository
  class << self
    def find_by_name(user_name)
      User.find_by(name: user_name.value)
    end

    def recently_created_active_users
      User.active.recent.order(created_at: :desc)
    end

    def exists_by_name?(user_name)
      User.exists?(name: user_name.value)
    end
  end
end

# または、ActiveRecordのクラスメソッドとして
class User < ApplicationRecord
  scope :active, -> { where(active: true) }
  scope :recent, -> { where("created_at > ?", 1.month.ago) }

  def self.find_by_name(user_name)
    find_by(name: user_name.value)
  end
end
```

### テスト容易性

#### ルール

- [ ] **インメモリリポジトリの実装**: テスト用にインメモリリポジトリを実装できる構造になっているか
- [ ] **インターフェースの定義**: リポジトリのインターフェースが定義され、実装を切り替え可能になっているか（TypeScript/Next.jsの場合）。Railsの場合は、ActiveRecordが既にリポジトリ的な役割を担っているため、この項目は該当しない

## アプリケーションサービス（Service Object）

### ビジネスプロセスの実装

#### ルール

- [ ] **ビジネスプロセス単位**: アクションごとではなく、ビジネスプロセスごとにService Objectを作成しているか。代わりに、1つのビジネスプロセスを1つのService Objectで実装すること
- [ ] **単一責任の原則**: Service Objectが単一のビジネスプロセスを担当しているか
- [ ] **命名の適切性**: `動詞 + 名詞 + Service` または `Namespace::動詞Service` の形式で命名されているか

#### 例

```ruby
# 良い例：ビジネスプロセス単位のService Object
class Orders::CreateService
  def initialize(params)
    @params = params
  end

  def call
    # 注文作成のビジネスプロセスを実装
  end
end

class OrderProcessingService
  def call
    # 注文処理のビジネスプロセスを実装（複数のService Objectを組み合わせる）
  end
end
```

### 戻り値のパターン

- [ ] **Resultオブジェクトの使用**: エラー情報を構造化して返すためにResultオブジェクトを使用しているか（推奨）
- [ ] **エラー情報の構造化**: エラー情報が構造化され、呼び出し側で適切に処理できるか
- [ ] **一貫性**: プロジェクト内で戻り値のパターンが統一されているか

```ruby
# 良い例：Resultオブジェクトを返す（推奨）
class OrderProcessingService
  Result = Struct.new(:success?, :data, :errors, keyword_init: true)

  def call
    ActiveRecord::Base.transaction do
      # 処理...
      Result.new(success?: true, data: order)
    rescue StandardError => e
      Result.new(success?: false, errors: [e.message])
    end
  end
end

# Controllerでの使用
result = OrderProcessingService.new(params).call
if result.success?
  render json: { order: result.data }, status: :created
else
  render json: { errors: result.errors }, status: :unprocessable_entity
end
```

### トランザクション管理

#### ルール

- [ ] **トランザクションの適用**: 複数の処理をまとめてトランザクションで管理しているか。代わりに、1つのビジネストランザクション単位でトランザクションを設定すること
- [ ] **ロールバックの適切性**: エラー時に適切にロールバックされるか
- [ ] **非同期処理の扱い**: メール送信など、失敗してもロールバックしない処理を適切に扱っているか。代わりに、非同期処理はトランザクション外で実行し、失敗してもロールバックしないようにすること

#### 例

```ruby
# 良い例：トランザクション管理
class OrderProcessingService
  def call
    ActiveRecord::Base.transaction do
      order = Order.create!(@params)
      Inventory::UpdateService.new(order).call!
      # メール送信は非同期、失敗してもロールバックしない
      begin
        OrderMailerService.new(order).call_async
      rescue => e
        Rails.logger.warn("メール送信に失敗: #{e.message}")
      end
      order
    end
  end
end
```

### Controllerでの実装

#### ルール

- [ ] **renderの実装**: Controllerでレスポンスを返しているか（Service Objectでrenderしない）。代わりに、Service ObjectはResultオブジェクトを返し、Controllerでrenderすること
- [ ] **エラーハンドリング**: Serviceの結果をチェックし、適切なHTTPステータスを返しているか。代わりに、Resultオブジェクトの`success?`をチェックし、成功時は200系、失敗時は400系のステータスを返すこと
- [ ] **ログの記録**: 予期しないエラーはログに記録しているか

## ドメインサービス

### ドメインサービスの役割

#### ルール

- [ ] **不自然なふるまいの解決**: エンティティや値オブジェクトに属さない「不自然なふるまい」を解決しているか
- [ ] **濫用の回避**: エンティティや値オブジェクトに属するふるまいは、エンティティや値オブジェクトに持たせているか。エンティティや値オブジェクトに属さない「不自然なふるまい」のみをドメインサービスとして実装しているか
- [ ] **最後の手段**: ドメインサービスは「最後の手段」として使用されているか。代わりに、まずエンティティや値オブジェクトにふるまいを持たせることを検討すること

#### 例

```ruby
# 良い例：ドメインサービスの適切な使用
class UserNameDuplicationService
  def self.exists?(user_name, user_repository)
    # ユーザ名の重複確認は、Userエンティティだけでは判断できない
    # リポジトリへのアクセスが必要なため、ドメインサービスとして実装
    user_repository.exists_by_name?(user_name)
  end
end

# 悪い例：ドメインサービスの濫用
class UserNameValidationService
  def self.valid?(user_name)
    # これは値オブジェクト（UserName）に持たせるべき
    user_name.length >= 3
  end
end
```

## Rails固有の実装パターン

### ActiveRecordと値オブジェクトの共存

#### ルール

- [ ] **値オブジェクトの変換**: ActiveRecordモデルと値オブジェクトの間の変換が適切に実装されているか
- [ ] **属性としての値オブジェクト**: エンティティの中に値オブジェクトを属性として持つことを検討しているか。代わりに、プリミティブ型の代わりに値オブジェクトを属性として持つことを検討すること

#### 例

```ruby
# 良い例：ActiveRecordモデルと値オブジェクトの共存
class User < ApplicationRecord
  def name_object
    FullName.new(first_name, last_name) if first_name && last_name
  end

  def name_object=(full_name)
    self.first_name = full_name.first_name
    self.last_name = full_name.last_name
  end
end
```

### Service Objectの配置

#### ルール

- [ ] **ディレクトリ構成**: Service Objectが適切なディレクトリに配置されているか
- [ ] **命名空間の使用**: 関連するService Objectが適切な名前空間で整理されているか。代わりに、関連するService Objectは同じ名前空間で整理すること

#### 例

```ruby
# 良い例：名前空間で整理
module Orders
  class CreateService
  end

  class UpdateService
  end
end
```

## アーキテクチャの原則

### レイヤー分離

- [ ] **ドメイン層の独立性**: ドメイン層が他の層に依存していないか
- [ ] **依存関係の方向**: 依存関係が内側（ドメイン層）に向いているか
- [ ] **技術的詳細の隔離**: データベース、フレームワーク、UIの詳細がドメイン層に漏れていないか

### 依存関係の逆転（DIP）

- [ ] **抽象への依存**: 高レベルモジュールが抽象（インターフェース）に依存しているか
- [ ] **実装の分離**: 実装がインフラストラクチャ層に配置されているか
- [ ] **テスト容易性**: インターフェースに依存することで、テストが容易になっているか

### テスト容易性

- [ ] **ドメインロジックの独立性**: ドメインロジックが独立してテストできる構造になっているか
- [ ] **モックの容易性**: リポジトリや外部サービスをモックしやすい構造になっているか
- [ ] **インメモリリポジトリ**: テスト用にインメモリリポジトリを実装できる構造になっているか

## レビュー時の質問例

### 値オブジェクトに関する質問

- この値にルール（バリデーション、ビジネスルール）が存在するか？
- この値を単独で取り扱いたいか？
- プリミティブ型の代わりに値オブジェクトを使用できないか？
- 値オブジェクトが不変になっているか？

### エンティティに関する質問

- このオブジェクトはライフサイクルがあり、時間の経過とともに状態が変わる「実体」か？
- このオブジェクトはIDで識別されるべきか？
- エンティティの中に値オブジェクトを属性として持てないか？

### リポジトリに関する質問

- 複雑なクエリロジックが散在していないか？
- データストアの詳細がドメイン層に漏れていないか？
- リポジトリパターンを使用することで、テストが容易になっているか？

### アプリケーションサービスに関する質問

- この処理はビジネスプロセスとして独立しているか？
- Service Objectが適切な粒度で実装されているか？
- トランザクション管理が適切に行われているか？

### ドメインサービスに関する質問

- この処理はエンティティや値オブジェクトに持たせられないか？
- ドメインサービスが濫用されていないか？
- ドメインサービスが「最後の手段」として使用されているか？

## 参考資料

### 書籍

- ドメイン駆動設計入門 ボトムアップでわかる! ドメイン駆動設計の基本
- エリック・エヴァンスのドメイン駆動設計

### 記事・ドキュメント

- [ドメイン駆動設計の基本概念](https://docs.microsoft.com/ja-jp/dotnet/architecture/microservices/microservice-ddd-cqrs-patterns/ddd-oriented-microservice)
- [Railsでのドメイン駆動設計](https://www.engineyard.com/blog/keeping-your-rails-controllers-dry-with-services)

### プロジェクト内の参考資料

- `input/books/技術/ドメイン駆動設計入門 ボトムアップでわかる! ドメイン駆動設計の基本_読書メモ.md`
- `input/books/技術/ドメイン駆動設計入門 ボトムアップでわかる! ドメイン駆動設計の基本.md`
