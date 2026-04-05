---
title: パフォーマンス
impact: MEDIUM
tags: rails, review-code, performance
---

## パフォーマンス

レビュー時のパフォーマンス確認チェックリスト。
実装規約の詳細は `.claude/rules/rails-performance.md` と `.claude/rules/rails-activerecord.md` を参照。

> **関連**: 設計面は `perspective_01_design.md`、テスト速度は `perspective_04_testing.md` を参照。

### データベース

- [ ] **N+1 問題**: 関連データの取得で `includes` / `preload` / `eager_load` が使われているか
- [ ] **インデックス**: `where` 条件のカラムにインデックスがあるか
- [ ] **バッチ処理**: 大量データで `find_each` が使われているか（`all.each` になっていないか）
- [ ] **クエリ最適化**: 集計が Ruby ではなく DB で行われているか（`count`, `sum`, `group`）
- [ ] **select/pluck**: 必要なカラムのみ取得しているか（BLOB/TEXT の不要な読み込みがないか）

### メモリ使用

- [ ] **一括読み込み**: 大量データを `to_a` で配列化していないか
- [ ] **ストリーミング**: 大きなファイルをストリーミング処理しているか
- [ ] **オブジェクト生成**: ループ内での不要な文字列連結がないか

### 非同期処理

- [ ] **非同期化**: 重い処理（メール送信、外部 API、ファイル処理）が ActiveJob に移されているか
- [ ] **冪等性**: ジョブがリトライ可能な設計か
- [ ] **キュー選択**: 処理の優先度に応じたキューが使われているか
