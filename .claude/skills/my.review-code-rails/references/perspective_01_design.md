---
title: 設計
impact: MEDIUM
tags: rails, review-code, design
---

<!-- markdownlint-disable MD024 -->

## 設計

ルールの詳細は以下に記載します。

## チェックリスト

### 概要

レビューで確認すべき最も大切なことは、CL の全体的な設計です。CL のコードの各部分が相互にきちんと連携するか、この変更がコードベースに属するものか（それともあるライブラリに属するものか）、システムの他の部分とうまく統合するか、この機能を追加するタイミングが今がふさわしいかを確認すること。

また、CLが必要以上に複雑になっていないか確認すること。CLのあらゆるレベルで複雑性を確認すること。一行一行は複雑すぎないか、関数は複雑すぎないか、クラスは複雑すぎないかを確認すること。「複雑すぎる」とは普通、「コードを読んですぐに理解できない」という意味です。あるいは、「開発者がこのコードを呼び出したり修正したりしようとするときに不具合を生み出す可能性がある」という意味でもあります。

**良い設計 = 低い複雑性** という関係を理解し、設計と複雑性を一体として考えることが重要です。

### レビューの基本姿勢

> **関連**: コードレビューの一般的な進め方については`README.md`の「コードレビューの進め方」を参照してください。ここでは設計視点でのレビューの基本姿勢を確認します。

#### 敬意と礼儀

コードレビューで最も重要なのは、**敬意と礼儀**です。

- [ ] **能力と善意を想定する**: 誤りは情報不足によるものと考える
- [ ] **理由を説明する**: なぜ間違っているのか、どのような変更が正しいのかを説明する
- [ ] **理由を聞く**: 相手の意図が不明確な場合は遠慮なく聞く
- [ ] **ポジティブに述べる**: 良い点を認める姿勢でレビューする
- [ ] **人を辱めない**: 極端な言葉やネガティブな表現を使わない
- [ ] **コードについて議論する**: 人ではなく、コードについて議論する

#### 設計視点でのレビュー

- [ ] **設計的な妥当性に重点を置く**: ロジック、機能要件、欠陥、コーディングスタイルだけでなく、設計的な妥当性を確認する
- [ ] **悪しき構造を見つける**: 悪しき構造を見つけて指摘する
- [ ] **改善案を具体的に提案する**: 改善案を具体的に提案する

### 基本原則

#### SOLID原則

以下の原則に従っているか確認すること：

##### 単一責任の原則（Single Responsibility Principle）

**特に重要**: 単一責任の原則は設計の基本であり、コードレビュー時に最も優先的に確認すべき原則です。クラス、メソッド、モジュールのすべてのレベルで単一責任であることを確認すること。

- [ ] **クラスの単一責任**: 1つのクラスが1つの責任のみを持っていることを確認すること。クラス名から責任が明確に推測できることを確認すること
- [ ] **変更理由の単一性**: クラスを変更する理由が1つであることを確認すること。複数の変更理由がある場合は、クラス分割を検討すること
- [ ] **メソッドの単一責任**: 1つのメソッドが1つの責任のみを持っていることを確認すること。メソッド名から処理内容が明確に推測できることを確認すること
- [ ] **モジュールの単一責任**: モジュール（Concernなど）が単一の責任のみを持っていることを確認すること
- [ ] **責任の明確性**: クラスやメソッドの責任が明確に定義されていることを確認すること。責任が曖昧な場合は、分割や再設計を検討すること
- [ ] **複数責任の検出**: クラスやメソッドが複数の責任を持っていないか確認すること。以下のサインがある場合は分割を検討すること：
  - クラス名やメソッド名に「and」や「or」が含まれている（例: `UserAndOrder`、`validateAndSave`）
  - クラスやメソッドが複数の異なる理由で変更される
  - クラスやメソッドの説明に「と」「および」などの接続詞が含まれる
  - クラスやメソッドが複数の異なる関心事を扱っている

- [ ] **オープン・クローズドの原則**: 新しい機能追加時に既存コードを修正しなくて済むことを確認すること
- [ ] **リスコフの置換原則**: 派生クラスが基底クラスの契約を守っていることを確認すること
- [ ] **インターフェース分離の原則**: モジュールが小さく、焦点が絞られていることを確認すること
- [ ] **依存性逆転の原則**: 高レベルモジュールが低レベルモジュールに直接依存していないことを確認すること

#### DRY原則

重複コードの扱いを確認すること：

- [ ] **重複排除**: 3回以上同じコードが出現していないことを確認すること
- [ ] **共通化の判断**: 重複コードは適切に共通化されていることを確認すること
- [ ] **抽象化のレベル**: 抽象化のレベルが適切であることを確認すること（過度な抽象化、不十分な抽象化を避ける）
- [ ] **共通化の適切性**: 結果と入力が同じ場合のみ共通化することを確認すること
- [ ] **共通化の判断基準**: 共通化すべきでないものを共通化していないことを確認すること

#### 複雑性の定義

以下の観点で複雑性を確認すること：

- [ ] **即座の理解**: コードを読んですぐに理解できることを確認すること
- [ ] **修正のリスク**: コードを修正しようとするときに不具合を生み出す可能性がないことを確認すること
- [ ] **認知的負荷**: コード理解に必要な認知的負荷が適切であることを確認すること
- [ ] **単純性の優先**: より単純な解決策が存在しないことを確認すること

#### オーバーエンジニアリングの回避

以下の点を確認すること：

- [ ] **現在の問題**: 現在解決する必要のある問題に焦点を当てていることを確認すること。代わりに、将来の要件を想定した実装を避けること
- [ ] **不要な一般化**: 必要以上にコードを一般化していないことを確認すること。代わりに、現在必要な機能のみを実装すること
- [ ] **不要な機能**: まだ必要のない機能を盛り込んでいないことを確認すること。代わりに、YAGNI原則に従い、必要な機能のみを実装すること
- [ ] **YAGNI原則**: You Aren't Gonna Need Itの原則に従っていることを確認すること
- [ ] **先回り実装の回避**: 今は必要ない機能を先回りして実装していないことを確認すること

### 設計の実践技法

#### データクラスの問題

データクラスに以下の問題がないか確認し、改善を提案すること：

- [ ] **直接変更の防止**: `attr_accessor`で直接変更可能になっていないか確認し、`attr_reader`に変更できないか検討すること
- [ ] **不正値の混入防止**: 不正値の混入を防ぐバリデーションが実装されているか確認し、コンストラクタでバリデーションを実装することを提案すること
- [ ] **未初期化状態の防止**: 未初期化状態を防ぐコンストラクタが実装されているか確認し、全てのフィールドを初期化するコンストラクタを実装することを提案すること
- [ ] **データとロジックの結合**: データとロジックが分離されていないか確認し、計算ロジックをクラス内に集約することを提案すること
- [ ] **重複コードの排除**: 重複コードがないか確認し、ロジックをクラス内に集約して重複を排除することを提案すること

#### 命名と変数の扱い

> **関連**: 命名規則の詳細については`perspective_05_naming.md`を参照してください。ここでは設計の実践技法として、命名の設計的な観点を確認します。

命名と変数の扱いを確認すること：

- [ ] **意図が伝わる名前**: 変数名が短すぎて意図が伝わらない（`d`, `p1`など）場合、意図が伝わる名前に変更することを提案すること
- [ ] **目的駆動の命名**: クラス名、メソッド名が目的を明確に表現しているか確認し、目的駆動で名前を選ぶことを提案すること
- [ ] **変数の再代入**: 変数に何度も値を代入していないか確認し、目的ごとの変数を用意することを提案すること
- [ ] **目的の一貫性**: 変数の目的が途中で変わっていないか確認し、各変数が1つの目的のみを持つようにすることを提案すること

#### メソッド化とカプセル化

メソッド化とカプセル化を確認すること：

- [ ] **長い処理の分割**: 長い処理がメソッド化されていないか確認し、目的ごとのまとまりでメソッド化することを提案すること
- [ ] **計算ロジックの集約**: 細かい計算ロジックがメソッドに閉じ込められているか確認し、計算ロジックをメソッドに抽出することを提案すること
- [ ] **データとロジックの結合**: データとロジックがバラバラになっていないか確認し、データとロジックをまとめることを提案すること
- [ ] **クラス設計**: フィールドとメソッドの両方を持つクラス設計になっているか確認し、クラスにフィールドとメソッドの両方を持たせることを提案すること

#### 完全コンストラクタと値オブジェクト

> **関連**: 値オブジェクトのDDDパターンとしての詳細については`pattern_06_ddd.md`を参照してください。ここでは設計の実践技法として、値オブジェクトパターンの適用を確認します。

完全コンストラクタと値オブジェクトを確認すること：

- [ ] **完全コンストラクタの実装**: 全てのインスタンス変数を初期化できる引数を持つコンストラクタがあるか確認し、完全コンストラクタを実装することを提案すること
- [ ] **ガード節によるバリデーション**: ガード節で不正な値を弾いているか。代わりに、コンストラクタでバリデーションを実装すること
- [ ] **不変性の確保**: 不変性で生成後に不正状態に陥ることを防止しているか。代わりに、不変性を確保すること
- [ ] **ロジックの配置**: 計算ロジックがデータ保持側に寄せられているか。代わりに、計算ロジックをデータ保持側に移動すること
- [ ] **値オブジェクトパターン**: 値オブジェクトパターンが適用できるか。代わりに、金額、日付、注文数などを値オブジェクトとして表現すること
- [ ] **制約条件の実装**: 値の制約条件がコンストラクタに実装されているか。代わりに、コンストラクタで制約条件をチェックすること

#### 不変性

不変性を確認すること：

- [ ] **再代入の回避**: 再代入が発生していないか確認し、不変性で不変にすることを提案すること
- [ ] **引数の不変性**: 引数が不変になっているか。代わりに、引数を不変にすること
- [ ] **可変インスタンスの回避**: 可変インスタンスを使い回していないか。代わりに、不変インスタンスを使用すること

#### プリミティブ型執着とstaticメソッド

プリミティブ型執着とstaticメソッドを確認すること：

- [ ] **プリミティブ型の回避**: プリミティブ型（`int`, `String`など）に固執していないか確認し、値オブジェクトパターンを適用することを提案すること
- [ ] **インスタンスメソッドの使用**: インスタンスメソッドのフリをしたstaticメソッドになっていないか。代わりに、インスタンスメソッドとして実装すること
- [ ] **staticメソッドの適切な使用**: staticメソッドを使うべき適切な場面か。代わりに、ユーティリティ関数など、適切な場面でのみ使用すること
- [ ] **初期化ロジックの集約**: 初期化ロジックが分散していないか。代わりに、コンストラクタで確実に正常値を設定すること

#### 関心の分離

関心の分離を確認すること（単一責任の原則の実践）：

