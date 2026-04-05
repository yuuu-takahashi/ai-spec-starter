# 設定レビュー: リファレンス索引

チェック対象のファイル種別から、読む `*.md` を特定する。複数にまたがる場合は両方読む。

| 検出キーワード / ファイル例 | リファレンス |
| --- | --- |
| `Dockerfile` | [docker.md](docker.md) |
| `docker-compose.yml`, `compose.yml` | [docker.md](docker.md) |
| `.dockerignore` | [docker.md](docker.md) |
| `.devcontainer/devcontainer.json` | [devcontainer.md](devcontainer.md) |
| `.github/workflows/*.yml`, `.gitlab-ci.yml`, `.circleci/config.yml` | [ci.md](ci.md) |
| ESLint（`eslint.config.*`, `.eslintrc*`） | [node-lint-format.md](node-lint-format.md) |
| Prettier（`.prettierrc*` 等） | [node-lint-format.md](node-lint-format.md) |
| `package.json`（engines / scripts / 依存） | [node-lint-format.md](node-lint-format.md) |
| `tsconfig.json` | [typescript.md](typescript.md) |
| Next.js（`next.config.*`） | [nextjs.md](nextjs.md) |
| Vitest（`vitest.config.*`） | [vitest.md](vitest.md) |
| `.gitignore`, `.gitattributes` | [git.md](git.md) |
| `.eslintignore`, `.prettierignore`, `.cursorignore`, `.npmignore` 等 | [ignore-files.md](ignore-files.md)（`.gitignore` レビュー時も併読） |
| `.env*`, アプリの env スキーマ | [env-secrets.md](env-secrets.md) |
| `config/deploy.yml`, `.kamal/*` | [kamal.md](kamal.md) と [env-secrets.md](env-secrets.md) |
| `.rubocop.yml`, RSpec | [ruby.md](ruby.md) |

## 横断参照

- **推奨ツール表**（レポートの「推奨ツール」欄）: [recommended-tools.md](recommended-tools.md)

## 公式ドキュメント

各 `*.md` の末尾に、そのツールの**公式ドキュメント**へのリンクを載せている。レビューで「仕様上こうなっているか」を確認するときはこれらを優先する。

## 使い方（SKILL 手順との対応）

1. 対象ファイルを上表でマッピングする。
2. 該当する `*.md` を開き、チェックリストと「公式ドキュメント」を参照する。
3. JS/TS または Ruby を含むレビューでは [recommended-tools.md](recommended-tools.md) でギャップを洗い出す。
