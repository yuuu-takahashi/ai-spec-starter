# ai-spec-starter

Claude Code × 仕様駆動開発のスターターキット。
最小限の構成で、すぐに使える。設定・MCP・仕様テンプレートを厳選してまとめています。

## 含まれるもの

### Claude Code 設定 (`.claude/settings.json`)

- **サンドボックス** — 機密ファイル（`.env`, SSH鍵, AWS認証情報など）の読み取りを禁止
- **権限制御** — allow / ask / deny の3段階でツール実行を管理
- **ステータスライン** — コンテキスト使用量・レート制限をリアルタイム表示
- **プラグイン** — `document-skills` を有効化済み

### MCP サーバー (`.mcp.json`)

| サーバー | 用途 |
|---|---|
| **chrome-devtools** | ブラウザのDevToolsをClaude Codeから操作 |
| **serena** | コードベースのセマンティック解析 |
| **context7** | ライブラリのドキュメント参照 |
| **drawio** | Draw.io 図の作成・編集 |
| **mermaid-mcp** | Mermaid 図の生成 |
| **figma** | Figma デザインとの連携 |
| **playwright** | ブラウザ自動操作・E2Eテスト |

### その他

- **仕様テンプレート** — 機能仕様・画面仕様などのひな形（予定）
- **カスタムスキル** — よく使う操作のスキル定義（予定）

## セットアップ

TODO

## ライセンス

MIT
