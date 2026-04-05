---
name: my.claude-manager
description: |
  .claude ディレクトリ配下の設定（skills, rules, agents, settings, paths.md）を
  一元管理するスキル。一覧表示、整合性チェック、追加・削除、整理レポートを行う。
  「設定の整合性」「config lint」「スキル一覧」「ルール一覧」「設定を確認」
  「.claude の健全性チェック」「設定が壊れてないか」「スキルの参照チェック」
  「不要なスキルを消したい」「ルールを整理したい」などの依頼で使うこと。
---

<!-- markdownlint-disable MD024 -->

# Claude Manager — .claude 設定の一元管理

`.claude/` 配下の設定ファイル群（skills, rules, agents, settings）を管理するスキル。

## 基本方針

- 削除・修正の操作はユーザーに確認を取ってから実行する
- 出力は日本語で行う
- レポートは Markdown 形式で生成する

## スコープ: 管理対象

以下の `.claude/` 配下の設定ファイルが対象:

| 種別 | パス | 説明 |
| ------ | ------ | ------ |
| スキル | `.claude/skills/my.*/SKILL.md` | v3 スキル定義 |
| ルール | `.claude/rules/*.md` | ルールファイル（glob パターン付き） |
| エージェント | `.claude/agents/*.md` | エージェント定義 |
| 設定 | `.claude/settings.json`, `settings.local.json` | hooks, statusline 等 |
| パス定義 | `.claude/skills/paths.md` | ファイル出力先の共通定義 |
| ドキュメント | `.claude/CLAUDE.md` | プロジェクトコンテキスト（本体） |
|  | `.claude/README.md` | .claude/ の詳細リファレンス |
|  | `AGENTS.md` | エージェント参照（CLAUDE.md へ委譲） |
|  | `README.md` | セットアップガイド（CLAUDE.md へ委譲） |

### 対象外

- `.claude/skills-v2/` — レガシースキル（別管理）
- `*-workspace/` — スキル評価用ワークスペース
- `.claude/memory/` — メモリファイル（別管理）

## 機能

### 1. 一覧表示 (`list`)

`.claude/` 配下の設定をカテゴリ別にテーブル形式で表示する。

```bash
# スキル一覧
ls -d .claude/skills/my.*/SKILL.md 2>/dev/null | sed 's|.claude/skills/||;s|/SKILL.md||'

# ルール一覧
ls .claude/rules/*.md 2>/dev/null | sed 's|.claude/rules/||'

# エージェント一覧
ls .claude/agents/*.md 2>/dev/null | sed 's|.claude/agents/||'
```

表示項目（スキルの場合）:

| # | スキル名 | 説明（1行目） | ファイル出力 |
| --- | --- | --- | --- |
| 1 | my.branch-name | ブランチ名を生成 | なし |
| 2 | my.memo | 会話メモを保存 | あり |

`list skills`, `list rules`, `list agents`, `list all` でフィルタ可能。

### 2. 整合性チェック (`check`)

設定ファイル群が互いに矛盾なく連携しているかを検証する。
以下の 6 カテゴリをすべて実行し、結果をサマリー表示する。

#### 2-1. paths.md 網羅性

ファイル出力を行うスキルが、すべて paths.md に登録されているか。

1. `.claude/skills/paths.md` を読み込む
2. 各 `SKILL.md` のファイル出力先を抽出
3. paths.md の登録と照合

- **WARN**: 出力するスキルが paths.md に未登録
- **WARN**: paths.md にあるが SKILL.md が存在しない
- **INFO**: 正常

#### 2-2. パス参照の一貫性

各スキルがパスをハードコードせず paths.md を参照しているか。

1. `SKILL.md` からハードコードされたパス（`.knowledge/`, `.claude/`）を抽出
2. paths.md への参照有無を確認
3. ハードコードと paths.md 定義の一致を照合

- **WARN**: ハードコードのみで paths.md 参照なし
- **WARN**: paths.md 定義と食い違い
- **OK**: 一致

#### 2-3. 存在しないパスの検出

設定ファイルが参照するパスが実在するか。

- `settings.json` の hooks スクリプトパス
- `SKILL.md` 内の `scripts/`, `references/` 参照
- rules 本文中の具体的ファイルパス

- **ERROR**: 参照先が存在しない
- **OK**: 存在する

#### 2-4. rules frontmatter 検証

`.claude/rules/*.md` の `paths:` が有効な glob パターンか。

- **WARN**: `paths:` frontmatter がない
- **INFO**: 同一 glob パターンの重複
- **OK**: 有効

