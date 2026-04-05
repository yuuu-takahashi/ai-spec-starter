# CLAUDE.md

このファイルは Claude Code がプロジェクトを読み込む際に自動参照するコンテキストファイルです。

## プロジェクト概要

Claude Code の設定・スキル・ルール・エージェントを一元管理するスターターキットです。
他プロジェクトからシンボリックリンク（または Dev Container の bind mount）で `.claude/` を参照して使います。

## 利用形態

- **シンボリックリンク**: `ln -s ~/workspace/ai-spec-starter/.claude ~/workspace/<project>/.claude`
- **Dev Container**: `"mounts": ["source=${localWorkspaceFolder}/../ai-spec-starter/.claude,target=/workspace/.claude,type=bind"]`
- リンクの管理には `/my.symlink-manager` を使用

## ディレクトリ構成

```text
.claude/
├── CLAUDE.md              # このファイル（プロジェクトコンテキスト）
├── README.md              # .claude/ の詳細リファレンス
├── settings.json          # 権限・フック・MCP・プラグイン設定
├── settings.local.json    # ローカル上書き設定（git 管理外推奨）
├── statusline.sh          # ステータスライン表示スクリプト
├── hooks/
│   ├── validate-command.sh   # Bash コマンド事前検証（PreToolUse）
│   └── log-error.sh          # エラーログ記録（PostToolUseFailure）
├── skills/
│   ├── paths.md              # 出力先パスの共通定義
│   └── my.*/SKILL.md         # カスタムスキル（24 件）
├── agents/                # エージェント定義（5 件）
├── rules/                 # ルールファイル（24 件）
├── plans/                 # 計画ファイル置き場
└── memory/                # 永続メモリ（自動管理）
```

## 設定の要点

### 権限モデル（settings.json）

| レイヤー | 方針 |
| --- | --- |
| allow | Read/Edit/Write/Glob/Grep、git status/diff/log は自動実行 |
| ask | npm/docker/gh/bundle 等の副作用コマンドは確認を挟む |
| deny | シークレット読取り、破壊的 git 操作、rm -rf は常にブロック |

### フック

- **PreToolUse**: `validate-command.sh` — 危険なコマンドをブロック
- **PostToolUseFailure**: `log-error.sh` — エラーを `.claude/error-log.jsonl` に記録

### 出力先

ファイル出力を行うスキルは `skills/paths.md` の共通定義に従います。
基本的に `.knowledge/` 配下に集約されます。詳細は `skills/paths.md` を参照してください。

## スキル一覧

全スキルの詳細は `.claude/README.md` を参照。主要カテゴリ:

| カテゴリ | スキル例 |
| --- | --- |
| 記事・ドキュメント | my.markdown, my.memo |
| コードレビュー | my.code-review, my.review-code-react, my.review-code-rails, my.review-config |
| Git / GitHub | my.branch-name, my.commit-message, my.github, my.pr-fix |
| 開発環境・インフラ | my.devcontainer, my.docker, my.port, my.cloudwatch |
| テスト | my.e2e-playwright |
| 外部連携 | my.notion, my.drawio |
| ユーティリティ | my.mentor, my.tech-news, my.stack-review, my.symlink-manager |
| Claude Code 管理 | my.claude-manager, my.fix-skills, my.rules-creator |

## エージェント

`.claude/agents/` に定義。ルートの `AGENTS.md` からもこのセクションを参照しています。

| エージェント | 定義ファイル | 用途 |
| --- | --- | --- |
| code-review | `.claude/agents/code-review.md` | PR やコード変更を汎用的にレビュー |
| review-config | `.claude/agents/review-config.md` | Dockerfile, CI, ESLint 等の設定ファイルをレビュー |
| review-rails | `.claude/agents/review-rails.md` | Rails / RSpec のコード変更をレビュー |
| review-react | `.claude/agents/review-react.md` | Next.js / React のコード変更をレビュー |
| tech-news | `.claude/agents/tech-news.md` | 直近 1 週間の技術ニュースを収集し TOP 10 にまとめる |

## ルール

`.claude/rules/` に 24 件のルールファイルを配置。各ルールは `paths:` frontmatter でスコープを限定しています。
カテゴリ: Rails（11 件）、React（8 件）、Next.js（3 件）、共通（2 件）。
