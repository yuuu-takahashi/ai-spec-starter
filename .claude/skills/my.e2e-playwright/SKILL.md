---
name: my.e2e-playwright
description: Playwright（@playwright/test）による E2E テストの設計・実装・実行・デバッグ。ユーザージャーニー作成、POM、ロケーター方針、trace/screenshot/video、HTML・JUnit レポート、フレイキー検知・隔離、CI での browsers インストールとアーティファクト保存。「E2E 書いて」「Playwright でテスト」「フレイキー調査」「playwright.config」「codegen」「show-report」「trace 見て」と依頼されたときに使う。本番の金銭・本番 DB への書き込みテストは対象外（ステージング・モック・テスト用アカウントに限定）。
compatibility: |
  - 対象リポジトリに Node.js と Playwright が導入されていること（未導入なら追加手順を先に提案）
  - Bash で `npx playwright` 等が実行できること
  - Cursor で user-playwright MCP が有効な場合、ブラウザ操作の補助に使ってよい（必須ではない）
---

# Playwright E2E テスト

`@playwright/test` を中心に、エンドツーエンドテストの作成・保守・実行・失敗調査までを一貫して扱う。

## いつ使うか

- クリティカルなユーザーフロー（認証、決済、主要 CRUD、オンボーディングなど）をブラウザで検証したい
- 既存の Playwright スペックの修正、ロケーター見直し、フレイキー対策が必要
- `playwright.config.ts`、レポーター、CI ジョブ、環境変数（`BASE_URL` 等）の整備
- 失敗時の trace / スクリーンショット / 動画の見方と再現手順の整理

**使わないでよい場面**: 純粋な単体テスト方針のみ、Jest/Vitest のみの話題（必要ならテスト観点だけ短く触れ、ユニット層へ誘導）。設定ファイルの静的レビュー中心なら `/my.review-config`、React 実装レビューなら `/my.review-code-react`。

## 手順

1. **前提確認**  
   `package.json` に `@playwright/test` があるか、`playwright.config.*` の有無、`testDir` と `baseURL` を確認。なければ導入コマンドと最小設定を提案する。

2. **ジャーニー単位で設計**  
   ハッピーパスを優先し、認証・外部 API・データ依存はテスト用ユーザー・モック・フィクスチャで隔離。セレクタは **`getByRole` / `getByLabel` / `getByTestId`** を優先し、スタイルクラスや深い XPath に依存しない。

3. **実装**  
   画面・フローが増える場合は Page Object（またはフィクスチャ化したヘルパー）で重複を減らす。長いコード例は `references/patterns.md` を参照。

4. **実行**  
   ローカルで対象スペック→必要なら全件。フレイキー疑いは `--repeat-each` や複数回実行で再現性を確認。

5. **失敗時**  
   `trace: on-first-retry` 等の設定を確認し、`npx playwright show-trace` でタイムラインを追う。ネットワーク・コンソール・スクリーンショットをログと突き合わせる。

6. **CI**  
   `npx playwright install --with-deps`、成果物（`playwright-report/`、JUnit XML）のアップロード、`if: always()` で失敗時もレポートを残す。詳細な YAML パターンは `references/patterns.md`。

## よく使うコマンド

```bash
npx playwright test
npx playwright test path/to/spec.ts
npx playwright test --headed
npx playwright test --debug
npx playwright codegen http://localhost:3000
npx playwright test --trace on
npx playwright show-report
npx playwright show-trace trace.zip
npx playwright test --update-snapshots
npx playwright test --project=chromium
npx playwright test --repeat-each=10
```

パッケージマネージャが yarn / pnpm のプロジェクトでは `yarn playwright test` / `pnpm exec playwright test` に読み替える。

## 入出力・アーティファクト

| 種別               | 典型的な出力先                               |
| ------------------ | -------------------------------------------- |
| HTML レポート      | `playwright-report/`（設定依存）             |
| JUnit              | `playwright-results.xml` 等（reporter 設定） |
| trace              | 失敗時または `trace: on` 時の zip            |
| screenshot / video | `screenshot` / `video` の設定に従う          |

ボルト内のノート保存先を決めるタスクではない。成果物パスは**作業中のリポジトリ**の設定に従う。

## 例（依頼と期待動作）

- **入力**: 「ログインからダッシュボードまで E2E 追加して」  
  **動作**: フロー分解→スペックと POM 案→ロケーター方針→実行コマンド→CI に載せる場合の差分要点。

- **入力**: 「このスペックだけ CI で不安定」  
  **動作**: 待機の種類（auto-wait / `waitForResponse` / `expect` の条件）を見直し、`waitForTimeout` の乱用を排除。再現手順と `repeat-each` 結果を踏まえて `fixme` / `skip` の可否を提案。

## トラブルシュート

| 症状                             | 確認・対処                                                                                                                 |
| -------------------------------- | -------------------------------------------------------------------------------------------------------------------------- |
| 要素が見つからない               | ロール・ラベル・testid に寄せる。アニメーションや遅延描画なら `expect(locator).toBeVisible()` など状態待ち。               |
| タイムアウト多発                 | `networkidle` の乱用を避け、特定レスポンスや UI 状態で待つ。タイムアウト値は箇所ごとに `expect(..., { timeout })` で調整。 |
| ローカルでは通るが CI のみ落ちる | 並列数・`workers`、環境変数、シードデータ、時刻・タイムゾーン、ヘッドレス差を疑う。                                        |
| スナップショット差分             | 意図した UI 変更なら `--update-snapshots`。そうでなければフレイキー要因を調査。                                            |

## 成功の目安（参考）

- クリティカルジャーニーが安定して緑になること
- フレイキーは隔離・Issue 化し、放置しないこと
- 失敗時に trace またはスクリーンショットで原因追跡できること

## 関連スキル・参照

- `/my.review-config` … GitHub Actions や Playwright インストール手順を含む CI の静的レビュー
- `/my.review-code-react` … フロント実装とテスト容易性（testid 等）のレビュー
- `/my.pr-fix` … 既存 PR の CI 失敗調査（このリポジトリの運用向け）
- コード例の全文: `references/patterns.md`

## セキュリティ

- 本番の実ユーザー・実カード・本番 API の破壊的操作を E2E で実行しない。
- シークレットはリポジトリに直書きせず、CI のシークレットストアを使う。
