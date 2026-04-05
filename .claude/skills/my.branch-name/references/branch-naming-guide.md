<!-- markdownlint-disable MD040 -->

# Git ブランチ命名ガイド

チームのブランチフロー規約に基づいたブランチ命名規則の詳細ガイド。

## ブランチ種類と命名規則

### feature（機能開発）

**用途**: 新機能の開発、機能拡張

**形式**: `feature/${チケット番号}`

**例**:

```bash
git checkout -b feature/#12345        # GitHub Issue
git checkout -b feature/PROJECT-9403  # JIRA/Backlog
```

**命名時の注意**:

- チケット番号を必ず含める
- 複数の小分けタスクの場合、親チケット番号を使用
- 一つのブランチは一つの機能単位

### hotfix（緊急修正）

**用途**: 本番環境の緊急バグ修正

**形式**: `hotfix/${チケット番号}`

**例**:

```bash
git checkout -b hotfix/#99999  # 本番障害対応
```

**命名時の注意**:

- 緊急度が高い修正に使用
- 修正後は master (main) へすぐにマージ
- リリース直後の致命的バグなど

### topic（調査・検証）

**用途**: 技術調査、PoC（概念実証）、実験的な実装

**形式**: `topic/${チケット番号}`

**例**:

```bash
git checkout -b topic/#11111  # 新技術検証
```

**命名時の注意**:

- 本番環境への影響が少ない実験的なコード
- 調査結果をコメントで記録
- 不要になった場合はブランチ削除

### release（リリース準備）

**用途**: リリース時のバージョン管理、リリース前の最終調整

**形式**: `release/${yyyymmdd}` または `release/${version}`

**例**:

```bash
git checkout -b release/20260322      # 日付ベース
git checkout -b release/v1.2.0        # バージョンベース
git checkout -b release/v2.0.0-beta   # プレリリース
```

**命名時の注意**:

- 本番環境へのデプロイ前の最終ブランチ
- バージョニング戦略に合わせて命名
- リリース後はマージして削除

### develop（開発統合）

**用途**: 開発ブランチの統合拠点

**形式**: `develop` (固定)

**命名時の注意**:

- 常に開発可能な状態を維持
- CI/CD パイプラインが動作している前提
- リリースバージョンは develop から分岐

### main（本番）

**用途**: 本番環境のコード

**形式**: `main` (固定)

**命名時の注意**:

- 常に本番デプロイ可能な状態
- CI/CD により自動デプロイ
- 直接のコミットは避ける

## キーワードからのプレフィックス推測

チケット番号がない場合のキーワード推測ロジック。

| キーワード | 推測結果 | 理由                   |
| ---------- | -------- | ---------------------- |
| 追加       | feature  | 新しい機能を追加       |
| 実装       | feature  | 新しい機能を実装       |
| 作成       | feature  | 新しい機能を作成       |
| 修正       | fix      | バグ修正               |
| 緊急       | hotfix   | 緊急対応               |
| リリース   | release  | リリース準備           |
| 調査       | topic    | 技術調査               |
| 検証       | topic    | 機能検証               |
| refactor   | refactor | コードリファクタリング |
| その他     | feature  | デフォルトは feature   |

## ブランチ名の正規化ルール

キーワードのみでブランチ名を生成する場合のルール。

### 1. 日本語 → 英語変換

```text
例1: ユーザー認証機能
→ user-authentication

例2: 記事一覧表示
→ article-list-display

例3: エラーハンドリング改善
→ error-handling-improvement
```

### 2. 特殊文字の処理

```text
元の文字列      処理後
"ユーザー's認証" → "user-authentication"
"Auth (新)     → "auth-new"
"API/GraphQL"  → "api-graphql"
```

### 3. ケバブケース（小文字ハイフン区切り）

```text
元の文字列         処理後
"UserAuthentication" → "user-authentication"
"user_authentication" → "user-authentication"
"USER-AUTH"      → "user-auth"
```

### 4. 50文字以内に制限

