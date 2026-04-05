---
name: my.notion
description: |
  Notion ワークスペースの検索・参照・要約、ページ作成・編集・複製・移動、コメント追加、データベース作成・スキーマ変更、ビュー操作、チーム・ユーザー情報取得を行う統合スキル。Notion MCP の全 14 ツールをフル活用し、ユーザーの Notion 操作を効率化する。
  「Notion で探して」「Notion にページ作って」「Notion のあのページ見せて」「Notion にコメントして」「Notion のビュー変えて」「Notion のDB まとめて」「Notion のDB にカラム追加して」「Notion の議事録どこ」「Notion の進捗確認」「Notion のタスク一覧」「Notion にメモ書いて」「Notion のページをコピーして」「Notion のページ移動して」「Notion のチームメンバー誰」など、Notion に関連する操作全般でこのスキルを使用すること。Notion の URL やページ名が会話に出てきた場合も積極的にトリガーする。
---

# Notion 統合スキル

## 概要

Notion ワークスペースと対話するための統合スキル。検索・閲覧・要約・ページ作成/編集・コメント・DB 構築/スキーマ変更・ビュー操作・ページ整理・チーム情報取得の機能を提供する。Notion MCP サーバーが接続されている前提で動作する。

## いつ使うか

- Notion ワークスペース内の情報を検索・参照したいとき
- Notion ページやデータベースの内容を要約・整理したいとき
- Notion に新しいページやメモを作成したいとき
- 既存の Notion ページの内容やプロパティを編集したいとき
- Notion ページにコメントやフィードバックを残したいとき
- データベースを新規作成したい、またはスキーマ（カラム構成）を変更したいとき
- データベースのビュー（テーブル、ボード、カレンダー等）を作成・修正したいとき
- ページを別の場所に移動・複製したいとき
- チームメンバーやユーザー情報を確認したいとき
- Notion の URL が会話に登場したとき

## 使わない場面

- Obsidian ボルト内のローカルファイル検索 → `/my:search` を使う
- 外部 Web コンテンツの Obsidian へのインポート → `/my:import` を使う
- Notion 以外のプロジェクト管理ツール（GitHub Issues 等）→ `/my:github` を使う

## 機能一覧

| 機能 | 説明 | 主要ツール |
| --- | --- | --- |
| 検索 | ワークスペース横断のセマンティック検索 | `notion-search` |
| 参照 | ページ・DB の詳細取得と表示 | `notion-fetch` |
| 要約 | ページ・DB の内容を構造化して要約 | `notion-fetch` → 分析 |
| ページ作成 | 新規ページを作成（DB 内/スタンドアロン） | `notion-create-pages` |
| ページ編集 | 既存ページの内容・プロパティを更新 | `notion-update-page` |
| ページ整理 | ページの複製・別の場所への移動 | `notion-duplicate-page`, `notion-move-pages` |
| コメント | ページやブロックにコメント追加・閲覧 | `notion-create-comment`, `notion-get-comments` |
| DB 作成 | 新規データベースをスキーマ定義から構築 | `notion-create-database` |
| DB スキーマ変更 | カラム追加・削除・名前変更・型変更 | `notion-update-data-source` |
| ビュー操作 | DB ビューの作成・フィルタ・ソート変更 | `notion-create-view`, `notion-update-view` |
| チーム・ユーザー | チーム一覧やメンバー情報の取得 | `notion-get-teams`, `notion-get-users` |

## 手順（エージェント向け）

### 1. 検索・参照

ユーザーが Notion の情報を探している場合:

1. **URL が提供されている場合** → `notion-fetch` で直接取得する
2. **キーワードのみの場合** → `notion-search` でセマンティック検索を実行する
   - `query` にユーザーの意図を反映した検索語を設定
   - `page_size` は必要最小限に（既定 10、最大 25）
   - 特定の DB 内を検索したい場合は、先に DB を `notion-fetch` して `data_source_url`（`collection://...`）を取得してから絞り込む
3. **検索結果から詳細が必要な場合** → 結果の URL/ID を `notion-fetch` に渡してフルコンテンツを取得

検索結果は簡潔にまとめて提示する。タイトル、URL、ハイライト（該当箇所の抜粋）を含める。

**検索のコツ**: `notion-search` はセマンティック検索なので、キーワード完全一致ではなく意味的に近い結果も返る。ユーザーの意図を汲んだ自然な検索クエリを使うと精度が上がる。

### 2. 要約・まとめ

ページやデータベースの内容を要約する場合:

1. `notion-fetch` で対象ページ/DB のコンテンツを取得
2. コンテンツの種類に応じた要約を生成:
   - **ページ**: 見出し構造に沿ったサマリー、要点の箇条書き
   - **データベース**: スキーマ概要、レコード数、主要なステータス分布
   - **議事録/ドキュメント**: 決定事項・アクションアイテム・次のステップの抽出
3. 要約はユーザーの目的に合わせて粒度を調整する（「ざっくり」→ 3-5 行、「詳しく」→ セクションごと）

