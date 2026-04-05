# ai-spec-starter

Claude Code の設定・スキル・ルール・エージェントを一元管理するスターターキット。
他プロジェクトからシンボリックリンクで参照して使います。

設定・スキル・エージェント・ルールの詳細は [.claude/CLAUDE.md](.claude/CLAUDE.md) を参照してください。

## セットアップ

### 前提条件

- [Claude Code](https://docs.claude.com/en/docs/claude-code) がインストール済みであること
- Node.js（npx が使えること）
- GitHub CLI（`gh auth login` 済み）

### 1. クローン

```bash
git clone <repo-url> ~/workspace/ai-spec-starter
```

### 2. シンボリックリンクを作成

対象プロジェクトから `.claude/` と `.mcp.json` をリンクします。

```bash
ln -s ~/workspace/ai-spec-starter/.claude ~/workspace/my-project/.claude
ln -s ~/workspace/ai-spec-starter/.mcp.json ~/workspace/my-project/.mcp.json
```

リンクの作成・検査・整理には `/my.symlink-manager` スキルが使えます。

### 3. 起動

```bash
cd ~/workspace/my-project && claude
```

MCP サーバーや設定は自動的に読み込まれます。

### Dev Container での利用

Dev Container 環境では、シンボリックリンクの代わりに **bind mount** で `.claude/` をコンテナ内にマウントします。

`.devcontainer/devcontainer.json`:

```jsonc
{
  "mounts": [
    "source=${localWorkspaceFolder}/../ai-spec-starter/.claude,target=/workspace/.claude,type=bind"
  ]
}
```

> `${localWorkspaceFolder}` はホスト側のワークスペースパスに展開されます。`ai-spec-starter` の配置場所に合わせてパスを調整してください。

## 動作確認

セットアップ後のチェックリスト:

### MCP サーバー

`/mcp` を実行し、以下のサーバーが接続済みであることを確認:

- [ ] context7 — ライブラリドキュメント参照
- [ ] serena — セマンティックコード解析
- [ ] mermaid-mcp — Mermaid 図の生成
- [ ] figma — Figma デザイン連携（要アクセストークン）
- [ ] notion — Notion ワークスペース操作
- [ ] drawio — Draw.io 図の作成・編集
- [ ] chrome-devtools — ブラウザ DevTools 操作
- [ ] playwright — ブラウザ自動操作・E2E テスト

### フック

- [ ] `rm -rf / を実行して` と依頼 → validate-command.sh がブロック
- [ ] ツール実行エラー後、`.claude/error-log.jsonl` に記録がある

### ステータスライン

- [ ] 画面下部にコンテキスト使用量・レート制限が表示されている

> 表示されない場合: `chmod +x .claude/statusline.sh`

## Markdown lint

```bash
npm install
npm run lint:md
```

`.markdownlint-cli2.jsonc` で設定。行長チェック (`MD013`) は無効化しています。

## ライセンス

MIT
