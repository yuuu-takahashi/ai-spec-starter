---
title: レビュー出力形式
tags: rails, review, output, format
---

<!-- markdownlint-disable MD025 -->

# レビュー出力形式

Rails コードレビューではこの形式に従う。

## 基本ルール

- findings を先に出す
- 重要度順に並べる
- 各指摘に file/line を付ける
- 「なぜ問題か」と「どう直すか」を短く書く
- 問題がなければその旨を明示する

## 推奨フォーマット

```markdown
1. [must] 問題の要約
   - File: path:line
   - Reason: 何が壊れるか
   - Fix: 最短の修正方針

2. [want] 改善案
   - File: path:line
   - Reason: 保守性や性能の観点
   - Fix: 望ましい形
```

## ラベル

- `[must]`: バグ、セキュリティ、データ破壊、明確な仕様逸脱
- `[want]`: 設計、性能、保守性の改善
- `[nits]`: 軽微な可読性や表現の改善
- `[ask]`: 前提確認が必要
- `[info]`: 共有だけしておきたいこと

## 末尾に置いてよいもの

- open questions
- 前提や未確認事項
- 変更全体の短いまとめ
