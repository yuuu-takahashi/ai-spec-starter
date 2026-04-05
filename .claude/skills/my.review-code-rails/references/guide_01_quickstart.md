---
title: クイックスタート - Rails コードレビュー実行ガイド
tags: rails, review, quickstart
---

<!-- markdownlint-disable MD025 MD040 -->

## クイックスタート - Rails コードレビュー実行ガイド

このスキルを初めて使う場合、ここから始めてください。

## 基本フロー（3ステップ）

```text
1. Rails コードを読む
   ↓
2. 「このコード、Rails 的にどうだろう？」と思ったら、このスキルを呼び出す
   ↓
3. よくある使用シーンの表から、参照すべきファイルを選んでチェック
```

## よくある使用シーン

| シーン                         | 参照すべきファイル                                             |
| ------------------------------ | -------------------------------------------------------------- |
| **RSpec テスト設計**           | `perspective_04_testing.md` + `perspective_06_complexity.md`   |
| **API エンドポイント実装**     | `perspective_01_design.md` + `perspective_02_security.md`      |
| **パフォーマンス最適化**       | `pattern_08_perf_analysis.md` + `perspective_03_performance.md`|
| **ドメイン設計**               | `pattern_06_ddd.md` + `perspective_01_design.md`               |
| **セキュリティ脆弱性**         | `perspective_02_security.md`                                   |

## レビュー観点（優先度順）

| 優先度         | 観点           | 説明                         | ファイル                        |
| -------------- | -------------- | ---------------------------- | ------------------------------- |
| **Must**       | 設計           | 責務分離、アーキテクチャ     | `perspective_01_design.md`      |
| **Must**       | セキュリティ   | SQLi, XSS, CSRF, 認証・認可  | `perspective_02_security.md`    |
| **Should**     | パフォーマンス | N+1, クエリ効率, メモリ      | `perspective_03_performance.md` |
| **Should**     | テスト         | テスト品質, カバレッジ       | `perspective_04_testing.md`     |
| **Supporting** | 命名           | Rails 命名慣習, 意図の明確性 | `perspective_05_naming.md`      |
| **Supporting** | 複雑性         | 認知的負荷, メソッド長       | `perspective_06_complexity.md`  |

スタイル（インデント、フォーマット）は RuboCop に委譲する。

## よくある質問

### Q: どのルールから始めればいい？

A: よくある使用シーン表から、あなたのケースに最も近いものを選んでください。

### Q: すべてのルールを確認する必要がある？

A: いいえ。変更内容に関連する観点だけで十分です。

### Q: 出力形式は？

A: `guide_04_output_format.md` のラベル形式（`[must]`, `[want]`, `[nits]`）で整理してください。

## 次のステップ

- **詳細なレビューワークフロー** → `guide_02_workflow.md`
- **パターン別レビュー方法** → `guide_03_patterns.md`
- **出力形式** → `guide_04_output_format.md`