### 3. コメント

Notion ページにコメントを追加する場合:

1. 対象ページの `page_id` を特定する（URL から抽出、または検索で見つける）
2. 既存コメントを確認したい場合は `notion-get-comments` で取得
   - `include_all_blocks: true` でブロックレベルのコメントも取得可能
   - `include_resolved: true` で解決済みコメントも表示可能
3. コメントを追加:
   - **ページ全体へのコメント**: `page_id` のみ指定
   - **特定箇所へのコメント**: `selection_with_ellipsis` で対象テキストの先頭約10文字...末尾約10文字を指定
   - **既存スレッドへの返信**: `discussion_id` を指定
4. `rich_text` でコメント内容を構成する。メンションやリンクも利用可能

```text
コメント例:
- ページレベル: 「このドキュメント全体について確認しました」
- 箇所指定: selection_with_ellipsis = "# 第2四半期の...売上分析" → その見出しにコメント
- 返信: discussion_id = "discussion://pageId/blockId/discussionId"
```

### 4. ページ作成

Notion に新しいページを作成する場合:

1. **作成先を決定する**:
   - **スタンドアロンページ**: `parent` を省略するとワークスペースのプライベートページとして作成
   - **既存ページの子ページ**: `parent: { page_id: "..." }` を指定
   - **DB のレコードとして**: `parent: { data_source_id: "..." }` を指定（先に `notion-fetch` で DB のスキーマを確認）
2. `notion-create-pages` でページを作成:
   - `properties`: タイトルや DB プロパティを設定
   - `content`: Notion Markdown 形式で本文を記述
   - `icon`: 絵文字やカスタム絵文字を設定可能
   - `cover`: 外部画像 URL でカバー画像を設定可能
3. DB にページを追加する場合、Markdown 仕様を確認するために `notion://docs/enhanced-markdown-spec` リソースを参照する

```text
例: DB にタスクを追加
parent: { data_source_id: "collection://..." }
properties: { "Task Name": "レビュー対応", "Status": "To Do", "date:Due Date:start": "2026-04-10" }
content: "## やること\n- PR のコメント対応\n- テスト追加"
```

一度に最大 100 ページまでバッチ作成できる。大量のレコードを一括登録したい場合に活用する。

### 5. ページ編集

既存ページの内容やプロパティを更新する場合:

1. まず `notion-fetch` で対象ページの現在の内容を取得する（編集前に必ず実施）
2. `notion-update-page` で更新。`command` パラメータで操作を指定:
   - **`update_properties`**: プロパティのみ変更（ステータス変更、担当者変更など）
   - **`update_content`**: 部分的な内容変更（検索置換方式で `old_str` → `new_str`）
   - **`replace_content`**: ページ全体の内容を置き換え
   - **`apply_template`**: テンプレートを適用（テンプレート ID は `notion-fetch` の結果に含まれる）
   - **`update_verification`**: ページの検証ステータスを更新

```text
例: プロパティ更新
command: "update_properties"
properties: { "Status": "Done", "Assignee": "田中太郎" }

例: 部分的な内容変更
command: "update_content"
content_updates: [{ old_str: "## 未着手", new_str: "## 進行中" }]
```

子ページや子 DB が含まれるページを `replace_content` する場合、`<page url="...">` や `<database url="...">` タグで参照を保持しないと削除される点に注意する。

### 6. ページ整理（複製・移動）

ページの複製や移動で Notion の構造を整理する場合:

1. **ページ複製** → `notion-duplicate-page`:
   - `page_id` を指定するだけで複製される
   - 複製は非同期で完了するため、すぐには反映されないことをユーザーに伝える
2. **ページ移動** → `notion-move-pages`:
   - 最大 100 ページを一括移動可能
   - 移動先は `page_id`（ページ配下）、`database_id`（DB 配下）、`data_source_id`（特定データソース配下）、`workspace`（ワークスペースルート）から選択
   - データソース（DB 内のコレクション）単体は移動できない

### 7. DB 作成・スキーマ変更

新しいデータベースを作成する、または既存 DB のスキーマを変更する場合:

**新規 DB 作成** → `notion-create-database`:

- `schema` に SQL DDL 風の CREATE TABLE 文を書く
- `parent` で配置先のページを指定（省略するとワークスペースルートに作成）
- カラム名はダブルクォートで囲む

```text
例: タスク管理 DB
title: "Sprint Tasks"
parent: { page_id: "..." }
schema: CREATE TABLE (
  "Task" TITLE,
  "Status" SELECT('Backlog':gray, 'In Progress':blue, 'Done':green),
  "Priority" SELECT('High':red, 'Medium':yellow, 'Low':gray),
  "Assignee" PEOPLE,
  "Due Date" DATE,
  "Story Points" NUMBER,
  "Tags" MULTI_SELECT('frontend':blue, 'backend':purple, 'bug':red)
)
```

