---
title: コードレビュー実装ガイド - 4ステップワークフロー
tags: rails, review-workflow, process
---

<!-- markdownlint-disable MD025 -->

## コードレビュー実装ガイド - 4ステップワークフロー

Rails コードをレビューする際の**具体的で再現可能なワークフロー**を示します。

## ステップ1: 変更内容の初期分析（5分）

変更内容を読み、以下を判断します。これにより、どの観点を優先的にレビューするかが決まります。

| 確認項目               | 質問                                                  | 関連観点     |
| ---------------------- | ----------------------------------------------------- | ------------ |
| **何が変わった？**     | 新機能か？バグ修正か？リファクタリングか？            | すべて       |
| **どの領域？**         | Model / Controller / Service / Query / Migration か？ | 複数         |
| **複雑性**             | 変更コード行数は？新しい依存関係は？                  | 複雑性・設計 |
| **テスト**             | テストケースはあるか？カバレッジは十分か？            | テスト       |
| **セキュリティリスク** | 入力検証・認可・SQL注入リスクは？                     | セキュリティ |

**出力**: 「Critical（セキュリティ・機能）」「Important（設計・テスト）」「Nice to have（スタイル）」の優先度付け

## ステップ2: 6標準観点の優先度決定（3分）

初期分析の結果に基づいて、以下の優先度でレビューを計画します。

### Priority 1: Critical（セキュリティ・データ整合性）

これらが問題ならコミット前に必ず修正すべき：

- **セキュリティ** → 認証・認可・入力検証・SQL注入
- **設計** → アーキテクチャ・責務分離・全体整合性

### Priority 2: Important（パフォーマンス・テスト）

改善が強く推奨される：

- **パフォーマンス** → N+1問題・クエリ効率・メモリ使用量
- **テスト** → テストケースの十分性・テスト戦略

### Priority 3: Nice to have（命名・複雑性）

改善があれば望ましいが、必須ではない：

- **命名** → 変数・メソッドの名前の明確性
- **複雑性** → 認知負荷・メソッド長

## ステップ3: 各観点の具体的なチェック（10-20分）

優先度に従って、該当する perspective ファイルを参照してチェックリストを実施します。

### チェック結果の構造化

各観点について、以下の形式でまとめます：

```markdown
### 観点名 (Good Points / Moderate Concerns / Issues Found)

#### ✅ Good Points

- [チェックリストで確認された良い点]
- 例: "N+1問題が適切に防止されている（includesが正しく使用）"

#### ⚠️ Moderate Concerns

- [改善の余地がある点。必須ではないが改善が望ましい]
- 例: "default_scope の使用を検討すれば、重複コードが削減できる"

#### 🔴 Issues Found

- [修正が必須な問題]
- 例: "認可チェック（pundit）が実装されていない → セキュリティリスク"
```

### チェック実施例：ActiveRecord クエリの場合

```ruby
# レビュー対象コード
class ReportService
  def self.user_summary_with_posts
    User.where('created_at > ?', 30.days.ago)
      .joins(:posts)
      .select('users.id, users.name, COUNT(posts.id) as post_count')
      .group('users.id, users.name')
      .having('COUNT(posts.id) > 0')
      .order('post_count DESC')
  end
end
```

**チェック手順**:

1. **ステップ1**: 「複雑な集計クエリ」→ パフォーマンス・設計・テストが重要
2. **ステップ2**: Priority: Performance > Design > Testing
3. **ステップ3**: `perspective_03_performance.md` + `pattern_08_perf_analysis.md` で確認
   - ✅ DB 側で集計している（Ruby で配列集計していない）
   - ⚠️ スコープ化する方が再利用性が高い
   - ⚠️ テストで explain で実行クエリを確認した？

## ステップ4: 優先度付きレコメンデーション（5分）

全問題を優先度付けして、改善提案をまとめます。出力形式は `guide_04_output_format.md` に従います。

---

## よくあるパターン別チェック例

### Pattern A: Model ロジックのレビュー

**優先度**: セキュリティ > 設計 > テスト

**よくある課題**: コールバックの副作用、バリデーション忘れ、スコープの不適切な定義

**参照ガイド**: `perspective_01_design.md`, `perspective_04_testing.md`

### Pattern B: トランザクション管理のレビュー

**優先度**: セキュリティ > 設計 > テスト

**よくある課題**: トランザクション境界が不明確、ロック戦略がない、コールバック内で外部API呼び出し

**参照ガイド**: `perspective_02_security.md`, `perspective_01_design.md`

### Pattern C: API エンドポイントのレビュー

**優先度**: セキュリティ > 設計 > テスト

**よくある課題**: 入力検証不足、エラーハンドリング不備、認可チェック忘れ

**参照ガイド**: `perspective_02_security.md`, `perspective_01_design.md`

### Pattern D: マイグレーションのレビュー

**優先度**: 設計 > パフォーマンス > セキュリティ

**よくある課題**: データロス、ロールバック不可、ダウンタイムが長い

**参照ガイド**: `perspective_01_design.md`, `perspective_03_performance.md`

---

## タイミング別推奨フロー

### 新規機能開発時

1. 設計をレビュー → テスト戦略を確認 → セキュリティチェック
2. 参照: `perspective_01_design.md` → `perspective_04_testing.md` → `perspective_02_security.md`

### バグ修正時

1. 既存テストへの影響確認 → セキュリティリスク確認
2. 参照: `perspective_04_testing.md` → `perspective_02_security.md`

### パフォーマンス最適化時

1. パフォーマンス分析を確認 → 既存機能への影響確認 → テスト追加
2. 参照: `pattern_08_perf_analysis.md` → `perspective_04_testing.md`

### リファクタリング時

1. 設計改善を確認 → 複雑性の削減を確認 → テスト十分性を確認
2. 参照: `perspective_01_design.md` → `perspective_06_complexity.md` → `perspective_04_testing.md`
