# .claude/ ディレクトリ概要

このディレクトリには Claude Code の設定ファイルとカスタムスキルが格納されています。

---

## settings.json

プロジェクト固有の Claude Code 設定ファイルです。主要セクションは以下のとおりです。

### permissions

ツール実行の権限を 3 層で管理します。

| レイヤー | 説明 | 例 |
| -------- | ---- | -- |
| **allow** | 確認なしで自動実行 | `Read(*)`, `Edit(*)`, `Bash(git status:*)` など |
| **ask** | 実行前にユーザー確認を求める | `Bash(npm:*)`, `Bash(docker:*)`, `Bash(gh:*)` など |
| **deny** | 常にブロック | シークレットファイル読取り (`~/.ssh/**`, `**/.env` 等)、破壊的操作 (`rm -rf`, `git push`, `git.*force` 等) |

### hooks

ツール実行の前後に自動で走るシェルスクリプトを定義します。

- **PreToolUse (Bash)** — `.claude/hooks/validate-command.sh` でコマンドを事前検証
- **PostToolUseFailure** — `.claude/hooks/log-error.sh` でエラーをログ記録

### MCP サーバー

有効化されている MCP サーバー一覧です。

| サーバー | 用途 |
| -------- | ---- |
| chrome-devtools | Chrome DevTools 操作 |
| serena | セマンティックコード解析 |
| context7 | ライブラリドキュメント取得 |
| drawio | draw.io 図の生成・編集 |
| mermaid-mcp | Mermaid 図の検証・レンダリング |
| figma | Figma デザイン連携 |
| playwright | ブラウザ自動操作・テスト |

---

## skills/

カスタムスキル（スラッシュコマンド）の定義ディレクトリです。各スキルは `skills/<名前>/SKILL.md` に配置されます。

| スキル | コマンド | 説明 |
| ------ | -------- | ---- |
| **my.markdown** | `/my.markdown` | Markdown ドキュメントの構造化・Mermaid 図埋め込み |
| **my.docs** | `/my.docs` | 会話・エラー解析・アイデアを Markdown として保存・整理 |
| **my.github** | `/my.github` | GitHub リポジトリ情報（Issue, PR, リリース等）の取得・表示 |
| **my.pr-fix** | `/my.pr-fix` | PR の CI 失敗やレビューコメントの分析・修正 |
| **my.fix-skills** | `/my.fix-skills` | エラーログから原因スキルを特定し SKILL.md を修正 |
