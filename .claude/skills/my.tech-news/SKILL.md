---
name: my.tech-news
description: |
  直近1週間の技術ニュース（Rails, React, Claude, Cursor, AI, Next.js, TypeScript, Ruby など）を
  Web 検索で収集し、重要度順 TOP 10 にまとめて ${KNOWLEDGE_BASE}/docs/ に保存するスキル。
  「最新ニュース」「今週の技術トピック」「tech news」「最近のアップデート」「新着情報まとめ」
  「Rails の最新」「React の動向」「AI ニュース」「Cursor アップデート」「Claude 新機能」
  など、技術トレンドやリリース情報の収集・まとめを求められたときに積極的にこのスキルを使うこと。
  定期実行（/loop, /schedule）との組み合わせも想定している。
compatibility: |
  - WebSearch（必須）— ニュースソースの検索
  - WebFetch（任意）— 詳細ページの取得
  - ファイルシステム操作 — Markdown ファイルの書き出し
---

# Overview

`my.tech-news` は、開発者が追いかけるべき直近1週間の技術ニュースを Web 検索で収集し、
重要度の高い順に TOP 10 を選定して `.knowledge/docs/` に Markdown ファイルとして保存するスキルです。

対象とするトピックのデフォルト:

- **フレームワーク**: Rails, React, Next.js
- **言語**: Ruby, TypeScript, JavaScript
- **AI ツール**: Claude, Cursor, GitHub Copilot, ChatGPT, その他 AI コーディングツール
- **AI 全般**: LLM, AI Agent, MCP, 生成 AI の主要ニュース

ユーザーが追加トピックを指定した場合はそれも含める。

## When to use

- 「最新ニュースまとめて」「今週の技術トピック教えて」と言われたとき
- 「Rails / React / AI の最近の動き」を聞かれたとき
- 定期的なニュース収集タスクとして `/loop` や `/schedule` から呼ばれたとき
- 特定技術の最新リリースやアップデートを知りたいとき

## Workflow

### 1. Search — ニュースを収集する

以下のカテゴリごとに WebSearch を並列実行する。検索クエリには `after:YYYY-MM-DD`（1週間前の日付）を含めて鮮度を確保する。

**検索カテゴリと推奨クエリ例**（今日が 2026-04-05 なら `after:2026-03-29`）:

| カテゴリ | 検索クエリ例 |
| --------- | ------------- |
| Rails | `Ruby on Rails news release update after:YYYY-MM-DD` |
| React / Next.js | `React Next.js release update news after:YYYY-MM-DD` |
| Claude / Anthropic | `Claude Anthropic AI update news after:YYYY-MM-DD` |
| Cursor | `Cursor AI editor update news after:YYYY-MM-DD` |
| AI 全般 | `AI LLM agent news this week after:YYYY-MM-DD` |
| 追加トピック | ユーザー指定があればここに追加 |

各カテゴリで 3〜5 件の有力な結果をピックアップする。

### 2. Evaluate — 重要度で選定する

収集した候補から以下の基準で TOP 10 を選ぶ:

1. **インパクト** — 多くの開発者に影響するか（メジャーリリース、破壊的変更、新機能）
2. **鮮度** — 直近1週間以内に公開・発表されたか
3. **関連性** — このプロジェクト（Rails + Next.js + AI ツール活用）に関係するか
4. **話題性** — コミュニティで広く議論されているか

迷ったら「自分が月曜の朝に同僚に共有したいか」で判断する。

### 3. Format — TOP 10 をまとめる

以下のテンプレートで Markdown を生成する:

```markdown
---
title: "Tech News TOP 10: YYYY-MM-DD 週"
date: YYYY-MM-DD
tags: [tech-news, weekly]
topics: [rails, react, claude, cursor, ai]
period: "YYYY-MM-DD 〜 YYYY-MM-DD"
---

# Tech News TOP 10: YYYY-MM-DD 週

> 対象期間: YYYY-MM-DD（月）〜 YYYY-MM-DD（日）

## 1. [ニュースタイトル]

- **カテゴリ**: Rails / React / AI / Cursor / その他
- **ソース**: [リンクテキスト](URL)
- **要約**: 2〜3 文でニュースの内容と影響を説明

## 2. [ニュースタイトル]

...（10 件まで繰り返し）

---

## Honorable Mentions

TOP 10 に入らなかったが注目すべきニュースがあれば、箇条書きで 3〜5 件追加する。

## Sources

- 参照した主要ソースの URL リスト
```

### 4. Save — ファイルを保存する

- **保存先**: `${KNOWLEDGE_BASE}/docs/` = `.knowledge/docs/`
- **ファイル名**: `news-YYYY-MM-DD-weekly-tech-top10.md`
  - YYYY-MM-DD はスキル実行日（≒ 対象週の最終日付近）
- 保存先ディレクトリが存在しない場合は作成する
- 保存後、ファイルパスをユーザーに報告する

### 5. Present — 結果を表示する

保存した内容の要約（TOP 3 のハイライト + 残り 7 件のタイトル一覧）を会話内に表示する。
全文を表示する必要はない — ユーザーがファイルを開けば読める。

## Customization

- ユーザーが「Rails だけ」「AI 関連だけ」と絞り込んだ場合は、該当カテゴリのみ検索する
- 件数の指定があれば TOP 10 でなくその件数に合わせる
- `news-` 接頭辞は固定、接尾辞はトピックに応じて変更可
  - 例: `news-2026-04-05-rails-updates.md`（Rails 限定の場合）

## Notes

- 検索結果の情報は公開 Web ページに基づく。正確性はソース次第なので、重要な情報は原文リンクを必ず付ける
- 同じ週に複数回実行した場合、ファイルは上書きではなく別名で保存する（タイムスタンプで区別）
- ニュースの要約は客観的に書く。個人的な評価やおすすめは `Honorable Mentions` のコメントに留める

## References

- Paths and naming rules: `.claude/skills/paths.md`
