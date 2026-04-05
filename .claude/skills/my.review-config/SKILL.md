---
name: my.review-config
description: プロジェクトの設定ファイル（Dockerfile、docker-compose、devcontainer、GitHub Actions/CI、ESLint、Prettier、TypeScript、Next.js、Vitest、Rubocop、RSpec、各種 ignore（.gitignore/.dockerignore/.eslintignore 等）、環境変数・シークレット、Kamalなど）を7観点で体系的にレビューし、問題点と改善案を具体的に提示するスキル。CI/Dockerファイル編集時はPostToolUseフックで自動検証（actionlint/Hadolint）。設定ファイルの新規作成・修正・見直し、プロジェクトセットアップ、開発環境構築、「この設定おかしくない？」「設定ファイルをチェックして」といった依頼時に必ず使用してください。devcontainerの導入・検証、CIワークフローの追加・修正時にも自動的にトリガーされます。
hooks:
  PostToolUse:
    - matcher: 'Edit|Write'
      hooks:
        - type: command
          command: '"$CLAUDE_PROJECT_DIR"/.claude/skills/my.review-config/scripts/post-edit-check.sh'
          timeout: 30
---

# 設定ファイル統合レビュー

プロジェクト内のあらゆる設定ファイルを **7つの観点** で体系的にレビューし、具体的な改善案を提示します。

設定ファイルの種類ごとのチェックリストは `references/` 配下にツール別に分割しています。まず `references/INDEX.md` で対象ファイル種別とリファレンスの対応を確認し、該当する `references/*.md` を読んでください。根拠・非推奨・構文の確認は、各ファイル末尾の **公式ドキュメント** リンクを優先する（ツールの一次情報に合わせて指摘する）。

## PostToolUse フック（自動検証）

CI/Dockerファイルの Edit/Write 直後にフックスクリプトが自動実行されます。

| ファイル                             | 自動チェック内容                     |
| ------------------------------------ | ------------------------------------ |
| `.github/workflows/*`                | actionlint（未インストール時は案内） |
| `.gitlab-ci.yml` 他のCI設定          | 案内メッセージ                       |
| `Dockerfile`                         | Hadolint（未インストール時は案内）   |
| `docker-compose.yml` / `compose.yml` | `docker compose config --quiet`      |
| `.dockerignore`                      | 案内メッセージ                       |

対象外ファイルの編集時はスクリプトは何もせず終了します。

## チェック実施手順

### Step 1: チェック対象の特定

引数の解釈ルール:

- **ファイルパス指定** (`Dockerfile`, `.github/workflows/ci.yml` など) → そのファイル＋関連ファイルをチェック
- **タイプ指定** (`docker`, `ci`, `devcontainer`, `eslint` など) → 該当する設定ファイルを検索してチェック
- **未指定** → プロジェクト内の主要な設定ファイルを自動検出

設定ファイルが複数の拡張子で存在する場合は **`.ts` → `.js` → `.json`** の優先順位で判定します（TypeScript形式はコメントと型チェックが可能で保守性が最も高いため）。

自動検出の検索順序:

1. Docker: `Dockerfile`, `docker-compose.yml`, `.dockerignore`
2. devcontainer: `.devcontainer/devcontainer.json`
3. CI/CD: `.github/workflows/*.yml`, `.gitlab-ci.yml`, `.circleci/config.yml`
4. ESLint, Prettier, TypeScript, Node.js, Next.js, Vitest
5. Git: `.gitignore`, `.gitattributes`
6. ignore 系（リポジトリにあれば）: `.dockerignore`, `.eslintignore`, `.prettierignore`, `.cursorignore`, `.npmignore`, `.helmignore`, `.gcloudignore` など
7. Ruby: `.rubocop.yml`, `spec/spec_helper.rb`
8. 環境変数: `.env`, `.env.example`, `.env.keys`, `src/config/env.ts` などアプリの env スキーマ・読み込み箇所
9. Kamal: `config/deploy.yml`, `.kamal/secrets`
10. その他: `.editorconfig`, `.nvmrc`

### Step 2: 設定ファイル別チェックポイントの参照

`references/INDEX.md` を開き、チェック対象に対応する `references/*.md` を読み、チェックポイントを確認します。

