# Paths

`.claude/skills` 配下のスキルが参照する、保存先と命名規則の共通定義。

## 共通ベースパス

| 変数             | パス          | 備考                           |
| ---------------- | ------------- | ------------------------------ |
| `KNOWLEDGE_BASE` | `.knowledge/` | ドキュメント系出力の共通ルート |

## 出力先・命名規則

| キー             | パス                                        | 用途                                | 使用スキル                  | ファイル名パターン                 |
| ---------------- | ------------------------------------------- | ----------------------------------- | --------------------------- | ---------------------------------- |
| `DOCS`           | `${KNOWLEDGE_BASE}/docs/`                   | 会話サマリー・技術決定              | `my.memo` (docs)            | `docs-YYYY-MM-DD-{topic}.md`       |
|                  |                                             | 週次技術ニュース TOP 10             | `my.tech-news`              | `news-YYYY-MM-DD-{topic}.md`       |
| `ERROR_ANALYSIS` | `${KNOWLEDGE_BASE}/errors/`                 | エラー分析レポート                  | `my.memo` (error)           | `error-YYYY-MM-DD-{error-name}.md` |
|                  |                                             |                                     | `my.fix-skills`             | `fix-skills-YYYY-MM-DD-{topic}.md` |
| `IDEA`           | `${KNOWLEDGE_BASE}/ideas/`                  | アイデアメモ                        | `my.memo` (idea)            | `idea-YYYY-MM-DD-{title}.md`       |
| `REVIEWS`        | `${KNOWLEDGE_BASE}/records/reviews/`        | コードレビューレポート              | `my.code-review` (PR)       | `pr-{number}-{short-desc}.md`      |
|                  |                                             |                                     | `my.code-review` (ローカル) | `{YYYY-MM-DD}-{short-desc}.md`     |
|                  |                                             |                                     | `my.review-code-react`      | 同上（React/Next.js 特化レビュー） |
|                  |                                             |                                     | `my.review-code-rails`      | 同上（Rails/RSpec 特化レビュー）   |
| `CONFIG_REVIEW`  | `${KNOWLEDGE_BASE}/records/config-reviews/` | 設定ファイルレビューレポート        | `my.review-config`          | `{YYYY-MM-DD}-{type}-review.md`    |
| `RECORDS`        | `${KNOWLEDGE_BASE}/records/`                | 設定リンタ等、`reviews/` 以外の記録 | `my.claude-manager`         | 運用で命名（例: 日付入りレポート） |
| `SYMLINK_REPORT` | `./symlink-report.md` (repository root)     | シンボリックリンク整理レポート      | `my.symlink-manager`        | デフォルト固定名（要望で変更可）   |
| `KNOWLEDGE_ROOT` | `${KNOWLEDGE_BASE}/`                        | 汎用プラン、hand-off、thread log    | `my.memo` (hand-off 等)     | `thread-YYYY-MM-DD-{topic}.md`     |
| `ERROR_LOG`      | `.claude/error-log.jsonl`                   | フックが記録するエラーログ          | `my.fix-skills`             | —                                  |
| `RULES`          | `.claude/rules/`                            | エージェントルール置き場            | 複数スキル                  | —                                  |
| `AGENTS`         | `.claude/agents/`                           | エージェント定義置き場              | 複数スキル                  | —                                  |
| `SKILLS`         | `.claude/skills/`                           | スキル定義と参照ファイル            | 複数スキル                  | —                                  |
| `PROJECT_DOC`    | `README.md`                                 | このリポジトリの概要ドキュメント    | 複数スキル                  | —                                  |

## Notes

- このリポジトリではドキュメント系の出力先を `KNOWLEDGE_BASE` 配下に集約する
- `KNOWLEDGE_BASE` を変更する場合は各スキルの参照先も合わせて更新する
- 新しいスキルを追加する場合も、まず既存キーで足りるかを確認する
- 新しい保存先が必要なら、先にこのファイルへキーを追加してから `SKILL.md` 側で参照する
