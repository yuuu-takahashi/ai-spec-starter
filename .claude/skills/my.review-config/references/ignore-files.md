# ignore 系ファイル（共通指針）

ツールごとに「除外の意味」が異なる。**git の追跡対象外**と**Docker ビルドコンテキストの削減**と**Lint 対象外**を混同しないこと。

## 代表ファイルと役割

| ファイル                                | 主な目的                                                   | 備考                                                                         |
| --------------------------------------- | ---------------------------------------------------------- | ---------------------------------------------------------------------------- |
| `.gitignore`                            | バージョン管理に含めないパス                               | 既に追跡済みのファイルは ignore だけでは消えない（`git rm --cached` が必要） |
| `.gitattributes`                        | 改行・LFS・diff 挙動（ignore ではないが併せて確認）        | バイナリや生成物の diff 抑制                                                 |
| `.dockerignore`                         | ビルドコンテキストから除外                                 | **`.gitignore` を自動継承しない**。`COPY . .` の内容と直接関係               |
| `.eslintignore` / `.prettierignore`     | リンター・フォーマッタの対象外                             | ESLint flat config では `ignores` に寄せる構成も多い。二重管理に注意         |
| `.cursorignore` / `.cursor/indexignore` | エディタ・索引の対象外                                     | 機密・巨大生成物の誤送信防止。必要なコードまで除外しすぎない                 |
| `.npmignore`                            | npm 公開時の同梱から除外                                   | `package.json` の `files` と併用時は **ホワイトリスト優先の意図**を確認      |
| `.gcloudignore` / `.helmignore` など    | 各クラウド・パッケージツールの送信・パッケージ対象から除外 | 公式のデフォルト（`.gcloudignore` が `.gitignore` を参照するか等）を確認     |

## 正確性・完全性

- パターンがそのツールの**解釈ルール**（先頭 `/`、`**`、ディレクトリ末尾 `/`、`!` 否定）に合っているか
- **必要なファイルまで除外していないか**（例: `dist/` を ignore した結果、本番イメージに成果物が入らない、など）
- モノレポでルートとサブパッケージの ignore が**期待どおり階層適用**されるか

## セキュリティ

- `.env*`、鍵、証明書、`.pem`、`.key`、バックアップ、資格情報っぽいパス名が、Git・Docker・公開パッケージのいずれでも**意図どおり漏れなく**除外されているか
- **誤ってコミット済みの機密**は ignore 追加だけでは不十分（履歴からの除去・ローテーションが必要）であることを認識した指摘にする

## パフォーマンス

- `.dockerignore` で `node_modules`、キャッシュ、巨大アセット、`.git` を除外し、**ビルドコンテキスト転送時間**を削減できているか
- AI・索引系 ignore で、不要な巨大ディレクトリ（アーカイブ、ダンプ）を外しているか

## 保守性・整合性

- `.gitignore`、`.dockerignore`、`.eslintignore` の**重複は許容**しつつ、**矛盾**（一方では追跡必須・他方でビルドに必要、など）がないか
- 否定パターン（`!`）は必要最小限にし、**なぜ例外が必要か**をコメントで残す
- `package.json` の `files` でホワイトリスト運用している場合、`.npmignore` と**二重で意図が食い違わないか**

---

## 公式ドキュメント（ツール別）

- Git: [gitignore](https://git-scm.com/docs/gitignore), [gitattributes](https://git-scm.com/docs/gitattributes)
- Docker: [.dockerignore](https://docs.docker.com/build/building/context/#dockerignore-files)
- ESLint: [Ignore files](https://eslint.org/docs/latest/use/configure/ignore)
- Prettier: [Ignore code](https://prettier.io/docs/en/ignore.html)
- npm: [package.json `files`](https://docs.npmjs.com/cli/v11/configuring-npm/package-json#files), [Developers / npm publish](https://docs.npmjs.com/cli/v11/using-npm/developers#keeping-files-out-of-your-package)
- Helm: [.helmignore](https://helm.sh/docs/chart_template_guide/helm_ignore_file)