**ignore 系ファイル**と**環境変数**をレビュー対象に含める場合は、`references/ignore-files.md` と `references/env-secrets.md` を必ず参照してください（ツールごとの構文差・`.gitignore` との役割の違い・シークレットの扱いをここで揃えます）。

**ESLint / RuboCop / RSpec 等**をレビュー対象に含める場合は、`references/recommended-tools.md` を参照し、スタックに対して**未導入で効果が大きいツール**を洗い出し、レポートの **「推奨ツール」** に**優先度（高 / 中 / 低）と理由**で書く。

### Step 3: 無駄な設定ファイルの検出

レビュー前に以下を確認します:

- **重複検出**: 同じツールの設定が複数の拡張子で存在しないか（例: `eslint.config.ts` と `.eslintrc.json` の両方がある場合、後者は不要）
- **未使用検出**: `package.json` から参照されていない、非推奨の形式、実質空のファイル

削除提案は**ユーザーの承認を得てから**実行します。

### Step 4: 7観点でチェック実施

以下の7つの観点でレビューを実施します。各観点の詳しいチェック内容はファイルタイプごとに異なるため、`references/INDEX.md` から該当する `references/*.md` を参照してください。

1. **正確性** — 構文エラー、型エラー、無効な値、必須フィールドの欠落
2. **ベストプラクティス** — 公式推奨設定への準拠、非推奨設定の使用
3. **セキュリティ** — 機密情報のハードコード、不適切な権限設定
4. **パフォーマンス** — ビルド時間・キャッシュ戦略の最適化、不要な処理
5. **保守性** — コメントの適切さ、設定の論理的整理、環境変数の活用
6. **整合性** — 関連ファイル間の矛盾、バージョン不一致、設定ファイル重複
7. **完全性** — 必要な設定の網羅、環境別設定の分離

### Step 5: レポート作成と保存

`template.md` の構造に従ってレポートを作成し、**レポート本文をそのまま会話に全文出力**します（要約だけにしない）。対象に JS/TS または Ruby が含まれる場合は、テンプレートの **「推奨ツール」** を埋め、`references/recommended-tools.md` と突き合わせた内容にする。

レポートの出力先・ファイル名は `../paths.md` の `CONFIG_REVIEW` を参照。保存先ディレクトリが存在しない場合は自動作成する。

## 入力パラメータ

| 引数 | 説明                               | 例                                     |
| ---- | ---------------------------------- | -------------------------------------- |
| `$1` | ファイルパスまたはタイプ（省略可） | `Dockerfile`, `docker`, `ci`, `eslint` |
| `$2` | 重点観点（省略可）                 | `セキュリティ`, `パフォーマンス`       |

## レポートの重要原則

レビューの価値は「なぜ問題なのか」と「どう直すべきか」を具体的に伝えることにあります。以下の原則を守ってください:

- **「なぜ」を必ず説明する**: 問題の背景（セキュリティリスク、パフォーマンス影響など）を明示。理由がわかれば開発者は類似の問題も自分で気づけるようになる
- **修正前/修正後を実際の設定で示す**: プレースホルダー（`[問題のある設定]` など）は使わず、対象ファイルの実際のコードをコードブロックで引用し、改善案も具体的なコードで提示する
- **指摘と称賛を分離する**: 各観点のセクションには指摘（Moderate Concerns / Issues Found）のみ記載。良い点はレポート末尾の「良いところ（3点）」にまとめ、各項目にファイルパスと行番号を記載する

## ignore 系ファイルの扱い（レビュー時の共通方針）

ignore ファイルは「何を**コンテキストから外すか**」がツールごとに異なるため、**同じパターンを機械的にコピーしない**ことが重要です。

