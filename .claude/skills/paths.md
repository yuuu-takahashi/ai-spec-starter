# Paths

`.claude/skills` 配下のスキルが参照する、保存先と命名規則の共通定義。

## 共通ベースパス

| 変数 | パス | 備考 |
| --- | --- | --- |
| `KNOWLEDGE_BASE` | `.knowledge/` | ドキュメント系出力の共通ルート |

## 出力先一覧

| キー | パス | 用途 | 使用スキル |
| ------ | ------ | ------ | ------------ |
| `DOCS` | `${KNOWLEDGE_BASE}/docs/` | 会話サマリー・技術決定（docs モード） | `my.docs` |
| `ERROR_ANALYSIS` | `${KNOWLEDGE_BASE}/errors/` | エラー分析レポート（error モード） | `my.docs`, `my.fix-skills` |
| `IDEA` | `${KNOWLEDGE_BASE}/ideas/` | アイデアメモ（idea モード） | `my.docs` |
| `KNOWLEDGE_ROOT` | `${KNOWLEDGE_BASE}/` | 汎用プラン、hand-off、thread log | `my.docs` |
| `ERROR_LOG` | `.claude/error-log.jsonl` | フックが記録するエラーログ | `my.fix-skills` |
| `RULES` | `.claude/rules/` | エージェントルール置き場 | 複数スキル |
| `AGENTS` | `.claude/agents/` | エージェント定義置き場 | 複数スキル |
| `SKILLS` | `.claude/skills/` | スキル定義と参照ファイル | 複数スキル |
| `PROJECT_DOC` | `README.md` | このリポジトリの概要ドキュメント | 複数スキル |

## ファイル命名規則

| スキル | ファイル名パターン |
| -------- | ------------------- |
| `my.docs` (docs) | `docs-YYYY-MM-DD-{topic}.md` |
| `my.docs` (error) | `error-YYYY-MM-DD-{error-name}.md` |
| `my.docs` (idea) | `idea-YYYY-MM-DD-{title}.md` |
| `my.docs` (hand-off / thread log) | `thread-YYYY-MM-DD-{topic}.md` |
| `my.fix-skills` | `fix-skills-YYYY-MM-DD-{topic}.md` |

## Notes

- このリポジトリではドキュメント系の出力先を `KNOWLEDGE_BASE` 配下に集約する
- `KNOWLEDGE_BASE` を変更する場合は各スキルの参照先も合わせて更新する
- 新しいスキルを追加する場合も、まず既存キーで足りるかを確認する
- 新しい保存先が必要なら、先にこのファイルへキーを追加してから `SKILL.md` 側で参照する
