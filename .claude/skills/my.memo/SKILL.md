---
name: my.memo
description: |
  会話の要点、エラー解析、アイデア、決定事項をサッと Markdown メモに残すスキル。
  入力内容を見てメモタイプを自動判定し、要約・決定・学び・次のアクションを構造化して保存する。
  保存先キー、タイトル、タグを確認してからファイルを生成する。
compatibility: |
  - Markdown の新規ファイル・フォルダ作成
  - `my.markdown` による構造化出力
  - メタデータ収集・thread log からの抜粋
  - ファイルシステム操作
---

# Overview

`my.memo` は会話やアイデアを素早く Markdown メモに残すためのスキルです。入力内容を見て最適なメモタイプに切り替え、後から読み返せる形に整理して保存します。出力先は `.knowledge/` 配下に寄せて運用します（`paths.md` の `KNOWLEDGE_BASE` を参照）。

基本方針:

- 会話・作業ログ → 要点、決定、次のアクションを残す
- エラー → 原因、解決策、学びを残す
- アイデア → コンセプト、用途、次の掘り下げ先を残す
- 決定事項 → 背景、結論、理由をセットで残す
- 必要なら Mermaid 図や補助画像を使う

## When to use

- 会話の要点を所定の出力先にメモしたいとき
- 実装方針、決定事項、hand-off、振り返りを整理したいとき
- エラー解析やスタックトレースの理解を記録したいとき
- アイデアやコンセプトを短時間でメモしたいとき

## Memo types

`my.memo` はコマンド名を増やさず、内容によってメモタイプを切り替える。

1. **Thread memo** — 通常の会話、技術的議論、タスク整理、設計相談
2. **Decision memo** — 実装方針の比較、引き継ぎ、レビュー観点、作業メモ
3. **Error memo** — エラーメッセージ、スタックトレース、失敗ログが中心
4. **Idea memo** — 短い発想、構想、提案、仮説メモ

判定に迷う場合はユーザーに確認する。明示指定があればそれを優先する。

## Detection rules

以下の順に判定する。

1. **明示指定がある**
   - 例: 「error として保存」「アイデアメモにして」「hand-off にまとめて」
2. **入力にエラーやログが含まれる**
   - 判定シグナル: `Error:`, `Exception`, `TypeError`, `NoMethodError`, `Traceback`, `Cannot read properties`, `at ...`, stack trace, build log
   - → `Error memo`
3. **入力が短文の発想メモに近い**
   - 判定シグナル: 「アイデア」「思いついた」「案」「こういうの」「〜したい」「〜できないかな」
   - → `Idea memo`
4. **議論の結論や引き継ぎが主目的**
   - 判定シグナル: 「決定事項」「引き継ぎ」「handoff」「レビュー観点」「やること整理」
   - → `Decision memo`
5. **上記に当てはまらない**
   - → `Thread memo`

## Workflow

1. **Capture** — このスレッドの質問、回答、TODO、決定事項、ログを拾う
2. **Classify** — 内容からメモタイプを決める
3. **Draft** — タイトル、保存先キー、セクション、タグを決める
4. **Format** — 必要なら `my.markdown` を使って見出し、箇条、表、図の構成を整える
5. **Save** — `.claude/skills/paths.md` を参照し、適切なキーの保存先に保存する
6. **Metadata** — title, date, tags, related-skills, related-paths を冒頭に残す

保存先と命名規則は `.claude/skills/paths.md` を参照する。

## Output patterns

### 1. Thread memo

```markdown
# <テーマ>

## Summary

## Key Decisions

## Discussion Flow

## Open Questions

## Next Steps

## References
```

### 2. Decision memo

```markdown
# <テーマ>

## Background

## Decision

## Reasoning

## Impact

## Open Items

## Next Actions
```

### 3. Error memo

```markdown
# エラー分析: <エラー名>

## Error

## Cause

## Fix

## Learnings

## Debug Notes

## Further Exploration
```

### 4. Idea memo

```markdown
# <アイデア名>

## Concept

## Potential Use Cases

## Constraints / Risks

## Next Exploration
```

## Writing rules

- ユーザー発話はそのまま大量に転記しない。必要なら中立な見出しに置き換える
- 決定事項は「結論」と「理由」をセットで残す
- 再現に必要なコマンド、ファイルパス、設定、バージョンは省略しない
- 長い会話は `Summary` と `Next Steps` だけに潰さず、論点や未解決事項も分ける
- エラー分析では連鎖エラーより根本原因を優先する
- アイデアメモは短くても、利用シーンか次の検証項目を最低1つ入れる
- 保存先はパス文字列で埋め込まず、まず `.claude/skills/paths.md` のキーで判断する

## Save mapping

- `Thread memo` → `DOCS`
- `Decision memo` → `DOCS`（作業途中の hand-off や thread log は `KNOWLEDGE_ROOT`）
- `Error memo` → `ERROR_ANALYSIS`
- `Idea memo` → `IDEA`

ファイル名パターンも `.claude/skills/paths.md` の命名規則を参照する。

## Troubleshooting

- **図が不要**: Mermaid を使わず箇条書きで表現する
- **会話が長い**: 論点ごとに分けて、最後に決定事項と TODO を再集約する
- **分類が曖昧**: `Thread memo` を基本にして、不足する観点だけ `Error` や `Idea` の章を混ぜる

## References

- `my.markdown` for structure and formatting
- Paths and naming rules: `.claude/skills/paths.md`
- Mermaid diagram guidance: `.claude/skills/my.markdown/references/diagram-guide.md`