- **目的の切り分け**: Git 管理対象の除外（`.gitignore`）、Docker ビルドコンテキストの縮小（`.dockerignore`）、Lint/Format 対象から外す（`.eslintignore` / `.prettierignore`）、npm 公開パッケージの同梱除外（`.npmignore` または `package.json` の `files`）、エディタ・AI の索引対象（`.cursorignore`）など、**そのツールが読むファイルだけ**を整備する
- **`.gitignore` との関係**: `.dockerignore` は `.gitignore` を継承しない（明示が必要）。他ツールは gitignore 互換のことが多いが、**公式ドキュメントで構文を確認**する
- **セキュリティ**: `.env`、鍵、証明書、バックアップ、資格情報を含むディレクトリは、ビルド・公開・索引のいずれでも漏れなく除外する。逆に **ignore しすぎてビルドやテストに必要なファイルが欠ける**と CI が壊れるため、`COPY` / パッケージング / テスト実行経路と突き合わせる
- **保守性**: パターンに短いコメント（`# 理由`）を付け、重複・矛盾（一方で ignore・他方で追跡が必要など）がないか確認する。否定パターン（`!`）は最小限にし、意図をコメントで残す
- **整合性**: リポジトリルートとサブディレクトリの ignore の関係、モノレポでの各パッケージの `.npmignore` / `files`、`.dockerignore` と `Dockerfile` の `COPY` の整合を取る

詳細なチェックリストは `references/ignore-files.md` を参照してください。

## 環境変数の扱い（ベストプラクティス概要）

レビューでは次を基準にします（詳細は `references/env-secrets.md`）。

- **まずはリポジトリ内の暗号化を優先**: チームで値を共有する必要がある場合は、**平文でコミットせず**、スタックに合う手段で**暗号化した状態でリポジトリに置く**方針を優先する（例: **Rails** の [Encrypted credentials](https://guides.rubyonrails.org/security.html#custom-credentials)（`config/credentials.yml.enc` と `config/master.key`）、**Node 等**の [dotenvx](https://github.com/dotenvx/dotenvx)（暗号化 `.env` と `DOTENV_PRIVATE_KEY`）、ほか SOPS、git-crypt など）。**マスターキー・`DOTENV_PRIVATE_KEY` 等の復号材料はリポジトリに含めず**、各人マシン、CI のシークレット、インフラのシークレットストアだけに置く
- **取得元を必ずどこかに書く**: README、`docs/env.md`、`config/deploy.yml` のコメント、または `env` モジュールのドキュメントコメントなど**単一の参照先**に、「各変数がどこから入るか」（暗号化 `.env`、Kamal `env.secret`、GitHub `secrets`、ホストのエクスポート、プラットフォームの設定画面など）を対応表または一覧で残す。口伝・チャットのみに依存しない
- **未定義ならすぐ気づく**: 必須キーは起動直後に検証し、**欠落・空文字なら明示的に失敗**する（Zod / envalid / 自前スキーマ等）。`undefined` のまま動いて後から壊れる状態を避ける。`process.env` の直参照が散在しないよう集約レイヤー（例: `config/env`）があると検証と取得元の説明を一箇所にまとめやすい
- **「なんとなく」のデフォルト値を置かない**: `process.env.FOO || 'http://localhost'` のように**未設定を隠すフォールバック**を広く使わない。未設定であることが検証で検知できなくなる。どうしても定数が必要なら、コード内の名前付き定数とコメントで意図を明示し、環境変数とは別レイヤーとして扱う
- **テンプレートと実体**: `.env.example`（または `.env.sample`）には**キー名・説明・取得元のヒント**を載せ、実値は暗号化ファイル・CI・デプロイ経由に寄せる
- **環境の分離**: `development` / `staging` / `production` で同名キーの意味がぶれないか。フレームワークのプレフィックス（例: クライアントに露出する `NEXT_PUBLIC_*`, `VITE_*`）のルールをチームで統一する
- **Docker / ビルド**: ビルド時のみ必要な値は `ARG`、実行時は `ENV` やランタイム注入。**機密を平文 `ARG` で焼き付けない**（暗号化ビルド引数・シークレットマウント・マルチステージで最終イメージに持ち込まない等を検討）
- **本番の供給元**: コンテナオーケストレーション・PaaS・Kamal 等の**シークレット機構**とアプリの読み取り方法が一致し、上記「取得元」の文書と矛盾しないか

## 使用例

```text
/my.review-config Dockerfile
/my.review-config docker
/my.review-config ci
/my.review-config devcontainer
/my.review-config .eslintrc.js セキュリティ
/my.review-config .github/workflows/ci.yml
/my.review-config .gitignore
/my.review-config .dockerignore
/my.review-config
```