- [ ] **目的の分離（単一責任の確認）**: 異なる目的が混在していないか確認し、目的ごとにクラスを分割することを提案すること。各クラスが単一の責任を持つようにすること
- [ ] **変数の分離**: 変数を使い回していないか。代わりに、目的ごとの変数を用意すること。各変数が単一の目的のみを持つようにすること
- [ ] **メソッドの分離（単一責任の確認）**: 目的ごとのまとまりでメソッド化できているか。代わりに、目的ごとにメソッドを分割すること。各メソッドが単一の責任を持つようにすること
- [ ] **依存関係の管理**: 依存関係が適切に管理されているか。代わりに、依存関係を明確にすること
- [ ] **循環依存の回避**: 依存関係が循環していないか。代わりに、循環依存を解消すること

#### 継承と委譲

継承と委譲を確認すること：

- [ ] **委譲の検討**: 継承より委譲（コンポジション）を使えないか確認し、委譲パターンを検討することを提案すること
- [ ] **スーパークラス依存の回避**: スーパークラス依存が発生していないか。代わりに、依存関係を見直すこと
- [ ] **悪しき共通化の回避**: 継承による悪しき共通化が発生していないか。代わりに、適切な共通化方法を検討すること

#### 条件分岐の整理

条件分岐の整理を確認すること：

- [ ] **ネストの解消**: 条件分岐のネストが深くないか確認し、早期return（ガード節）でネストを解消することを提案すること
- [ ] **else句の削除**: `else`句が不要になっていないか。代わりに、早期returnで`else`句を削除すること
- [ ] **switch文の重複回避**: `switch`文が重複していないか。代わりに、`interface`を使って機能を取り換える（ストラテジパターン）こと
- [ ] **条件分岐の集約**: 条件分岐を一箇所にまとめられないか。代わりに、条件分岐を集約すること
- [ ] **フラグ引数の回避**: フラグ引数が使われていないか。代わりに、メソッドを分離する、またはストラテジパターンを使用すること
- [ ] **interface設計**: 機能を取り換える単位が明確か。代わりに、取り換える単位を明確にすること

#### コレクションの扱い

コレクションの扱いを確認すること：

- [ ] **標準ライブラリの活用**: 標準ライブラリの機能を活用できているか確認し、標準ライブラリの機能を優先的に使用することを提案すること
- [ ] **自前実装の回避**: 自前で実装する必要がないか。代わりに、標準ライブラリに同等の機能がないか確認すること
- [ ] **continueの使用**: `continue`でループ処理中の条件分岐ネストを解消できないか。代わりに、`continue`を使用すること
- [ ] **breakの使用**: `break`でネストを解消できないか。代わりに、`break`を使用すること
- [ ] **コレクション処理のカプセル化**: コレクション処理がカプセル化されているか。代わりに、コレクション処理をクラスに集約すること
- [ ] **外部への不変な提供**: 外部へ渡す場合、コレクションを変更できなくしているか。代わりに、コピーを返すなどして不変にすること

#### 設計の健全性

設計の健全性を確認すること：

- [ ] **デッドコードの削除**: デッドコード（到達不能なコード）が残っていないか確認し、見つけ次第削除することを提案すること
- [ ] **マジックナンバー**: マジックナンバーが定数に置き換えられているか。代わりに、定数として定義すること
- [ ] **グローバル変数の回避**: グローバル変数が使われていないか。代わりに、どうしても必要な場合以外は定義しないこと
- [ ] **null問題**: `null`を返さない、渡さない、代入しない設計になっているか。代わりに、`null`を許容しない設計にすること
- [ ] **文字列型執着の回避**: 目的の異なる複数の値を、単一の`String`変数に詰め込んでいないか。代わりに、値オブジェクトパターンを適用すること
- [ ] **例外の適切な処理**: 例外が適切に処理されているか。代わりに、例外を適切に処理すること
- [ ] **例外の握り潰し回避**: 例外を握り潰していないか。代わりに、例外を握り潰さないこと
- [ ] **メタプログラミングの適切な使用**: メタプログラミングが適切に使われているか。代わりに、適切な場面でのみ使用すること
- [ ] **技術駆動パッケージング**: パッケージ構造が技術ではなく、ドメインで整理されているか。代わりに、ドメインで整理すること

#### 名前設計

> **関連**: 命名規則の詳細については`perspective_05_naming.md`を参照してください。ここでは設計の実践技法として、名前設計の観点を確認します。

名前設計を確認すること：

- [ ] **目的の明確な表現**: 名前が目的を明確に表現しているか確認し、目的を表現する名前を使うことを提案すること
- [ ] **意味の明確性**: 大雑把で意味が不明瞭な名前になっていないか。代わりに、具体的で意味が明確な名前を使うこと
- [ ] **目的駆動の命名**: 存在駆動ではなく、目的駆動で名前が選ばれているか。代わりに、目的駆動で名前を選ぶこと
- [ ] **名前の再検討**: 違う名前に置き換えられないか検討できているか。代わりに、より適切な名前を検討すること

### デザインパターン

#### パターン適用の判断基準

パターン適用の判断基準を確認すること：

- [ ] **問題の明確化**: 解決しようとしている問題が明確であることを確認すること
- [ ] **パターンの適切性**: 選択したパターンが問題に適していることを確認すること
- [ ] **過度な抽象化の回避**: 必要以上に複雑になっていないことを確認すること
- [ ] **可読性の維持**: パターン適用により可読性が向上していることを確認すること
- [ ] **保守性の向上**: パターン適用により保守性が向上していることを確認すること

#### 生成に関するパターン（Creational Patterns）

生成に関するパターンの適用を確認すること：

- [ ] **Factory Method**: オブジェクト生成をサブクラスに委譲していることを確認すること
- [ ] **Abstract Factory**: 関連する複数のオブジェクトを生成していることを確認すること
- [ ] **Builder**: オブジェクトを段階的に構築していることを確認すること
- [ ] **Singleton**: インスタンスが1つだけ存在することを保証していることを確認すること（慎重に使用）
- [ ] **Prototype**: 既存のオブジェクトを複製して新しいオブジェクトを作成していることを確認すること

#### 構造に関するパターン（Structural Patterns）

構造に関するパターンの適用を確認すること：

- [ ] **Adapter**: 既存のクラスのインターフェースを別のインターフェースに変換していることを確認すること
- [ ] **Bridge**: 実装と抽象を分離していることを確認すること
- [ ] **Composite**: 部分と全体を同じように扱えることを確認すること
- [ ] **Decorator**: 実行時に機能を追加していることを確認すること
- [ ] **Facade**: 複雑なサブシステムを簡潔なインターフェースで提供していることを確認すること
- [ ] **Flyweight**: 共有可能な状態を共有していることを確認すること
- [ ] **Proxy**: オブジェクトへのアクセスを制御していることを確認すること

#### 振る舞いに関するパターン（Behavioral Patterns）

振る舞いに関するパターンの適用を確認すること：

- [ ] **Chain of Responsibility**: 要求を連鎖的に処理していることを確認すること
- [ ] **Command**: 要求をオブジェクトとして表現していることを確認すること
- [ ] **Iterator**: 反復処理を抽象化していることを確認すること
- [ ] **Mediator**: オブジェクト間の通信を仲介していることを確認すること
- [ ] **Observer**: 状態変化をオブザーバーに通知していることを確認すること
- [ ] **State**: 状態をオブジェクトとして表現していることを確認すること
- [ ] **Strategy**: アルゴリズムを交換できることを確認すること
- [ ] **Template Method**: 処理の骨組みを定義していることを確認すること
- [ ] **Visitor**: データ構造と操作を分離していることを確認すること

#### Railsでのデザインパターン適用

Railsでのデザインパターン適用を確認すること：

- [ ] **Service Object（Command）**: ビジネスロジックをService Objectに分離していることを確認すること
- [ ] **Form Object（Adapter）**: 複数のモデルを統合していることを確認すること
- [ ] **Query Object（Strategy）**: クエリロジックを分離していることを確認すること
- [ ] **Policy Object（Strategy）**: 認可ロジックを分離していることを確認すること
- [ ] **Presenter/Decorator**: 表示ロジックを分離していることを確認すること
- [ ] **Value Object**: Value Objectが不変であることを確認すること

#### パターン適用の注意点

パターン適用の注意点を確認すること：

- [ ] **必要十分な抽象化**: 必要以上に抽象化していないことを確認すること
- [ ] **可読性の維持**: パターン適用により可読性が低下していないことを確認すること
- [ ] **適切な組み合わせ**: パターンを適切に組み合わせていることを確認すること
- [ ] **パターンの誤用**: より簡単な解決方法がないか検討していることを確認すること

### レイヤー構造

#### 標準MVC層

標準MVC層の適切な使用を確認すること：

- [ ] **Controller**: リクエスト/レスポンス処理のみを行っていることを確認すること（Skinny Controller）
- [ ] **Model**: データとビジネスルールのみを持っていることを確認すること（Fat Modelの回避）
- [ ] **View**: ビジネスロジックが含まれていないことを確認すること

#### 追加レイヤーの判断

追加レイヤーの適切な使用を確認すること：

- [ ] **Service層**: 複雑なビジネスロジックはService層に分離されていることを確認すること
- [ ] **Form Object**: 複数モデルにまたがるフォーム処理はForm Objectを使用していることを確認すること
- [ ] **Query Object**: 複雑なクエリはQuery Objectまたはscopeに分離されていることを確認すること
- [ ] **Presenter/Decorator**: プレゼンテーション層のロジックはPresenter/Decoratorに分離されていることを確認すること
- [ ] **Policy Object**: 複雑な認可ロジックはPolicy Objectに分離されていることを確認すること
- [ ] **Value Object**: ドメイン概念はValue Objectで表現されていることを確認すること
- [ ] **Serializer**: API レスポンスはSerializerで整形されていることを確認すること
- [ ] **Builder**: 複雑なオブジェクト生成はBuilderで抽象化されていることを確認すること
- [ ] **Repository**: データアクセス層はRepositoryで抽象化されていることを確認すること
- [ ] **Job/Worker**: 非同期処理はJob/Workerで実装されていることを確認すること
- [ ] **Concern**: 横断的関心事はConcernで共通化されていることを確認すること

### レイヤー選択の判断基準

#### Service層を使うべき時

> **関連**: Service Objectの命名については`perspective_05_naming.md`の「Service Objectの命名」を、DDDでのService Objectについては`pattern_06_ddd.md`の「アプリケーションサービス」を参照してください。ここではレイヤー選択の判断基準として確認します。

- [ ] 3つ以上の異なる処理（トランザクション）が必要
- [ ] 複数のモデルを協調させる必要がある
- [ ] 外部API呼び出しが含まれる
- [ ] 同じビジネスロジックを複数箇所で使用する
- [ ] 複雑なエラーハンドリングが必要（技術的例外とビジネス例外の使い分け）
- [ ] 統一された戻り値（Result型）が必要