**利用可能な型**: TITLE, RICH_TEXT, NUMBER, SELECT, MULTI_SELECT, DATE, PEOPLE, CHECKBOX, URL, EMAIL, PHONE_NUMBER, STATUS, FILES, FORMULA, RELATION, ROLLUP, UNIQUE_ID, CREATED_TIME, LAST_EDITED_TIME

**スキーマ変更** → `notion-update-data-source`:

- 先に `notion-fetch` で `data_source_id` を取得
- `statements` にセミコロン区切りの DDL 文を記述

```text
例: カラム操作
ADD COLUMN "Reviewer" PEOPLE                          -- カラム追加
DROP COLUMN "Old Field"                               -- カラム削除
RENAME COLUMN "Task" TO "Task Name"                   -- カラム名変更
ALTER COLUMN "Priority" SET SELECT('P0':red, 'P1':orange, 'P2':yellow)  -- 型/選択肢変更
```

DB のタイトルや説明文も `title` / `description` パラメータで変更可能。`in_trash: true` でデータソースをゴミ箱に移動できる。

### 8. ビュー操作

データベースのビューを作成・修正する場合:

1. まず `notion-fetch` で対象 DB を取得し、以下を確認:
   - `database_id`（DB 全体の ID）
   - `data_source_id`（`<data-source url="collection://...">` から取得）
   - 既存ビューの一覧と ID（`view://...`）
   - プロパティのスキーマ（カラム名と型）
2. **新規ビュー作成** → `notion-create-view` を使用:
   - `type`: table, board, list, calendar, timeline, gallery, chart 等
   - `configure` DSL でフィルタ・ソート・グルーピングを設定
3. **既存ビュー修正** → `notion-update-view` を使用:
   - `view_id`: 修正対象のビュー ID
   - `configure` DSL で変更内容を記述
   - `CLEAR FILTER`, `CLEAR SORT` 等で既存設定をリセット可能

**ビュー DSL の主要構文**:

```text
FILTER "Status" = "In Progress"          -- フィルタ
SORT BY "Due Date" ASC                   -- ソート
GROUP BY "Status"                        -- グループ化（ボードビューに必須）
CALENDAR BY "Due Date"                   -- カレンダービュー用
SHOW "Name", "Status", "Assignee"       -- 表示カラム指定
CLEAR FILTER                             -- フィルタ解除
```

複数ディレクティブはセミコロンで区切る:

```text
FILTER "Status" = "Active"; SORT BY "Priority" DESC; SHOW "Name", "Status", "Owner"
```

### 9. ディスカッション確認

ページ内のディスカッション（コメントスレッド）を把握したい場合:

1. `notion-fetch` に `include_discussions: true` を渡してページを取得
   - ディスカッション数とプレビューが `<page-discussions>` タグで表示される
   - 本文中に `discussion://` マーカーが埋め込まれ、どこにコメントがあるか把握できる
2. 詳細を見たいスレッドは `notion-get-comments` で `discussion_id` を指定して取得

### 10. チーム・ユーザー情報

ワークスペースのチームやメンバーを確認したい場合:

1. **チーム一覧** → `notion-get-teams`:
   - クエリなしで全チーム取得、または名前で検索
   - メンバーシップ状態（参加済み/未参加）、ロール情報が返る
2. **ユーザー検索** → `notion-get-users`:
   - 名前やメールアドレスで検索可能
   - `user_id: "self"` で自分自身の情報を取得
   - ページネーション対応（`start_cursor` で次ページ取得）
3. **ユーザー ID の活用**: コメントでのメンション、ページプロパティの PEOPLE 型、検索フィルタの `created_by_user_ids` など、他の操作で使用するユーザー ID をここで取得できる

## ユーザーへの出力形式

- 検索結果: タイトル + URL + 抜粋を箇条書き
- ページ内容: 見出し構造を保ったまま Markdown で表示
- 要約: 目的に応じた粒度の箇条書きまたは短文
- ページ作成/編集: 作成・更新したページの URL と変更内容の要約
- コメント操作: 実行結果の確認（「コメントを追加しました」+ 内容の要約）
- DB 作成/変更: スキーマの概要（カラム名・型の一覧）
- ビュー操作: 変更内容の要約（「フィルタを "Status = Active" に設定しました」等）
- ページ整理: 移動先/複製先の確認
- チーム/ユーザー: 名前・メール・ロールの一覧表示

## 補足

- Notion のページ ID は URL の末尾 32 文字（ハイフンなし UUID）から取得できる
- データベースとデータソースは異なる概念。DB には複数のデータソースが含まれる場合がある。ビュー操作やページ作成には `data_source_id` が必要
- `notion-search` は AI 検索（コネクテッドソース含む）とワークスペース検索を自動切替する。検索精度を上げたい場合は `content_search_mode` で明示指定できる
- ビュー DSL の完全な構文は `notion://docs/view-dsl-spec` リソースを参照
- ページコンテンツの Markdown 仕様は `notion://docs/enhanced-markdown-spec` リソースを参照
