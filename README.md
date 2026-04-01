# ai-spec-starter

Claude Code × 仕様駆動開発のスターターキット。
最小限の構成で、すぐに使える。設定・MCP・仕様テンプレートを厳選してまとめています。

## 含まれるもの

### Claude Code 設定 (`.claude/settings.json`)

- **サンドボックス** — 機密ファイル（`.env`, SSH鍵, AWS認証情報など）の読み取りを禁止
- **権限制御** — allow / ask / deny の3段階でツール実行を管理
- **ステータスライン** — コンテキスト使用量・レート制限をリアルタイム表示（`.claude/statusline.sh`）
- **プラグイン** — `document-skills` を有効化済み
- **出力スタイル** — `Explanatory`（教育的な解説付き）
- **プランディレクトリ** — `.claude/plans/` に計画ファイルを保存

### フック (`.claude/hooks/`)

| フック | タイミング | 内容 |
| --- | --- | --- |
| **validate-command.sh** | PreToolUse (Bash) | `rm -rf` や `prod` を含むコマンドをブロック |
| **log-error.sh** | PostToolUseFailure | エラーを `.claude/error-log.jsonl` にJSONL形式で自動記録 |

### カスタムスキル (`.claude/skills/`)

| スキル | 説明 |
| --- | --- |
| **my.fix-skills** | エラーログを分析し、原因スキルを特定して SKILL.md を直接修正する |

### MCP サーバー (`.mcp.json`)

| サーバー | 用途 |
| --- | --- |
| **chrome-devtools** | ブラウザのDevToolsをClaude Codeから操作 |
| **serena** | コードベースのセマンティック解析 |
| **context7** | ライブラリのドキュメント参照 |
| **drawio** | Draw.io 図の作成・編集 |
| **mermaid-mcp** | Mermaid 図の生成 |
| **figma** | Figma デザインとの連携 |
| **playwright** | ブラウザ自動操作・E2Eテスト |

### Serena 設定 (`.serena/`)

- **project.yml** — Serena MCP サーバーのプロジェクト設定（言語サーバー: bash / yaml）

### その他

- **仕様テンプレート** — 機能仕様・画面仕様などのひな形（予定）

## ディレクトリ構成

```text
.
├── .claude/
│   ├── settings.json        # Claude Code 設定
│   ├── statusline.sh        # ステータスライン表示スクリプト
│   ├── hooks/
│   │   ├── validate-command.sh  # Bash コマンド検証
│   │   └── log-error.sh        # エラーログ記録
│   ├── skills/
│   │   └── my.fix-skills/
│   │       └── SKILL.md         # スキル修正スキル
│   ├── plans/               # 計画ファイル置き場
│   ├── agents/              # エージェント定義置き場
│   └── rules/               # ルール定義置き場
├── .serena/
│   └── project.yml          # Serena プロジェクト設定
├── .mcp.json                # MCP サーバー定義
└── README.md
```

## セットアップ

### 前提条件

- [Claude Code](https://docs.claude.com/en/docs/claude-code) がインストール済みであること
- Node.js（npx が使えること）

### 使い方

1. リポジトリをクローンまたはテンプレートとしてコピー
2. プロジェクトルートで `claude` を起動
3. 下記の「動作確認」セクションで各ツールが機能しているか確認

MCP サーバーや設定は自動的に読み込まれます。

## 動作確認

セットアップ後、以下のチェックリストで各ツールが正しく機能しているか確認できます。

### GitHub CLI (`gh`)

Claude Code に以下のように依頼して、GitHub の情報が返ってくることを確認:

- [ ] `このリポジトリの Issue 一覧を見せて` → Issue のタイトル・番号が表示される
- [ ] `最新の PR を見せて` → PR のタイトル・ステータスが表示される

> **未認証の場合**: ターミナルで `gh auth login` を実行してログインしてください。

### MCP サーバー

Claude Code セッション内で `/mcp` を実行し、各サーバーのステータスが表示されることを確認します。

- [ ] `/mcp` を実行 → 接続済みサーバー一覧とツール数が表示される

以下のサーバーが一覧に含まれていれば OK:

- [ ] **context7** — ライブラリドキュメント参照
- [ ] **serena** — コードベースのセマンティック解析
- [ ] **mermaid-mcp** — Mermaid 図の生成
- [ ] **figma** — Figma デザイン連携
- [ ] **drawio** — Draw.io 図の作成・編集
- [ ] **chrome-devtools** — ブラウザ DevTools 操作
- [ ] **playwright** — ブラウザ自動操作・E2Eテスト

> **補足**
>
> - **figma** は事前に Figma のアクセストークン設定が必要です
> - サーバーが `error` 状態の場合、`/mcp` の出力でエラー詳細を確認できます

### フック

- [ ] **validate-command.sh** — Claude Code に `rm -rf / を実行して` と依頼 → ブロックされてコマンドが実行されない
- [ ] **log-error.sh** — ツール実行エラー発生後、`.claude/error-log.jsonl` にエラーが JSONL 形式で記録されている

### ステータスライン

- [ ] Claude Code 起動後、画面下部にコンテキスト使用量・レート制限がリアルタイム表示されている

> 表示されない場合は `chmod +x .claude/statusline.sh` で実行権限を付与してください。

## Markdown lint

Markdown は `markdownlint-cli2` で lint できます。

```bash
npm install
npm run lint:md
```

`./.markdownlint-cli2.jsonc` で設定しており、現状は行長チェック (`MD013`) のみ無効化しています。

## ライセンス

MIT