#### 2-5. スキル間の参照整合

スキルが他スキルを参照する場合、参照先が存在するか。

- **ERROR**: 参照先スキルが存在しない
- **WARN**: README との不一致
- **OK**: 存在する

#### 2-6. settings.json 整合

hooks スクリプト、statusline、plans ディレクトリの存在確認。

- **ERROR**: 参照先が存在しない
- **OK**: 存在する

#### 2-7. ドキュメント間の整合性

4 つのドキュメント（`.claude/CLAUDE.md`, `.claude/README.md`, `AGENTS.md`, `README.md`）の記載が実態と一致しているかを検証する。

情報の流れ: `CLAUDE.md`（本体）← `README.md`, `AGENTS.md`, `.claude/README.md`（参照）

チェック項目:

1. **スキル一覧の同期**: `.claude/README.md` と `CLAUDE.md` に記載されたスキル名が、実際の `skills/my.*/SKILL.md` と一致するか
   - **WARN**: 実在するスキルがドキュメントに未記載
   - **WARN**: ドキュメントに記載があるが実在しないスキル
2. **エージェント一覧の同期**: `CLAUDE.md` に記載されたエージェントが、実際の `agents/*.md` と一致するか
   - **WARN**: 実在するエージェントが未記載 / 記載があるが実在しない
3. **ルール件数の同期**: `CLAUDE.md` に記載されたルール件数が実際と一致するか
   - **INFO**: 件数の不一致
4. **参照リンクの有効性**: `README.md` と `AGENTS.md` の CLAUDE.md へのリンクが有効か
   - **ERROR**: リンク先ファイルが存在しない
5. **MCP サーバー一覧の同期**: `.claude/README.md` と `settings.json` の `enabledMcpjsonServers` が一致するか
   - **WARN**: 不一致

- **OK**: すべて一致

### 3. 追加 (`add`)

新しいスキル/ルール/エージェントのひな型を作成する。

手順:

1. 種別（skill / rule / agent）をユーザーに確認
2. 名前を確認（スキルなら `my.xxx` 形式）
3. 既存の同名ファイルがないか確認
4. ひな型ファイルを生成
5. 必要に応じて paths.md にエントリを追加

スキルのひな型:

```markdown
---
name: my.<name>
description: |
  （説明）
---

# <Name>

（内容）
```

### 4. 削除 (`remove`)

不要なスキル/ルール/エージェントを削除する。

手順:

1. 対象の詳細（名前、説明、他スキルからの参照）を表示
2. 他スキルから参照されている場合は警告
3. ユーザーに確認
4. 削除を実行
5. paths.md から該当エントリを除去
6. 結果を表示

一括削除の場合:

1. 対象リストを一覧表示
2. 全件確認を取る
3. 1件ずつ削除し結果をまとめて報告

### 5. 整理レポート (`report`)

check の結果を Markdown レポートとして生成・保存する。

```markdown
# .claude Config Report

**実行日時**: YYYY-MM-DD HH:MM
**対象**: .claude/ 配下全体

## サマリー

| カテゴリ | スキル | ルール | エージェント | 設定 |
|---------|-------|-------|------------|------|
| 件数    |       |       |            |      |

## 整合性チェック結果

| カテゴリ               | ERROR | WARN | INFO | OK |
| ---------------------- | ----- | ---- | ---- | -- |
| paths.md 網羅性        |       |      |      |    |
| パス参照の一貫性       |       |      |      |    |
| 存在しないパスの検出   |       |      |      |    |
| rules frontmatter 検証 |       |      |      |    |
| スキル間の参照整合     |       |      |      |    |
| settings.json 整合     |       |      |      |    |
| ドキュメント間の整合性 |       |      |      |    |
| **合計**               |       |      |      |    |

## 詳細

（各カテゴリの詳細結果）

## 推奨アクション

（ERROR / WARN の修正案を箇条書き）
```

デフォルト保存先: `.claude/skills/paths.md` の **`RECORDS`** キーを参照。

### 6. 差分確認 (`diff`)

前回のレポートと現在の状態を比較し、変更点を表示する。

- 追加されたスキル/ルール/エージェント
- 削除されたもの
- 整合性の改善/悪化

## ユーザーとのやりとり

- 削除・修正は対象を明示してから確認を取る
- ユーザーが「整理して」と曖昧に言った場合は、まず `list all` → `check` を実行し、結果を見せてから次のアクションを提案する
- 一覧が長い場合はカテゴリ別にグルーピングして見やすくする
