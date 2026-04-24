# .claude/ ディレクトリ概要

このディレクトリには Claude Code の設定ファイルとカスタムスキルが格納されています。

---

## settings.json

プロジェクト固有の Claude Code 設定ファイルです。主要セクションは以下のとおりです。

### permissions

ツール実行の権限を 3 層で管理します。

| レイヤー  | 説明                         | 例                                                                                                         |
| --------- | ---------------------------- | ---------------------------------------------------------------------------------------------------------- |
| **allow** | 確認なしで自動実行           | `Read(*)`, `Edit(*)`, `Bash(git status:*)` など                                                            |
| **ask**   | 実行前にユーザー確認を求める | `Bash(npm:*)`, `Bash(docker:*)`, `Bash(gh:*)` など                                                         |
| **deny**  | 常にブロック                 | シークレットファイル読取り (`~/.ssh/**`, `**/.env` 等)、破壊的操作 (`rm -rf`, `git push`, `git.*force` 等) |

### hooks

ツール実行の前後に自動で走るシェルスクリプトを定義します。

- **PreToolUse (Bash)** — `.claude/hooks/validate-command.sh` でコマンドを事前検証
- **PostToolUseFailure** — `.claude/hooks/log-error.sh` でエラーをログ記録

### MCP サーバー

有効化されている MCP サーバー一覧です。

| サーバー        | 用途                           |
| --------------- | ------------------------------ |
| chrome-devtools | Chrome DevTools 操作           |
| serena          | セマンティックコード解析       |
| context7        | ライブラリドキュメント取得     |
| drawio          | draw.io 図の生成・編集         |
| mermaid-mcp     | Mermaid 図の検証・レンダリング |
| figma           | Figma デザイン連携             |
| notion          | Notion ワークスペース操作      |
| playwright      | ブラウザ自動操作・テスト       |

---

## skills/

カスタムスキル（スラッシュコマンド）の定義ディレクトリです。各スキルは `skills/<名前>/SKILL.md` に配置されます。

### 記事・ドキュメント系

| スキル | 説明 |
| --- | --- |
| my.markdown | Markdown ドキュメントの構造化・Mermaid 図埋め込み |
| my.memo | 会話の要点・エラー解析・アイデアをサッと Markdown メモに残す |

### コードレビュー系

| スキル | 説明 |
| --- | --- |
| my.code-review | Google エンジニアリングプラクティスに基づく汎用コードレビュー |
| my.review-code-react | Next.js / React 特化のコードレビュー |
| my.review-code-rails | Ruby on Rails / RSpec 特化のコードレビュー |
| my.review-config | 設定ファイル（Dockerfile, CI, ESLint, tsconfig 等）のレビュー |

### Git / GitHub 系

| スキル | 説明 |
| --- | --- |
| my.branch-name | チケット番号やキーワードからブランチ名を生成・チェックアウト |
| my.commit-message | Conventional Commits 形式のコミットメッセージを自動生成 |
| my.github | GitHub リポジトリ情報（Issue, PR, リリース等）の取得・表示 |
| my.pr-fix | PR の CI 失敗やレビューコメントの分析・修正 |

### 開発環境・インフラ系

| スキル | 説明 |
| --- | --- |
| my.devcontainer | Dev Container の build/up/exec 検証と設定修正 |
| my.docker | Docker リソース（コンテナ・ボリューム・イメージ等）のクリーンアップ |
| my.port | ポート使用状況の確認・空きポート検索・プロセス終了 |
| my.cloudwatch | AWS CloudWatch Logs Insights クエリの生成 |

### テスト系

| スキル | 説明 |
| --- | --- |
| my.e2e-playwright | Playwright E2E テストの設計・実装・実行・デバッグ |

### 外部サービス連携系

| スキル | 説明 |
| --- | --- |
| my.notion | Notion の検索・ページ作成・編集・DB 操作 |
| my.drawio | draw.io の図を XML 形式で生成・編集 |

### ユーティリティ系

| スキル | 説明 |
| --- | --- |
| my.mentor | 技術的な行き詰まりの思考整理・意思決定支援 |
| my.tech-news | 直近 1 週間の技術ニュースを収集し TOP 10 にまとめる |
| my.stack-review | 技術スタックの見直し・技術選定の支援 |
| my.symlink-manager | リポジトリ関連のシンボリックリンク管理 |

### Claude Code 管理系

| スキル | 説明 |
| --- | --- |
| my.claude-manager | .claude/ 配下の設定を一元管理（一覧・整合性チェック・レポート） |
| my.fix-skills | エラーログから原因スキルを特定し SKILL.md を修正 |
| my-rules-creator | ルールファイル（.claude/rules/*.md）の生成・編集・削除 |
