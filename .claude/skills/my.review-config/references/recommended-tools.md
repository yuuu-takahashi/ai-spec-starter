# おすすめツール（カテゴリ別）

レビューレポートでは、下表を**出発点**とし、プロジェクトのスタック・既存選定を尊重しつつ**欠けている単品**を提案する。競合する選択肢（例: RuboCop 詳細設定 vs Standard）は**どちらか一方**でよいことを明記する。

表に載る各パッケージ / Gem の仕様・設定・非推奨は、[npm](https://www.npmjs.com/) / [RubyGems](https://rubygems.org/) の該当ページと、各プロジェクトの**公式ドキュメント**（例: [ESLint](https://eslint.org/docs/latest/)、[RuboCop](https://docs.rubocop.org/)）を優先して確認する。

## JavaScript / TypeScript（ESLint 関連）

| 優先度   | ツール / パッケージ                                                            | 役割                                                                 |
| -------- | ------------------------------------------------------------------------------ | -------------------------------------------------------------------- |
| 高       | `eslint`                                                                       | Lint の中核。新規は **flat config**（`eslint.config.ts` 等）へ寄せる |
| 高       | `typescript-eslint`                                                            | TypeScript 向けパーサ・ルール                                        |
| 高       | `@eslint/js`                                                                   | ESLint 公式の JavaScript 推奨ルールプリセット                        |
| 高       | `eslint-config-prettier`                                                       | Prettier とぶつかる ESLint ルールを無効化（併用時は事実上必須）      |
| 中       | `eslint-plugin-import-x` または `eslint-plugin-import`                         | import の解決・並び順                                                |
| 中       | `eslint-plugin-n`                                                              | Node / サーバ向けの慣習チェック                                      |
| 中       | `eslint-plugin-security` または `eslint-plugin-security-node`                  | 追加のセキュリティ系ルール（スタックに合わせて選定）                 |
| 条件付き | `eslint-plugin-react` / `eslint-plugin-react-hooks` / `eslint-plugin-jsx-a11y` | React 利用時                                                         |
| 条件付き | `@next/eslint-plugin-next`                                                     | Next.js 利用時                                                       |
| 低       | `globals`                                                                      | ブラウザ / Node 等のグローバルを flat config で明示                  |

- **フォーマット**は **Prettier** を別担当とし、ESLint は品質・バグ寄り、`eslint --fix` と役割が被らないよう `eslint-config-prettier` で調整する。

## Ruby / Rails（RuboCop 関連）

| 優先度   | ツール / Gem                              | 役割                                                                    |
| -------- | ----------------------------------------- | ----------------------------------------------------------------------- |
| 高       | `rubocop`                                 | Ruby のスタイル・軽微な問題検出の基盤                                   |
| 高       | `rubocop-rails`                           | Rails API・規約に沿ったチェック                                         |
| 条件付き | `rubocop-rspec`                           | RSpec を書く場合                                                        |
| 中       | `rubocop-performance`                     | パフォーマンス反パターン                                                |
| 用途次第 | `rubocop-rake` / `rubocop-factory_bot` 等 | 該当ライブラリ利用時                                                    |
| 参考     | `standard`（Standard Ruby）               | ルールを固定したい場合の **RuboCop 代替**。**RuboCop と二重運用しない** |

- **セキュリティ**: `brakeman`（Rails 向け静的解析）、`bundler-audit`（既知脆弱性）は CI とのセットで推奨しやすい。

## RSpec・テスト周辺（Ruby）

- **フレームワーク**: `rspec`
- **カバレッジ**: `simplecov`（閾値・除外パスは CI と揃える）

## 実行タイミング（言語横断）

- **pre-commit**: `husky` + `lint-staged`（変更分だけ ESLint / Prettier / RuboCop 等）
- **CI**: ローカルと同じコマンドをワークフローで実行し、差分をなくす
