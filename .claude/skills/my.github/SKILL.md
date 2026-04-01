---
name: my.github
description: |
  GitHub リポジトリの情報を gh CLI で取得・整理して見やすく表示するスキル。
  Issue、PR、リリース、ブランチ、コントリビューター、ワークフロー実行、リポジトリ概要など幅広い情報を取得できる。
  ユーザーが「Issue 一覧」「PR の状態」「最近のリリース」「ブランチ一覧」「CI の状況」「リポジトリの情報を見せて」
  「GitHub の〜を教えて」「コントリビューター」「ラベル」「マイルストーン」など、
  GitHub に関連する情報取得を求めたときに積極的にこのスキルを使うこと。
  gh コマンドが使える環境であれば、どのリポジトリでも動作する。
compatibility: |
  - gh CLI (GitHub CLI) がインストール済みであること
  - gh auth login 済みであること
  - Bash ツールによるコマンド実行
---

# Overview

`my.github` は `gh` CLI を使って GitHub リポジトリのさまざまな情報を取得し、見やすく整理して表示するスキルです。ユーザーが GitHub 上の情報について質問したとき、適切な `gh` コマンドを組み立てて実行し、結果を整形して返します。

## When to use

- Issue や PR の一覧・詳細を確認したいとき
- リリースやタグの情報を見たいとき
- ブランチの一覧や状態を確認したいとき
- CI/CD（GitHub Actions）の実行状況を知りたいとき
- コントリビューターやコラボレーターの情報を取得したいとき
- リポジトリ全体の概要やメタ情報を確認したいとき
- ラベル、マイルストーン、プロジェクトなどの管理情報を見たいとき

## Query types and commands

ユーザーの質問内容に応じて、以下のカテゴリからコマンドを選択して実行する。

### 1. Issue

| 操作 | コマンド例 |
| ------ | ----------- |
| オープン Issue 一覧 | `gh issue list --limit 1000` |
| 全 Issue（クローズ含む） | `gh issue list --state all --limit 1000` |
| ラベルで絞り込み | `gh issue list --label "bug" --limit 1000` |
| アサイン先で絞り込み | `gh issue list --assignee @me --limit 1000` |
| Issue の詳細 | `gh issue view <number>` |
| Issue のコメント | `gh api repos/{owner}/{repo}/issues/<number>/comments` |
| Issue の検索 | `gh issue list --search "keyword" --limit 1000` |

### 2. Pull Request

| 操作 | コマンド例 |
| ------ | ----------- |
| オープン PR 一覧 | `gh pr list --limit 1000` |
| マージ済み PR | `gh pr list --state merged --limit 1000` |
| 自分の PR | `gh pr list --author @me --limit 1000` |
| PR の詳細 | `gh pr view <number>` |
| PR のレビュー状況 | `gh pr view <number> --json reviews` |
| PR の差分 | `gh pr diff <number>` |
| PR のチェック状況 | `gh pr checks <number>` |

### 3. リリース・タグ

| 操作 | コマンド例 |
| ------ | ----------- |
| リリース一覧 | `gh release list --limit 1000` |
| 最新リリース | `gh release view --json tagName,name,body,publishedAt` |
| 特定リリースの詳細 | `gh release view <tag>` |
| タグ一覧 | `git tag --sort=-creatordate` |

### 4. ブランチ

| 操作 | コマンド例 |
| ------ | ----------- |
| リモートブランチ一覧 | `git branch -r` |
| ローカル + リモート | `git branch -a` |
| デフォルトブランチ | `gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name'` |
| ブランチの保護ルール | `gh api repos/{owner}/{repo}/branches/<branch>/protection` |

### 5. GitHub Actions / ワークフロー

| 操作 | コマンド例 |
| ------ | ----------- |
| 最近のワークフロー実行 | `gh run list --limit 1000` |
| 特定ワークフローの実行 | `gh run list --workflow <name> --limit 1000` |
| 実行の詳細 | `gh run view <run-id>` |
| 実行ログ | `gh run view <run-id> --log` |
| 失敗した実行のみ | `gh run list --status failure --limit 1000` |
| ワークフロー一覧 | `gh workflow list` |

### 6. リポジトリ情報

| 操作 | コマンド例 |
| ------ | ----------- |
| リポジトリ概要 | `gh repo view` |
| JSON で詳細取得 | `gh repo view --json name,description,url,stargazerCount,forkCount,isPrivate,defaultBranchRef,languages,licenseInfo` |
| コントリビューター | `gh api repos/{owner}/{repo}/contributors --jq '.[] \| "\(.login) (\(.contributions) commits)"'` |
| コラボレーター | `gh api repos/{owner}/{repo}/collaborators --jq '.[].login'` |
| 言語別割合 | `gh api repos/{owner}/{repo}/languages` |

### 7. ラベル・マイルストーン・プロジェクト

| 操作 | コマンド例 |
| ------ | ----------- |
| ラベル一覧 | `gh label list` |
| マイルストーン一覧 | `gh api repos/{owner}/{repo}/milestones --jq '.[] \| "\(.title) - \(.state) (\(.open_issues) open, \(.closed_issues) closed)"'` |
| プロジェクト一覧 | `gh project list` |

### 8. 通知・セキュリティ

| 操作 | コマンド例 |
| ------ | ----------- |
| Dependabot アラート | `gh api repos/{owner}/{repo}/dependabot/alerts --jq '.[] \| "\(.state): \(.security_advisory.summary)"'` |
| シークレットスキャンアラート | `gh api repos/{owner}/{repo}/secret-scanning/alerts` |

## Workflow

1. **Parse request** - ユーザーの質問から、どのカテゴリの情報を求めているか判断する
2. **Build command** - 上記のコマンド表を参考に、適切な `gh` / `git` コマンドを組み立てる
3. **Execute** - Bash ツールでコマンドを実行する
4. **Format output** - 結果を Markdown の表や箇条書きで見やすく整形して返す
5. **Suggest next** - 関連する追加情報があれば提案する（例: Issue 一覧を表示した後「詳細を見たい Issue はありますか？」）

## Output formatting rules

- 一覧系の情報は Markdown テーブルで表示する
- 一覧取得時は `--limit 1000` をデフォルトで付与し、取りこぼしを防ぐ
- 日時は `YYYY-MM-DD HH:MM` 形式で表示する（JST 変換が可能ならする）
- ステータスには視覚的な区別をつける（Open/Closed/Merged など）
- 結果が 0 件の場合は「該当なし」と明示し、条件を広げる提案をする
- `gh api` の JSON 出力は `--jq` で必要なフィールドだけ抽出する

## Error handling

- `gh` が未インストール or 未認証の場合: インストール・認証手順を案内する
- リポジトリが見つからない場合: 現在のディレクトリが git リポジトリか確認する
- 権限不足の場合: 必要な権限を説明する
- API レート制限の場合: 待機を提案する

## Tips

- `{owner}/{repo}` は `:owner/:repo` と書くと gh が自動補完してくれる場合がある
- 複数の情報を同時に取得したい場合は、Bash ツールを並列で呼び出して効率化する
- `--json` フラグと `--jq` を組み合わせると柔軟に出力をカスタマイズできる
- `gh api graphql` を使えば、REST API では取得しにくい情報も一度に取得できる