```text
長いタイトル: "ユーザー認証機能の実装とセキュリティ強化について"
短縮版: "user-authentication-security"  # 30文字以内に

基準:
- 41-50文字: 許容範囲内
- 51文字以上: 短縮が必要
```

## ブランチ命名の実例

### 例1: GitHub Issue

```bash
# 入力
/my:branch #12345

# 出力
推奨ブランチ名: feature/#12345
プレフィックス: feature/
チケット番号: #12345
理由: GitHub Issue番号が検出されました

実行コマンド:
git checkout main
git fetch origin main
git checkout -b feature/#12345
```

### 例2: JIRA チケット

```bash
# 入力
/my:branch PROJ-9403

# 出力
推奨ブランチ名: feature/PROJ-9403
プレフィックス: feature/
チケット番号: PROJ-9403
理由: JIRA形式のチケット番号が検出されました

実行コマンド:
git checkout main
git fetch origin main
git checkout -b feature/PROJ-9403
```

### 例3: キーワード + プレフィックス明示

```bash
# 入力
/my:branch hotfix #99999

# 出力
推奨ブランチ名: hotfix/#99999
プレフィックス: hotfix/
チケット番号: #99999
理由: "hotfix" プレフィックスが明示されました

実行コマンド:
git checkout main
git fetch origin main
git checkout -b hotfix/#99999
```

### 例4: キーワードのみ（フォールバック）

```bash
# 入力
/my:branch ユーザー認証を実装

# 出力
推奨ブランチ名: feature/user-authentication
プレフィックス: feature/
チケット番号: なし（フォールバック）
理由: 「実装」というキーワードから新機能と判断

代替案:
- feature/user-auth
- feature/authentication-system

⚠️ 注意: チケット番号がないブランチです
可能な限り課題管理システムでチケット作成を推奨
```

## Git ブランチ作成・操作コマンド

### ブランチ作成と移動

```bash
# 新規ブランチ作成と移動（ワンステップ）
git checkout -b feature/#12345

# 既存ブランチへ移動
git checkout feature/#12345

# ローカルブランチ一覧表示
git branch

# リモートブランチも含めて表示
git branch -a
```

### 前のブランチに戻る

```bash
# すぐ前のブランチに戻る（チェックアウト前）
git checkout -
```

### ブランチの削除

```bash
# ローカルブランチを削除
git branch -d feature/#12345

# リモートブランチを削除
git push origin --delete feature/#12345

# 強制削除（マージ前でも削除）
git branch -D feature/#12345
```

### ブランチ名の変更

```bash
# 現在のブランチ名を変更
git branch -m feature/new-name

# 特定のブランチ名を変更
git branch -m feature/#12345 feature/#54321
```

## トラブルシューティング

### ブランチが既に存在する場合

```bash
# エラーメッセージ
fatal: A branch named 'feature/#12345' already exists.

# 解決方法
# 1. 既存ブランチへチェックアウト
git checkout feature/#12345

# 2. 既存ブランチをリセット
git checkout feature/#12345
git reset --hard main

# 3. ブランチを削除して作成しなおす
git branch -D feature/#12345
git checkout -b feature/#12345
```

### main ブランチとの同期が取れていない場合

```bash
# main の最新を取得
git fetch origin main

# main をマージ
git merge origin/main

# または rebase
git rebase origin/main
```

### リモートに存在するブランチが見えない場合

```bash
# リモート情報を更新
git fetch origin

# 再度ブランチを確認
git branch -a
```

## ベストプラクティス

1. **チケット番号を優先**: キーワードより課題管理システムのチケット番号を使用
2. **短い名前を心がける**: 50文字以内が目安
3. **統一性の維持**: プレフィックスは一貫性を保つ
4. **リモート名と同期**: origin への push 時に同名のブランチを作成
5. **不要なブランチは削除**: マージ後は速やかにブランチを削除
6. **大文字は使わない**: URL 互換性のためケバブケース（小文字ハイフン区切り）推奨