#### Form Objectを使うべき時

- [ ] 3つ以上のモデルを同時に作成・更新する
- [ ] データベースに保存しない一時的なフォーム
- [ ] 複雑なバリデーションロジックが必要

#### Query Objectを使うべき時

- [ ] 5つ以上の条件が必要
- [ ] 動的に条件を組み立てる必要がある
- [ ] 複数のControllerで同じクエリを使用する
- [ ] scopeのチェーンが5つ以上になる

#### Presenter/Decoratorを使うべき時

- [ ] View内のロジックが10行以上になる
- [ ] 同じ表示ロジックを複数のViewで使用する
- [ ] Modelに表示用のメソッドを追加したくない

#### Policy Objectを使うべき時

- [ ] 認可ロジックが複雑
- [ ] 複数のControllerで同じ認可ロジックを使用する
- [ ] 権限チェックが複雑

#### Value Objectを使うべき時

- [ ] ドメイン概念を表現する値
- [ ] 不変である必要がある
- [ ] ビジネスルールを含む

#### Serializerを使うべき時

- [ ] API レスポンスを整形する必要がある
- [ ] 複雑なJSON構造が必要
- [ ] レスポンス形式を統一したい

#### Builderを使うべき時

- [ ] 複雑なオブジェクト生成が必要
- [ ] 段階的なオブジェクト構築が必要
- [ ] オブジェクト生成を抽象化したい

#### Repositoryを使うべき時

- [ ] データアクセス層を抽象化したい
- [ ] 複雑なクエリを集約したい
- [ ] データソースを切り替える可能性がある

#### Job/Workerを使うべき時

- [ ] 非同期で処理したい
- [ ] 重い処理がある
- [ ] バックグラウンドで処理したい

#### Concernを使うべき時

- [ ] 複数のモデルで同じ機能を使用する
- [ ] 横断的な関心事を共通化したい
- [ ] 機能を再利用したい

### Rails特有の設計

> **関連**: トランザクションの機能性については`perspective_01_design.md`の「並行処理の安全性」を、DDDでのトランザクション管理については`pattern_06_ddd.md`の「アプリケーションサービス」を参照してください。ここでは設計の観点からトランザクション設計を確認します。

#### トランザクション設計

トランザクション設計を確認すること：

- [ ] **トランザクション境界**: ビジネストランザクション単位で適切に設定されていることを確認すること
- [ ] **ロック戦略**: 楽観的/悲観的ロックが適切に選択されていることを確認すること
- [ ] **ネスト管理**: トランザクションのネストが適切に管理されていることを確認すること

#### エラーハンドリング設計

> **関連**: エラーハンドリングの機能性については`perspective_01_design.md`の「異常系の処理」を、DDDでのエラーハンドリングについては`pattern_06_ddd.md`の「アプリケーションサービス」を参照してください。ここでは設計の観点からエラーハンドリング設計を確認します。

エラーハンドリング設計を確認すること：

- [ ] **例外の区別**: 技術的例外とビジネス例外が適切に区別されていることを確認すること
- [ ] **処理の分離**: 各層で適切なエラー処理が実装されていることを確認すること
- [ ] **ログ出力**: エラーログが適切に出力されていることを確認すること

##### Service層のエラーハンドリング

Service層のエラーハンドリングを確認すること：

- [ ] **技術的例外**: データベースエラー、外部APIエラー、システムエラーはraiseしていることを確認すること
- [ ] **ビジネス例外**: バリデーションエラー、権限エラー、ビジネスルール違反はResult型で返していることを確認すること
- [ ] **Result型の統一**: Service層の戻り値が統一されたResult型を使用していることを確認すること
- [ ] **例外の変換**: 技術的例外をビジネス例外に適切に変換していることを確認すること
- [ ] **Controller連携**: Controller層でのエラー処理が適切に設計されていることを確認すること

##### エラーハンドリングの使い分け

エラーハンドリングの使い分けを確認すること：

- [ ] **Service層**: rescueを使用してエラーを適切に処理し、Result型で返していることを確認すること
- [ ] **Controller層**: rescue_fromを使用して統一的なエラーレスポンスを提供していることを確認すること
- [ ] **責務の分離**: 各層で適切なエラーハンドリング方法を使用していることを確認すること
- [ ] **重複排除**: 同じエラー処理が複数箇所で重複していないことを確認すること

#### 依存関係設計

依存関係設計を確認すること：

- [ ] **循環依存**: クラス間の循環依存がないことを確認すること
- [ ] **依存方向**: 依存関係が一方向になっていることを確認すること
- [ ] **依存性注入**: 依存性注入が適切に使われていることを確認すること

#### データ整合性設計

データ整合性設計を確認すること：

- [ ] **制約の使い分け**: DB制約とアプリケーション制約が適切に使い分けられていることを確認すること
- [ ] **バリデーション戦略**: バリデーション戦略が適切に設計されていることを確認すること
- [ ] **整合性保証**: データの整合性が保たれていることを確認すること

#### スケーラビリティ設計

スケーラビリティ設計を確認すること：

- [ ] **非同期処理**: 非同期処理が適切に選択されていることを確認すること
- [ ] **キャッシュ戦略**: キャッシュ戦略が適切に設計されていることを確認すること
- [ ] **パフォーマンス**: パフォーマンスが考慮されていることを確認すること

#### コールバック vs 明示的処理

コールバックと明示的処理の使い分けを確認すること：

- [ ] **使い分け**: コールバックと明示的処理が適切に使い分けられていることを確認すること
- [ ] **複雑なロジック**: 複雑なビジネスロジックは明示的に処理されていることを確認すること
- [ ] **テスタビリティ**: テストのしやすさが考慮されていることを確認すること

##### コールバックを使うべき時

- [ ] シンプルで必ず必要な処理
- [ ] 副作用が少ない処理
- [ ] 例: `before_save :normalize_email`, `after_commit :clear_cache`

##### 明示的処理（Service）を使うべき時

- [ ] 複雑なビジネスロジック
- [ ] 複数の副作用がある処理
- [ ] 条件によって実行が変わる処理
- [ ] テストで分離したい処理

### 総合チェック

#### 設計の基本原則

- [ ] **単一責任の原則（最重要）**: クラス、メソッド、モジュールのすべてのレベルで単一責任であることを確認すること。複数の責任がある場合は分割を検討すること
- [ ] **名前設計**: 目的駆動で名前を選び、構造を見破る
- [ ] **カプセル化**: データとロジックをまとめ、不変を活用
- [ ] **関心の分離**: 異なる目的を分けて整理
- [ ] **条件分岐の整理**: 早期return、interface設計でシンプルに
- [ ] **リファクタリング**: 動くコードを書いたら設計し直す

#### デザインパターン適用の判断

- [ ] **問題の明確化**: 解決しようとしている問題が明確であることを確認すること
- [ ] **パターンの適切性**: 選択したパターンが問題に適していることを確認すること
- [ ] **可読性の向上**: パターン適用により可読性が向上していることを確認すること
- [ ] **保守性の向上**: パターン適用により保守性が向上していることを確認すること
- [ ] **テスト容易性**: パターン適用によりテストしやすくなっていることを確認すること

#### コードレビューの観点

- [ ] **設計視点でのレビュー**: 設計視点でレビューできていることを確認すること
- [ ] **悪しき構造の発見**: 悪しき構造を見つけて指摘できていることを確認すること
- [ ] **改善案の提案**: 改善案を具体的に提案できていることを確認すること
- [ ] **パターン適用の妥当性**: パターンが適切に適用されていることを確認すること
- [ ] **パターンの誤用**: パターンが誤用されていないことを確認すること

### レビュー時の質問例

#### 全体設計

- [ ] この変更は、どのレイヤーに属するべきか？
- [ ] この機能は、既存のアーキテクチャに適合しているか？
- [ ] コードの各部分は相互にきちんと連携するか？
- [ ] コードの健康状態を改善しているか、悪化させていないか？

#### レイヤー選択

- [ ] この処理は、どのレイヤーで実装すべきか？
- [ ] 複雑なビジネスロジックはService層に分離されているか？
- [ ] 複数モデルにまたがる処理はForm Objectを使用しているか？

#### 複雑性

- [ ] この行は一度読んで理解できるか？
- [ ] このメソッドは何をしているか一目で分かるか？
- [ ] **このメソッドは単一の責任を持っているか？（重要）**: メソッドが1つの目的のみを達成しているか？複数の責任がある場合は分割を検討すること
- [ ] このメソッドのネストは深すぎないか？
- [ ] **このクラスは単一の責任を持っているか？（最重要）**: クラスが1つの責任のみを持っているか？クラス名から責任が明確に推測できるか？複数の責任がある場合は分割を検討すること
- [ ] このクラスは大きすぎないか？
- [ ] この条件分岐は必要か？ガード節で早期リターンできないか？
- [ ] ポリモーフィズムで置き換えられないか？

#### オーバーエンジニアリング

- [ ] この機能は今すぐ必要か？
- [ ] この一般化は本当に必要か？
- [ ] よりシンプルな解決策はないか？
- [ ] YAGNI（You Aren't Gonna Need It）に違反していないか？

#### Rails特有の設計

- [ ] トランザクション境界は適切に設定されているか？
- [ ] エラーハンドリングは適切に設計されているか？
- [ ] 依存関係は適切に管理されているか？
- [ ] 技術的例外とビジネス例外が適切に使い分けられているか？

#### デザインパターン

- [ ] このパターンは本当に必要か？
- [ ] より簡単な解決方法がないか？
- [ ] パターン適用により可読性が向上しているか？
- [ ] パターン適用により保守性が向上しているか？

### 参考資料

- 改訂新版 良いコード/悪いコードで学ぶ設計入門
- `input/books/技術/改訂新版 良いコード悪いコードで学ぶ設計入門.md`
- `input/books/技術/改訂新版 良いコード悪いコードで学ぶ設計入門_読書メモ.md`
- Java言語で学ぶデザインパターン入門
- `input/books/技術/Java言語で学ぶデザインパターン入門.md`
- `input/books/技術/Java言語で学ぶデザインパターン入門_読書メモ.md`
- GoFのデザインパターン（Gang of Four Design Patterns）

## 詳細解説

ルールの詳細は以下に記載します。

レビューで確認すべき最も大切なことは、CL の全体的な設計です。 CL のコードの各部分は相互にきちんと連携するでしょうか？この変更はコードベースに属するものでしょうか、それともあるライブラリに属するものでしょうか？システムの他の部分とうまく統合するでしょうか？この機能を追加するタイミングは今がふさわしいでしょうか？

### 概要

このドキュメントでは、Railsアプリケーションの設計レビューで確認すべき重要なポイントについて、理由と具体例を詳しく解説します。チェックリストと併せて使用することで、より深い理解と実践的な設計判断が可能になります。

### 目次

1. [基本原則の詳細解説](#基本原則の詳細解説)
2. [レイヤー構造の詳細解説](#レイヤー構造の詳細解説)
3. [Rails特有の設計の詳細解説](#rails特有の設計の詳細解説)
4. [レイヤー選択の判断基準](#レイヤー選択の判断基準)
5. [コールバック vs 明示的処理の判断](#コールバック-vs-明示的処理の判断)
6. [実践的な設計判断例](#実践的な設計判断例)

---

### 基本原則の詳細解説

#### SOLID原則

##### 1. 単一責任の原則（SRP: Single Responsibility Principle）

**なぜ重要なのか：**

- 1つのクラスが複数の責任を持つと、変更理由が複数になり、保守性が低下する
- テストが困難になり、バグが発生しやすくなる
- コードの理解が困難になる

**Railsでの具体例：**

```ruby
## ❌ 悪い例：複数の責任を持つController
class UsersController < ApplicationController
  def create
    @user = User.new(user_params)

    # バリデーション（Modelの責任）
    if @user.valid?
      # 保存（Modelの責任）
      @user.save
      # メール送信（Serviceの責任）
      UserMailer.welcome(@user).deliver_now
      # 統計更新（Serviceの責任）
      Statistics.increment_user_count
      # 通知（Serviceの責任）
      SlackNotifier.notify("New user: #{@user.email}")
    end
  end
end

## 問題点：
## 1. Controllerが複数の責任を持っている
## 2. テストが困難（メール送信やSlack通知が毎回実行される）
## 3. 管理画面でユーザー作成時もメールが送信される
## 4. 変更理由が複数（バリデーション、保存、メール、統計、通知）
```

```ruby
## ✅ 良い例：単一責任
class UsersController < ApplicationController
  def create
    result = Users::CreateUserService.call(user_params)

    if result.success?
      redirect_to result.data, notice: "User created successfully."
    else
      @user = result.data
      render :new
    end
  end
end

## app/services/users/create_user_service.rb
module Users
  class CreateUserService
    def self.call(params)
      new(params).call
    end

    def initialize(params)
      @params = params
    end

    def call
      user = User.new(@params)

      return Result.error(data: user, errors: user.errors.full_messages) unless user.valid?

      ActiveRecord::Base.transaction do
        user.save!
        send_welcome_email(user)
        update_statistics
        notify_slack(user)
      end

      Result.success(data: user)
    rescue => e
      Rails.logger.error "User creation failed: #{e.message}"
      Result.error(data: user, errors: [e.message])
    end

    private

    def send_welcome_email(user)
      UserMailer.welcome(user).deliver_later
    end

    def update_statistics
      Statistics.increment_user_count
    end

    def notify_slack(user)
      SlackNotifier.notify("New user: #{user.email}")
    end
  end
end

## 改善点：
## 1. Controllerはリクエスト/レスポンス処理のみ
## 2. ビジネスロジックはService層に分離
## 3. テストが容易（Service層をモック可能）
## 4. 管理画面では別のServiceを使用可能
```

##### 2. オープン・クローズドの原則（OCP: Open-Closed Principle）

**なぜ重要なのか：**

- 新しい機能を追加する際、既存コードを修正しなくて済む
- バグの発生リスクを減らす
- システムの安定性を保つ

**Railsでの具体例：**

```ruby
## ❌ 悪い例：新しい支払い方法を追加するたびに修正が必要
class PaymentProcessor
  def process(payment_type, amount)
    case payment_type
    when :credit_card
      process_credit_card(amount)
    when :bank_transfer
      process_bank_transfer(amount)
    when :paypal
      process_paypal(amount)
    # 新しい支払い方法が追加されるたびに修正が必要
    end
  end

  private

  def process_credit_card(amount)
    # クレジットカード処理
  end

  def process_bank_transfer(amount)
    # 銀行振込処理
  end

  def process_paypal(amount)
    # PayPal処理
  end
end

## 問題点：
## 1. 新しい支払い方法を追加するたびに修正が必要
## 2. 既存の支払い方法に影響する可能性
## 3. テストが複雑になる
```

```ruby
## ✅ 良い例：Strategyパターンで拡張に開いて修正に閉じている
class PaymentProcessor
  def initialize(strategy)
    @strategy = strategy
  end

  def process(amount)
    @strategy.process(amount)
  end
end

## 各支払い方法の実装
class CreditCardPayment
  def process(amount)
    # クレジットカード処理
    puts "Processing credit card payment: #{amount}"
  end
end

class BankTransferPayment
  def process(amount)
    # 銀行振込処理
    puts "Processing bank transfer: #{amount}"
  end
end

class PayPalPayment
  def process(amount)
    # PayPal処理
    puts "Processing PayPal payment: #{amount}"
  end
end

## 新しい支払い方法を追加（既存コードを変更せず）
class BitcoinPayment
  def process(amount)
    puts "Processing Bitcoin payment: #{amount}"
  end
end

## 使用例
processor = PaymentProcessor.new(CreditCardPayment.new)
processor.process(1000)

## 改善点：
## 1. 新しい支払い方法を追加しても既存コードを変更しない
## 2. 各支払い方法が独立してテスト可能
## 3. 既存の支払い方法に影響しない
```

##### 3. リスコフの置換原則（LSP: Liskov Substitution Principle）

**なぜ重要なのか：**

- 派生クラスが基底クラスの契約を守ることで、ポリモーフィズムが正しく動作する
- 予期しない動作やバグを防ぐ
- コードの信頼性を高める

**Railsでの具体例：**

```ruby
## ❌ 悪い例：派生クラスが基底クラスの契約を破る
class Bird
  def fly
    puts "Flying"
  end
end

class Penguin < Bird
  def fly
    raise "Penguins can't fly!"  # 基底クラスの契約を破る
  end
end

def make_bird_fly(bird)
  bird.fly  # Penguinを渡すと例外が発生
end

## 問題点：
## 1. PenguinをBirdとして扱えない
## 2. ポリモーフィズムが正しく動作しない
## 3. 予期しない例外が発生する
```

```ruby
## ✅ 良い例：適切な抽象化
class Bird
  def move
    raise NotImplementedError
  end
end

class FlyingBird < Bird
  def move
    fly
  end

  private

  def fly
    puts "Flying"
  end
end

class SwimmingBird < Bird
  def move
    swim
  end

  private

  def swim
    puts "Swimming"
  end
end

class Sparrow < FlyingBird
end

class Penguin < SwimmingBird
end

def make_bird_move(bird)
  bird.move  # どの鳥でも動作する
end

## 改善点：
## 1. 派生クラスが基底クラスの契約を守る
## 2. ポリモーフィズムが正しく動作する
## 3. 予期しない例外が発生しない
```

##### 4. インターフェース分離の原則（ISP: Interface Segregation Principle）

**なぜ重要なのか：**

- クライアントが使わないメソッドに依存しない
- インターフェースが小さく、焦点が絞られている
- 変更の影響を局所化できる

**Railsでの具体例：**

```ruby
## ❌ 悪い例：巨大なインターフェース
module Worker
  def work
    raise NotImplementedError
  end

  def eat
    raise NotImplementedError
  end

  def sleep
    raise NotImplementedError
  end

  def get_paid
    raise NotImplementedError
  end
end

class Robot
  include Worker

  def work
    puts "Working"
  end

  # ロボットは食べない、寝ない
  def eat
    raise "Robots don't eat"
  end

  def sleep
    raise "Robots don't sleep"
  end

  def get_paid
    raise "Robots don't get paid"
  end
end

## 問題点：
## 1. Robotが使わないメソッドを実装している
## 2. 例外を投げて処理を拒否している
## 3. インターフェースが大きすぎる
```

```ruby
## ✅ 良い例：小さなインターフェースに分割
module Workable
  def work
    raise NotImplementedError
  end
end

module Eatable
  def eat
    raise NotImplementedError
  end
end

module Sleepable
  def sleep
    raise NotImplementedError
  end
end

module Payable
  def get_paid
    raise NotImplementedError
  end
end

class Human
  include Workable
  include Eatable
  include Sleepable
  include Payable

  def work
    puts "Working"
  end

  def eat
    puts "Eating"
  end

  def sleep
    puts "Sleeping"
  end

  def get_paid
    puts "Getting paid"
  end
end

class Robot
  include Workable

  def work
    puts "Working"
  end
end

## 改善点：
## 1. 各インターフェースが小さく、焦点が絞られている
## 2. Robotは必要なインターフェースのみを実装
## 3. 使わないメソッドで例外を投げない
```

##### 5. 依存性逆転の原則（DIP: Dependency Inversion Principle）

**なぜ重要なのか：**

- 高レベルモジュールが低レベルモジュールに直接依存しない
- 抽象に依存することで、実装の詳細に依存しない
- テストが容易になり、保守性が向上する

**Railsでの具体例：**

```ruby
## ❌ 悪い例：高レベルモジュールが低レベルモジュールに直接依存
class UserService
  def create_user(params)
    user = User.create(params)

    # MySQLRepositoryに直接依存
    MySQLUserRepository.new.save(user)

    # SendGridMailerに直接依存
    SendGridMailer.new.send_welcome_email(user)

    user
  end
end

## 問題点：
## 1. 高レベルモジュールが低レベルモジュールに直接依存
## 2. テスト時にモックやスタブに差し替え困難
## 3. 実装の詳細に依存している
```

```ruby
## ✅ 良い例：抽象に依存
class UserService
  def initialize(repository: UserRepository.new, mailer: UserMailer.new)
    @repository = repository
    @mailer = mailer
  end

  def create_user(params)
    user = User.new(params)

    # 抽象（インターフェース）に依存
    @repository.save(user)
    @mailer.send_welcome_email(user)

    user
  end
end

## リポジトリの抽象
class UserRepository
  def save(user)
    # デフォルト実装（MySQLなど）
  end
end

## 異なる実装に簡単に差し替え可能
class PostgreSQLUserRepository < UserRepository
  def save(user)
    # PostgreSQL実装
  end
end

## テスト用の実装
class InMemoryUserRepository < UserRepository
  def initialize
    @users = []
  end

  def save(user)
    @users << user
  end
end

## 使用例：本番環境
service = UserService.new(
  repository: PostgreSQLUserRepository.new,
  mailer: SendGridMailer.new
)

## テスト環境
service = UserService.new(
  repository: InMemoryUserRepository.new,
  mailer: MockMailer.new
)

## 改善点：
## 1. 高レベルモジュールが抽象に依存
## 2. テスト時にモックやスタブに差し替え容易
## 3. 実装の詳細に依存しない
```

#### DRY原則・複雑度

##### DRY原則（Don't Repeat Yourself）

**なぜ重要なのか：**

- コードの重複は保守性を低下させる
- バグの修正時に複数箇所を修正する必要がある
- 一貫性の維持が困難になる

**Railsでの具体例：**

```ruby
## ❌ 悪い例：重複したコード
class UserReport
  def admin_report
    users = User.where(role: 'admin')
    users.map { |u| { name: u.name, email: u.email, created_at: u.created_at } }
  end

  def member_report
    users = User.where(role: 'member')
    users.map { |u| { name: u.name, email: u.email, created_at: u.created_at } }
  end

  def guest_report
    users = User.where(role: 'guest')
    users.map { |u| { name: u.name, email: u.email, created_at: u.created_at } }
  end
end

## 問題点：
## 1. 同じコードが3回出現している
## 2. 修正時に3箇所を修正する必要がある
## 3. 一貫性の維持が困難
```

```ruby
## ✅ 良い例：共通化
class UserReport
  def generate(role)
    User.where(role: role).map(&method(:format_user))
  end

  private

  def format_user(user)
    {
      name: user.name,
      email: user.email,
      created_at: user.created_at
    }
  end
end

## 改善点：
## 1. 重複を排除
## 2. 修正時に1箇所のみ修正すればよい
## 3. 一貫性の維持が容易
```

##### コードの複雑度

**なぜ重要なのか：**

- 複雑なコードは理解が困難
- バグが発生しやすくなる
- テストが困難になる

**メソッドの長さ：**

```ruby
## ❌ 悪い例：50行以上のメソッド
def process_order
  # ... 50行のコード
end

## 問題点：
## 1. 理解が困難
## 2. バグが発生しやすい
## 3. テストが困難
```

```ruby
## ✅ 良い例：小さなメソッドに分割（5-15行程度）
def process_order
  validate_order
  calculate_totals
  apply_discounts
  process_payment
  reduce_inventory
  send_confirmation
end

private

def validate_order
  # 5-10行
end

def calculate_totals
  # 5-10行
end

## 改善点：
## 1. 理解しやすい
## 2. バグが発生しにくい
## 3. テストが容易
```

**ネストの深さ：**

```ruby
## ❌ 悪い例：ネストが4階層以上
def calculate_discount(user, order)
  if user.premium?
    if order.total > 10000
      if order.items.count > 5
        if user.first_order?
          return order.total * 0.3
        end
      end
    end
  end
  0
end

## 問題点：
## 1. 理解が困難
## 2. バグが発生しやすい
## 3. テストが困難
```

```ruby
## ✅ 良い例：ガード句で早期リターン
def calculate_discount(user, order)
  return 0 unless user.premium?
  return 0 unless order.total > 10000
  return 0 unless order.items.count > 5
  return 0 unless user.first_order?

  order.total * 0.3
end

## 改善点：
## 1. 理解しやすい
## 2. バグが発生しにくい
## 3. テストが容易
```

---

### レイヤー構造の詳細解説

#### 標準MVC層

##### Controller層

**責務：**

- HTTPリクエスト/レスポンスの処理
- 認証・認可
- パラメータの検証と変換
- ビジネスロジックの呼び出し

**判断基準：**

- リクエスト/レスポンス処理以外のロジックがあるか？
- 複雑なビジネスロジックがControllerにないか？

**具体例：**

```ruby
## ❌ 悪い例：Controllerにビジネスロジックが混在
class OrdersController < ApplicationController
  def create
    @order = Order.new(order_params)
    @order.user_id = current_user.id

    # 在庫チェック（ビジネスロジック）
    @order.items.each do |item|
      if item.product.stock < item.quantity
        flash[:error] = "Insufficient stock for #{item.product.name}"
        render :new and return
      end
    end

    # 価格計算（ビジネスロジック）
    subtotal = @order.items.sum { |item| item.product.price * item.quantity }
    discount = current_user.premium? ? subtotal * 0.1 : 0
    tax = (subtotal - discount) * 0.1
    @order.total = subtotal - discount + tax

    if @order.save
      # 在庫減少（ビジネスロジック）
      @order.items.each do |item|
        item.product.decrement!(:stock, item.quantity)
      end

      # メール送信（ビジネスロジック）
      OrderMailer.confirmation(@order).deliver_now

      redirect_to @order, notice: "Order was successfully created."
    else
      render :new
    end
  end
end

## 問題点：
## 1. Controllerに複数の責務が混在
## 2. ビジネスロジックがControllerに散在
## 3. テストが困難
## 4. 再利用性が低い
```

```ruby
## ✅ 良い例：Controllerはリクエスト/レスポンス処理のみ
class OrdersController < ApplicationController
  def create
    result = Orders::CreateOrderService.call(
      order_params: order_params,
      user: current_user
    )

    if result.success?
      redirect_to result.data, notice: "Order was successfully created."
    else
      @order = result.data
      flash.now[:error] = result.errors.join(", ")
      render :new
    end
  end

  private

  def order_params
    params.require(:order).permit(:delivery_address, items_attributes: [:product_id, :quantity])
  end
end

## app/services/orders/create_order_service.rb
module Orders
  class CreateOrderService
    def self.call(order_params:, user:)
      new(order_params, user).call
    end

    def initialize(order_params, user)
      @order_params = order_params
      @user = user
    end

    def call
      order = build_order

      return Result.error(data: order, errors: ["User cannot place orders"]) unless @user.can_order?
      return Result.error(data: order, errors: stock_errors) unless sufficient_stock?(order)

      ActiveRecord::Base.transaction do
        calculate_totals(order)
        order.save!
        reduce_stock(order)
        send_confirmation(order)
      end

      Result.success(data: order)
    rescue => e
      Rails.logger.error "Order creation failed: #{e.message}"
      Result.error(data: order, errors: [e.message])
    end

    private

    def build_order
      order = Order.new(@order_params)
      order.user = @user
      order
    end

    def sufficient_stock?(order)
      order.items.all? { |item| item.product.stock >= item.quantity }
    end

    def stock_errors
      errors = []
      order.items.each do |item|
        if item.product.stock < item.quantity
          errors << "Insufficient stock for #{item.product.name}"
        end
      end
      errors
    end

    def calculate_totals(order)
      subtotal = order.items.sum { |item| item.product.price * item.quantity }
      discount = @user.premium? ? subtotal * 0.1 : 0
      tax = (subtotal - discount) * 0.1
      order.total = subtotal - discount + tax
    end

    def reduce_stock(order)
      order.items.each do |item|
        item.product.decrement!(:stock, item.quantity)
      end
    end

    def send_confirmation(order)
      OrderMailer.confirmation(order).deliver_later
    end
  end
end

## 改善点：
## 1. Controllerはリクエスト/レスポンス処理のみ
## 2. ビジネスロジックはService層に分離
## 3. テストが容易
## 4. 再利用性が高い
```

##### Model層

**責務：**

- データの永続化
- バリデーション
- 基本的なビジネスルール
- アソシエーション

**判断基準：**

- 表示用のメソッドがModelにないか？
- 複雑なビジネスロジックがModelにないか？

**具体例：**

```ruby
## ❌ 悪い例：Modelにプレゼンテーション層のロジック
class User < ApplicationRecord
  def display_name
    "#{name} (#{age} years old)"  # View層のロジック
  end

  def to_csv_row
    [id, name, email, created_at.strftime("%Y-%m-%d")].join(",")  # Export層のロジック
  end
end

## 問題点：
## 1. Modelに表示用のロジックが混在
## 2. 責務が不明確
## 3. 再利用性が低い
```

```ruby
## ✅ 良い例：Modelはビジネスルールとデータのみ
class User < ApplicationRecord
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :age, numericality: { greater_than: 0, less_than: 150 }

  has_many :orders
  has_many :posts

  # ビジネスルール
  def premium?
    subscription_tier == 'premium'
  end

  def can_order?
    active? && email_verified?
  end

  # ドメインロジック
  def total_spent
    orders.sum(:total)
  end
end

## Presenterに分離
class UserPresenter
  def initialize(user)
    @user = user
  end

  def display_name
    "#{@user.name} (#{@user.age} years old)"
  end

  def membership_badge
    @user.premium? ? "⭐ Premium" : "Standard"
  end
end

## Exporterに分離
class UserCsvExporter
  def initialize(users)
    @users = users
  end

  def to_csv
    CSV.generate do |csv|
      csv << ["ID", "Name", "Email", "Created At"]
      @users.each do |user|
        csv << [user.id, user.name, user.email, user.created_at.strftime("%Y-%m-%d")]
      end
    end
  end
end

## 改善点：
## 1. Modelはビジネスルールとデータのみ
## 2. 表示ロジックはPresenterに分離
## 3. 出力ロジックはExporterに分離
## 4. 責務が明確
```

#### 追加レイヤー

##### Service層

**こんな時に使う：**

- 複雑なビジネスロジック
- 複数モデルの協調
- 外部API連携
- トランザクション管理

**判断基準：**

- 3つ以上の異なる処理（トランザクション）が必要か？
- 複数のモデルを協調させる必要があるか？
- 外部API呼び出しが含まれるか？
- 同じビジネスロジックを複数箇所で使用するか？

**メリット：**

- ビジネスロジックの集約
- テストのしやすさ
- 再利用性

**デメリット：**

- レイヤーの増加
- 過度な抽象化のリスク

**具体例：**

```ruby
## app/services/user_registration_service.rb
class UserRegistrationService
  def initialize(user_params)
    @user_params = user_params
  end

  def call
    user = User.new(@user_params)
    if user.save
      { success: true, user: user }
    else
      { success: false, errors: user.errors.full_messages }
    end
  rescue ActiveRecord::RecordInvalid => e
    raise UserRegistrationError, "ユーザー登録に失敗しました: #{e.message}"
  end
end

## 使用例
class UsersController < ApplicationController
  def create
    result = UserRegistrationService.new(user_params).call

    if result[:success]
      render json: { user: result[:user] }, status: :created
    else
      render json: { errors: result[:errors] }, status: :unprocessable_entity
    end
  end
end
```

##### Form Object

**こんな時に使う：**

- 複数モデルにまたがるフォーム処理
- データベースに保存しない一時的なフォーム
- 複雑なバリデーションロジック

**判断基準：**

- 3つ以上のモデルを同時に作成・更新するか？
- データベースに保存しない一時的なフォームか？
- 複雑なバリデーションロジックが必要か？

**メリット：**

- 複数モデルの処理をカプセル化
- バリデーションの集約
- フォーム処理の明確化

**デメリット：**

- レイヤーの増加
- ActiveRecordの恩恵を受けにくい

**具体例：**

```ruby
## app/forms/user_registration_form.rb
class UserRegistrationForm
  include ActiveModel::Model

  attr_accessor :name, :email, :password, :bio, :location, :invite_code

  validates :name, :email, :password, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validate :validate_invite_code

  def save
    return false unless valid?

    ActiveRecord::Base.transaction do
      create_user!
      create_profile!
      create_settings!
    end

    true
  rescue => e
    Rails.logger.error "Registration failed: #{e.message}"
    errors.add(:base, e.message)
    false
  end

  def user
    @user
  end

  private

  def create_user!
    @user = User.create!(
      name: name,
      email: email,
      password: password,
      role: invite_code.present? ? 'premium' : 'free'
    )
  end

  def create_profile!
    @user.create_profile!(
      bio: bio,
      location: location
    )
  end

  def create_settings!
    @user.create_settings!(
      theme: 'light',
      notifications: true
    )
  end

  def validate_invite_code
    if invite_code.present? && !valid_invite_code?
      errors.add(:invite_code, 'is invalid')
    end
  end

  def valid_invite_code?
    InviteCode.exists?(code: invite_code, used: false)
  end
end

## Controller
class UsersController < ApplicationController
  def create
    @form = UserRegistrationForm.new(form_params)

    if @form.save
      redirect_to @form.user, notice: 'User created!'
    else
      render :new
    end
  end

  private

  def form_params
    params.require(:user_registration_form).permit(
      :name, :email, :password, :bio, :location, :invite_code
    )
  end
end
```

##### Query Object

**こんな時に使う：**

- 複雑な検索条件
- 動的に条件を組み立てる
- 複数のControllerで同じクエリを使用

**判断基準：**

- 5つ以上の条件が必要か？
- 動的に条件を組み立てる必要があるか？
- 複数のControllerで同じクエリを使用するか？
- scopeのチェーンが5つ以上になるか？

**メリット：**

- クエリロジックの集約
- 再利用性
- テストのしやすさ

**デメリット：**

- レイヤーの増加
- ActiveRecordの恩恵を受けにくい

**具体例：**

```ruby
## app/queries/product_search_query.rb
class ProductSearchQuery
  attr_reader :relation

  def initialize(relation = Product.all)
    @relation = relation
  end

  def call(params)
    @relation = filter_by_category(params[:category])
    @relation = filter_by_price_range(params[:min_price], params[:max_price])
    @relation = filter_by_stock(params[:in_stock])
    @relation = search_by_keyword(params[:search])
    @relation = sort_results(params[:sort])
    @relation
  end

  private

  def filter_by_category(category)
    return @relation if category.blank?
    @relation.where(category: category)
  end

  def filter_by_price_range(min_price, max_price)
    @relation = @relation.where('price >= ?', min_price) if min_price.present?
    @relation = @relation.where('price <= ?', max_price) if max_price.present?
    @relation
  end

  def filter_by_stock(in_stock)
    return @relation if in_stock != '1'
    @relation.where('stock > 0')
  end

  def search_by_keyword(keyword)
    return @relation if keyword.blank?
    @relation.where(
      'name ILIKE ? OR description ILIKE ?',
      "%#{keyword}%",
      "%#{keyword}%"
    )
  end

  def sort_results(sort)
    case sort
    when 'price_asc'
      @relation.order(price: :asc)
    when 'price_desc'
      @relation.order(price: :desc)
    when 'newest'
      @relation.order(created_at: :desc)
    else
      @relation.order(name: :asc)
    end
  end
end

## Controller
class ProductsController < ApplicationController
  def index
    @products = ProductSearchQuery.new.call(params).page(params[:page])
  end
end
```

---

### Rails特有の設計の詳細解説

#### トランザクション境界の設計

##### トランザクション境界の判断

**どこでトランザクションを切るか：**

1. **ビジネストランザクション単位**
   - 1つのビジネス操作が完了する単位
   - 例：注文確定、ユーザー登録

2. **データ整合性の境界**
   - データの整合性を保つ必要がある単位
   - 例：在庫減少と注文確定

3. **外部システム連携の境界**
   - 外部システムとの連携単位
   - 例：決済処理

**具体例：**

```ruby
## ❌ 悪い例：トランザクション境界が不適切
class OrderService
  def create_order(order_params)
    # トランザクション境界が不明確
    order = Order.create!(order_params)

    # 外部API呼び出し（トランザクション外）
    payment_result = PaymentGateway.charge(order.total)

    # 在庫減少（トランザクション外）
    order.items.each do |item|
      item.product.decrement!(:stock, item.quantity)
    end

    order
  end
end

## 問題点：
## 1. トランザクション境界が不明確
## 2. 外部API呼び出しでトランザクションが切れる
## 3. データ整合性が保たれない
```

```ruby
## ✅ 良い例：適切なトランザクション境界
class OrderService
  def create_order(order_params)
    ActiveRecord::Base.transaction do
      # 注文作成
      order = Order.create!(order_params)

      # 在庫確認
      validate_stock(order)

      # 在庫減少
      reduce_stock(order)

      # 注文確定
      order.confirm!

      # 外部API呼び出し（トランザクション内）
      payment_result = PaymentGateway.charge(order.total)

      # 決済情報保存
      order.update!(payment_id: payment_result.id)

      order
    end
  rescue => e
    # エラー時の処理
    Rails.logger.error "Order creation failed: #{e.message}"
    raise e
  end

  private

  def validate_stock(order)
    order.items.each do |item|
      if item.product.stock < item.quantity
        raise InsufficientStockError, "Insufficient stock for #{item.product.name}"
      end
    end
  end

  def reduce_stock(order)
    order.items.each do |item|
      item.product.decrement!(:stock, item.quantity)
    end
  end
end

## 改善点：
## 1. トランザクション境界が明確
## 2. データ整合性が保たれる
## 3. エラー時の処理が適切
```

#### エラーハンドリングの設計

##### 技術的例外 vs ビジネス例外の区別

**技術的例外：**

- アプリケーションの実行そのものが続けられなくなる問題
- プログラマのミスや実行環境の不備が原因
- システム全体に影響する
- ユーザーが対処できない

**ビジネス例外：**

- 業務ロジックの判断によりプログラムの実行が中断される状況
- 業務ルールやビジネスロジックに基づく正常な分岐処理
- ユーザーが対処可能
- 代替フローが存在する

**具体例：**

```ruby
## 技術的例外の例
class User < ApplicationRecord
  def self.find_by_email!(email)
    find_by!(email: email)  # ActiveRecord::RecordNotFoundが発生
  end
end

## ビジネス例外の例
class BankAccount
  def withdraw(amount)
    if amount > balance
      raise InsufficientBalanceError, "残高不足です"
    end
    # 引き出し処理
  end
end

## エラーハンドリングの実装
class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :render_404
  rescue_from InsufficientBalanceError, with: :render_400

  private

  def render_404(e)
    render json: { error: 'リソースが見つかりません' }, status: :not_found
  end

  def render_400(e)
    render json: { error: e.message }, status: :bad_request
  end
end
```

##### Service層でのエラーハンドリング設計

#### なぜService層でエラーハンドリングが重要なのか

1. **複雑なビジネスロジック** - Service層は複数の処理を協調させるため、エラーの種類も多様
2. **統一された戻り値** - Controller層で一貫したエラー処理を行うため
3. **テスタビリティ** - エラーの種類を明確に区別することで、テストが書きやすくなる
4. **保守性** - エラーハンドリングが統一されていることで、コードの理解と修正が容易

#### Service層でのエラーハンドリング戦略

##### 1. 技術的例外 → raiseする

技術的例外はraiseして、Controllerの`rescue_from`で一元的に処理します。

```ruby
## Service層
class UserRegistrationService
  def call(params)
    # 技術的例外はraise
    user = User.new(params)
    user.save!  # ActiveRecord::RecordInvalid が発生する可能性

    # 外部API呼び出し
    ExternalApiService.call(user)  # Net::TimeoutError が発生する可能性

    # ファイル操作
    File.write(user.avatar_path, avatar_data)  # Errno::ENOENT が発生する可能性
  end
end

## Controller層
class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordInvalid, with: :render_validation_error
  rescue_from Net::TimeoutError, with: :render_external_service_error
  rescue_from Errno::ENOENT, with: :render_file_error
  rescue_from StandardError, with: :render_internal_server_error

  private

  def render_validation_error(exception)
    render json: { errors: exception.record.errors.full_messages },
           status: :unprocessable_entity
  end

  def render_external_service_error(exception)
    render json: { error: '外部サービスでエラーが発生しました' },
           status: :service_unavailable
  end
end
```

##### 2. ビジネス例外 → Result型で返す

ビジネス例外はResult型で返して、Controllerで分岐処理します。

```ruby
## Result型の実装
class Result
  STATUSES = {
    success: :success,
    invalid: :invalid,
    duplicate: :duplicate,
    not_found: :not_found,
    unauthorized: :unauthorized,
    insufficient_balance: :insufficient_balance,
    out_of_stock: :out_of_stock
  }.freeze

  attr_reader :status, :data, :errors, :metadata

  def initialize(status, data: nil, errors: [], metadata: {})
    @status = status
    @data = data
    @errors = errors
    @metadata = metadata
  end

  def success?
    status == :success
  end

  def failure?
    !success?
  end

  # ファクトリメソッド
  def self.success(data = nil, metadata: {})
    new(:success, data: data, metadata: metadata)
  end

  def self.invalid(errors = [], metadata: {})
    new(:invalid, errors: errors, metadata: metadata)
  end

  def self.duplicate(errors = [], metadata: {})
    new(:duplicate, errors: errors, metadata: metadata)
  end

  def self.unauthorized(errors = [], metadata: {})
    new(:unauthorized, errors: errors, metadata: metadata)
  end
end

## Service層での使用
class UserRegistrationService
  def call(params)
    user = User.new(params)

    # ビジネス例外はResult型で返す
    return Result.invalid(user.errors.full_messages) unless user.valid?
    return Result.duplicate(['Email already exists']) if duplicate?(user)
    return Result.unauthorized(['Age restriction']) if underage?(user)

    if user.save
      Result.success(user)
    else
      Result.invalid(user.errors.full_messages)
    end
  end

  private

  def duplicate?(user)
    User.exists?(email: user.email)
  end

  def underage?(user)
    user.age < 18
  end
end

## Controller層での使用
class UsersController < ApplicationController
  def create
    result = UserRegistrationService.call(user_params)

    case result.status
    when :success
      render json: result.data, status: :created
    when :invalid
      render json: { errors: result.errors }, status: :unprocessable_entity
    when :duplicate
      render json: { error: "Already exists" }, status: :conflict
    when :unauthorized
      render json: { error: "Not authorized" }, status: :unauthorized
    end
  end
end
```

##### 3. ハイブリッドアプローチ（推奨）

技術的例外をキャッチしてビジネス例外に変換します。

```ruby
class UserRegistrationService
  def call(params)
    begin
      # 技術的例外はraise
      user = User.new(params)
      user.save!

      # 外部API呼び出し（技術的例外）
      ExternalApiService.call(user)

      # ビジネス例外はResult型で返す
      return Result.duplicate(['Email already exists']) if duplicate?(user)
      return Result.unauthorized(['Age restriction']) if underage?(user)

      Result.success(user)

    rescue ActiveRecord::RecordInvalid => e
      # 技術的例外をビジネス例外に変換
      Result.invalid(e.record.errors.full_messages)
    rescue Net::TimeoutError => e
      # 技術的例外をビジネス例外に変換
      Result.external_service_error(['External service timeout'])
    rescue StandardError => e
      # 予期しないエラー
      Rails.logger.error "Unexpected error in UserRegistrationService: #{e.message}"
      Result.failure(['An unexpected error occurred'])
    end
  end
end
```

**判断基準：**

###### raiseするべき技術的例外

```ruby
## 1. データベースエラー
user.save!  # ActiveRecord::RecordInvalid

## 2. 外部APIエラー
ExternalApiService.call  # Net::TimeoutError, Net::HTTPError

## 3. ファイルシステムエラー
File.read(path)  # Errno::ENOENT

## 4. メモリ不足
## NoMemoryError

## 5. ネットワークエラー
## SocketError, Timeout::Error
```

###### Result型で返すべきビジネス例外

```ruby
## 1. バリデーションエラー
return Result.invalid(errors) unless valid?

## 2. 権限エラー
return Result.unauthorized(['Not authorized']) unless authorized?

## 3. ビジネスルール違反
return Result.insufficient_balance(['Insufficient funds']) if balance < amount

## 4. 重複エラー
return Result.duplicate(['Already exists']) if duplicate?

## 5. 在庫不足
return Result.out_of_stock(['Out of stock']) if stock < quantity
```

**メリット：**

1. **明確な状態表現** - 成功・失敗の種類が明確
2. **型安全性** - 戻り値の構造が統一されている
3. **テストしやすさ** - 状態を明確に検証できる
4. **保守性** - エラーハンドリングが一貫している
5. **拡張性** - 新しい状態を簡単に追加できる

##### rescue vs rescue_from の使い分け

**なぜ使い分けが重要なのか：**

1. **責務の明確化** - 各層で適切なエラーハンドリング方法を使用することで、責務が明確になる
2. **重複排除** - 同じエラー処理が複数箇所で重複することを防ぐ
3. **保守性** - エラーハンドリングの変更が一箇所で済む
4. **テスタビリティ** - 各層のエラーハンドリングを独立してテストできる

**使い分けの基本原則：**

###### Service層 → `rescue`を使用

**理由：**

- Service層はビジネスロジックの層
- エラーを適切に処理して、Controller層に結果を返す責任
- 技術的例外をビジネス例外に変換する役割

```ruby
## ✅ Service層でのrescue使用
class UserRegistrationService
  def call(params)
    begin
      user = User.new(params)
      user.save!

      # 外部API呼び出し
      ExternalApiService.call(user)

      Result.success(user)

    rescue ActiveRecord::RecordInvalid => e
      # 技術的例外をビジネス例外に変換
      Result.invalid(e.record.errors.full_messages)
    rescue Net::TimeoutError => e
      # 技術的例外をビジネス例外に変換
      Result.external_service_error(['External service timeout'])
    rescue StandardError => e
      # 予期しないエラー
      Rails.logger.error "Unexpected error: #{e.message}"
      Result.failure(['An unexpected error occurred'])
    end
  end
end
```

###### Controller層 → `rescue_from`を使用

**理由：**

- Controller層はHTTPリクエスト/レスポンスの層
- 統一されたエラーレスポンスを提供する責任
- アプリケーション全体での一貫したエラー処理

```ruby
## ✅ Controller層でのrescue_from使用
class ApplicationController < ActionController::Base
  # 特定の例外を先に配置
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :render_validation_error
  rescue_from Net::TimeoutError, with: :render_external_service_error

  # キャッチオールを最後に配置
  rescue_from StandardError, with: :render_internal_server_error

  private

  def render_not_found(exception)
    render json: { error: 'リソースが見つかりません' }, status: :not_found
  end

  def render_validation_error(exception)
    render json: { errors: exception.record.errors.full_messages },
           status: :unprocessable_entity
  end

  def render_external_service_error(exception)
    render json: { error: '外部サービスでエラーが発生しました' },
           status: :service_unavailable
  end

  def render_internal_server_error(exception)
    error_id = SecureRandom.uuid
    Rails.logger.error "[#{error_id}] #{exception.class}: #{exception.message}"

    render json: { error: 'システムエラーが発生しました', error_id: error_id },
           status: :internal_server_error
  end
end
```

**判断基準：**

###### `rescue`を使うべき時

1. **Service層でのエラー処理**
2. **特定の処理でのみ発生するエラー**
3. **エラーを別の形式に変換したい時**
4. **ログ出力や通知が必要な時**

```ruby
## Service層でのrescue使用例
class PaymentService
  def process_payment(amount)
    begin
      # 決済処理
      payment_result = PaymentGateway.charge(amount)

      if payment_result.success?
        Result.success(payment_result)
      else
        Result.payment_failed(['Payment failed'])
      end

    rescue PaymentGateway::NetworkError => e
      # ネットワークエラーをビジネス例外に変換
      Rails.logger.error "Payment network error: #{e.message}"
      Result.payment_failed(['Network error occurred'])
    rescue PaymentGateway::InvalidCardError => e
      # カードエラーをビジネス例外に変換
      Result.invalid_card(['Invalid card information'])
    end
  end
end
```

###### `rescue_from`を使うべき時

1. **Controller層での統一的なエラー処理**
2. **アプリケーション全体で共通のエラー処理**
3. **HTTPステータスコードの統一**
4. **エラーレスポンスの統一**

```ruby
## Controller層でのrescue_from使用例
class ApiController < ApplicationController
  # ビジネス例外
  rescue_from BusinessError, with: :render_business_error
  rescue_from ValidationError, with: :render_validation_error

  # 技術的例外
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from Net::TimeoutError, with: :render_timeout_error

  # システム例外
  rescue_from StandardError, with: :render_system_error

  private

  def render_business_error(exception)
    render json: {
      error: {
        type: 'business',
        message: exception.message
      }
    }, status: :unprocessable_entity
  end

  def render_validation_error(exception)
    render json: {
      error: {
        type: 'validation',
        message: exception.message,
        details: exception.details
      }
    }, status: :unprocessable_entity
  end
end
```

**避けるべきパターン：**

###### ❌ Controller層でrescueを使う

```ruby
## ❌ 悪い例：Controller層でrescueを使用
class UsersController < ApplicationController
  def create
    begin
      result = UserRegistrationService.call(user_params)

      if result.success?
        render json: result.data, status: :created
      else
        render json: { errors: result.errors }, status: :unprocessable_entity
      end
    rescue StandardError => e
      # 各Controllerで同じエラー処理を繰り返す
      render json: { error: 'エラーが発生しました' }, status: :internal_server_error
    end
  end
end
```

**問題点：**

- 同じエラー処理が複数箇所で重複
- エラーレスポンスの形式が統一されない
- 保守性が低下
- テストが困難

###### ❌ Service層でrescue_fromを使う

```ruby
## ❌ 悪い例：Service層でrescue_fromを使用（不可能）
class UserRegistrationService
  # rescue_fromはController層でのみ使用可能
  rescue_from StandardError, with: :handle_error  # ← これは動作しない
end
```

**推奨パターン：**

###### ✅ ハイブリッドアプローチ

```ruby
## Service層：rescueで技術的例外をビジネス例外に変換
class UserRegistrationService
  def call(params)
    begin
      user = User.new(params)
      user.save!

      Result.success(user)

    rescue ActiveRecord::RecordInvalid => e
      Result.invalid(e.record.errors.full_messages)
    rescue StandardError => e
      Rails.logger.error "Unexpected error: #{e.message}"
      Result.failure(['An unexpected error occurred'])
    end
  end
end

## Controller層：rescue_fromで統一的なエラー処理
class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from StandardError, with: :render_internal_server_error

  private

  def render_not_found(exception)
    render json: { error: 'リソースが見つかりません' }, status: :not_found
  end

  def render_internal_server_error(exception)
    error_id = SecureRandom.uuid
    Rails.logger.error "[#{error_id}] #{exception.class}: #{exception.message}"

    render json: { error: 'システムエラーが発生しました', error_id: error_id },
           status: :internal_server_error
  end
end
```

**メリット：**

1. **責務の明確化** - 各層で適切なエラーハンドリング方法を使用
2. **重複排除** - 同じエラー処理が複数箇所で重複しない
3. **保守性** - エラーハンドリングの変更が一箇所で済む
4. **テスタビリティ** - 各層のエラーハンドリングを独立してテストできる
5. **一貫性** - アプリケーション全体で統一されたエラーレスポンス

#### コールバック vs 明示的処理

##### コールバックを使うべき時

**シンプルで必ず必要な処理：**

- `before_save :normalize_email` - メール正規化
- `before_validation :strip_whitespace` - 空白除去
- `after_commit :clear_cache` - キャッシュクリア

**判断基準：**

- 処理がシンプルか？
- 必ず実行される必要があるか？
- 副作用が少ないか？

##### 明示的処理（Service）を使うべき時

**複雑なビジネスロジック：**

- 複数の副作用がある処理
- 条件によって実行したりしなかったり
- テストで分離したい処理

**判断基準：**

- 複雑なビジネスロジックか？
- 複数の副作用があるか？
- 条件によって実行が変わるか？
- テストで分離したいか？

**具体例：**

```ruby
## ❌ 悪い例：コールバック（暗黙的）
class User < ApplicationRecord
  after_create :send_welcome_email
  after_create :create_default_settings
  after_create :notify_admin
  after_create :track_analytics

  private

  def send_welcome_email
    UserMailer.welcome(self).deliver_later
  end

  def create_default_settings
    create_settings!(theme: 'light')
  end

  def notify_admin
    AdminMailer.new_user(self).deliver_later
  end

  def track_analytics
    Analytics.track(self.id, 'user_created')
  end
end

## 使用時
user = User.create!(params)  # ← 裏で4つの処理が走る（見えない！）

## 問題点：
## 1. 何が実行されるか分からない
## 2. テストでUser.create!すると、毎回メールが飛ぶ
## 3. 管理画面でユーザー作成時もメールが飛ぶ
```

```ruby
## ✅ 良い例：明示的処理（Service層）
class User < ApplicationRecord
  # シンプルなModel
end

## app/services/user_registration_service.rb
class UserRegistrationService
  def initialize(params)
    @params = params
  end

  def call
    user = User.create!(@params)

    # 明示的に処理を実行
    send_welcome_email(user)
    create_default_settings(user)
    notify_admin(user)
    track_analytics(user)

    user
  end

  private

  def send_welcome_email(user)
    UserMailer.welcome(user).deliver_later
  end

  def create_default_settings(user)
    user.create_settings!(theme: 'light')
  end

  def notify_admin(user)
    AdminMailer.new_user(user).deliver_later
  end

  def track_analytics(user)
    Analytics.track(user.id, 'user_created')
  end
end

## 使用時
UserRegistrationService.new(params).call  # ← 何が起きるか明確！

## 改善点：
## 1. 何が実行されるか一目瞭然
## 2. テストでUser.create!だけ使える（メール送信なし）
## 3. 管理画面では別のServiceを使える
```

---

### レイヤー選択の判断基準

#### Service層を使うべき時

**判断基準：**

- 3つ以上の異なる処理（トランザクション）が必要
- 複数のモデルを協調させる必要がある
- 外部API呼び出しが含まれる
- 同じビジネスロジックを複数箇所で使用する
- 複雑なエラーハンドリングが必要（技術的例外とビジネス例外の使い分け）
- 統一された戻り値（Result型）が必要

**具体例：**

```ruby
## 注文処理のService層
class Orders::CreateOrderService
  def call(order_params:, user:)
    ActiveRecord::Base.transaction do
      # 1. 在庫確認
      validate_stock(order)
      # 2. 価格計算
      calculate_totals(order)
      # 3. 決済処理
      process_payment(order)
      # 4. 在庫減少
      reduce_stock(order)
      # 5. 配送手配
      schedule_delivery(order)
    end
  end
end
```

#### Form Objectを使うべき時

**判断基準：**

- 3つ以上のモデルを同時に作成・更新する
- データベースに保存しない一時的なフォーム
- 複雑なバリデーションロジックが必要

**具体例：**

```ruby
## ユーザー登録フォーム
class UserRegistrationForm
  include ActiveModel::Model

  attr_accessor :name, :email, :password, :bio, :location, :invite_code

  def save
    ActiveRecord::Base.transaction do
      create_user!      # Userモデル
      create_profile!   # Profileモデル
      create_settings!  # Settingsモデル
    end
  end
end
```

#### Query Objectを使うべき時

**判断基準：**

- 5つ以上の条件が必要
- 動的に条件を組み立てる必要がある
- 複数のControllerで同じクエリを使用する
- scopeのチェーンが5つ以上になる

**具体例：**

```ruby
## 商品検索クエリ
class ProductSearchQuery
  def call(params)
    @relation = filter_by_category(params[:category])
    @relation = filter_by_price_range(params[:min_price], params[:max_price])
    @relation = filter_by_stock(params[:in_stock])
    @relation = search_by_keyword(params[:search])
    @relation = sort_results(params[:sort])
    @relation
  end
end
```

#### Presenter/Decoratorを使うべき時

**判断基準：**

- View内のロジックが10行以上になる
- 同じ表示ロジックを複数のViewで使用する
- Modelに表示用のメソッドを追加したくない

**具体例：**

```ruby
## ユーザープレゼンター
class UserPresenter
  def initialize(user)
    @user = user
  end

  def display_name
    "#{@user.name} (#{@user.age} years old)"
  end

  def membership_badge
    @user.premium? ? "⭐ Premium" : "Standard"
  end
end
```

#### Policy Objectを使うべき時

**判断基準：**

- 認可ロジックが複雑
- 複数のControllerで同じ認可ロジックを使用する
- 権限チェックが複雑

**具体例：**

```ruby
## 記事ポリシー
class ArticlePolicy
  def initialize(user, article)
    @user = user
    @article = article
  end

  def edit?
    @user.admin? || (@user == @article.author && @article.published?)
  end

  def delete?
    @user.admin? || (@user == @article.author && !@article.published?)
  end
end
```

#### Value Objectを使うべき時

**判断基準：**

- ドメイン概念を表現する値
- 不変である必要がある
- ビジネスルールを含む

**具体例：**

```ruby
## 金額Value Object
class Money
  include Comparable

  attr_reader :amount, :currency

  def initialize(amount, currency = 'JPY')
    @amount = BigDecimal(amount.to_s)
    @currency = currency.to_s.upcase
  end

  def +(other)
    Money.new(amount + other.amount, currency)
  end

  def *(multiplier)
    Money.new(amount * multiplier, currency)
  end

  def <=>(other)
    amount <=> other.amount
  end
end
```

#### Serializerを使うべき時

**判断基準：**

- API レスポンスを整形する必要がある
- 複雑なJSON構造が必要
- レスポンス形式を統一したい

**具体例：**

```ruby
## ユーザーシリアライザー
class UserSerializer
  def initialize(user)
    @user = user
  end

  def as_json
    {
      id: @user.id,
      name: @user.name,
      email: @user.email,
      profile: {
        bio: @user.bio,
        location: @user.location
      },
      created_at: @user.created_at.iso8601
    }
  end
end
```

#### Builderを使うべき時

**判断基準：**

- 複雑なオブジェクト生成が必要
- 段階的なオブジェクト構築が必要
- オブジェクト生成を抽象化したい

**具体例：**

```ruby
## 注文ビルダー
class OrderBuilder
  def initialize
    @order = Order.new
  end

  def with_user(user)
    @order.user = user
    self
  end

  def with_items(items)
    @order.items = items
    self
  end

  def with_discount(discount)
    @order.discount = discount
    self
  end

  def build
    calculate_totals
    @order
  end

  private

  def calculate_totals
    @order.subtotal = @order.items.sum(&:total)
    @order.total = @order.subtotal - @order.discount
  end
end

## 使用例
order = OrderBuilder.new
  .with_user(user)
  .with_items(items)
  .with_discount(discount)
  .build
```

#### Repositoryを使うべき時

**判断基準：**

- データアクセス層を抽象化したい
- 複雑なクエリを集約したい
- データソースを切り替える可能性がある

**具体例：**

```ruby
## ユーザーリポジトリ
class UserRepository
  def initialize(relation = User.all)
    @relation = relation
  end

  def find_by_email(email)
    @relation.find_by(email: email)
  end

  def find_active_users
    @relation.where(active: true)
  end

  def find_by_role(role)
    @relation.where(role: role)
  end
end
```

#### Job/Workerを使うべき時

**判断基準：**

- 非同期で処理したい
- 重い処理がある
- バックグラウンドで処理したい

**具体例：**

```ruby
## メール送信ジョブ
class WelcomeEmailJob < ApplicationJob
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)
    UserMailer.welcome(user).deliver_now
  end
end

## 重い処理のジョブ
class DataProcessingJob < ApplicationJob
  queue_as :low_priority

  def perform(data_id)
    data = Data.find(data_id)
    # 重い処理
    data.process!
  end
end
```

#### Concernを使うべき時

**判断基準：**

- 複数のモデルで同じ機能を使用する
- 横断的な関心事を共通化したい
- 機能を再利用したい

**具体例：**

```ruby
## タイムスタンプConcern
module Timestampable
  extend ActiveSupport::Concern

  included do
    scope :recent, -> { order(created_at: :desc) }
    scope :old, -> { where('created_at < ?', 1.year.ago) }
  end

  def age_in_days
    (Time.current - created_at) / 1.day
  end
end

## 使用例
class User < ApplicationRecord
  include Timestampable
end

class Post < ApplicationRecord
  include Timestampable
end
```

---

### コールバック vs 明示的処理の判断

#### コールバックを使うべき時

**判断基準：**

- シンプルで必ず必要な処理
- 副作用が少ない処理

**具体例：**

```ruby
## ✅ 良い例：シンプルな処理
class User < ApplicationRecord
  before_save :normalize_email
  before_validation :strip_whitespace
  after_commit :clear_cache

  private

  def normalize_email
    self.email = email.downcase.strip
  end

  def strip_whitespace
    self.name = name.strip
  end

  def clear_cache
    Rails.cache.delete("user_#{id}")
  end
end
```

#### 明示的処理（Service）を使うべき時

**判断基準：**

- 複雑なビジネスロジック
- 複数の副作用がある処理
- 条件によって実行が変わる処理
- テストで分離したい処理

**具体例：**

```ruby
## ✅ 良い例：複雑な処理はService層で明示的に
class User < ApplicationRecord
  # シンプルなModel
end

class UserRegistrationService
  def call(params)
    user = User.create!(params)

    # 明示的に処理を実行
    send_welcome_email(user)
    create_default_settings(user)
    notify_admin(user)
    track_analytics(user)

    user
  end

  private

  def send_welcome_email(user)
    UserMailer.welcome(user).deliver_later
  end

  def create_default_settings(user)
    user.create_settings!(theme: 'light')
  end

  def notify_admin(user)
    AdminMailer.new_user(user).deliver_later
  end

  def track_analytics(user)
    Analytics.track(user.id, 'user_created')
  end
end
```

---

### 実践的な設計判断例

#### シチュエーション1: ユーザー登録処理

**要件：**

- ユーザー、プロフィール、設定を同時に作成
- ウェルカムメール送信
- 管理者通知
- 統計更新

**推奨レイヤー：**

- **Form Object**（複数モデル入力）
- **Service層**（ビジネスロジック）
- **Job**（非同期処理）

**理由：**

- 複数モデル（User、Profile、Settings）の同時作成 → Form Object
- 複雑なビジネスロジック（メール送信、通知等） → Service層
- 非同期処理（メール送信） → Job

#### シチュエーション2: 注文処理

**要件：**

- 在庫確認
- 決済処理
- 在庫減少
- 配送手配
- 確認メール送信

**推奨レイヤー：**

- **Service層**（ビジネスロジック）
- **Job**（非同期処理）
- **Value Object**（金額）

**理由：**

- 複雑なビジネスロジック（在庫確認、決済、配送） → Service層
- 非同期処理（メール送信、配送手配） → Job
- ドメイン概念（金額）の表現 → Value Object

#### シチュエーション3: 検索機能

**要件：**

- 複雑な検索条件
- ソート機能
- ページネーション
- 検索結果の表示

**推奨レイヤー：**

- **Query Object**（複雑なクエリ）
- **Presenter**（表示ロジック）

**理由：**

- 複雑な検索条件 → Query Object
- 表示ロジックの分離 → Presenter

### まとめ

この詳細ガイドでは、Rails設計レビューで確認すべき重要なポイントについて、理由と具体例を詳しく解説しました。

#### 重要なポイント

1. **基本原則の理解** - SOLID原則、DRY原則、複雑度管理
2. **レイヤー構造の適切な選択** - 各レイヤーの責務と使い所
3. **Rails特有の設計判断** - トランザクション、エラーハンドリング、コールバック等

#### 設計レビューの流れ

1. **基本原則の確認** - SOLID原則、DRY原則等
2. **レイヤー構造の確認** - 各レイヤーの責務が適切か
3. **Rails特有の設計確認** - トランザクション、エラーハンドリング等
4. **実践的な判断** - 具体的なシチュエーションでの設計選択

これらのポイントを意識して設計レビューを行うことで、保守性が高く、拡張しやすいRailsアプリケーションを構築できます。
