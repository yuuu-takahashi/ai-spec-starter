---
name: my.branch-name
description: チケット番号またはキーワードから、チームの Git ブランチフロー規約に基づいたブランチ名を生成します。生成後は main を更新してブランチに移動します。
compatibility: |
  - git リポジトリであること
---

<!-- markdownlint-disable MD041 MD040 -->

# my:branch

## 概要

課題管理システムと連携したブランチ名を生成し、ブランチへの移動まで自動実行するスキルです。

## いつ使うか

- チケットから素早くブランチを作成したい
- ブランチ命名規則に従った名前を自動生成したい
- 新しい機能開発を始めたい

## 使用方法

```text
/my:branch <チケット番号またはキーワード>
```

### パラメータ例

- `/my:branch #12345` - GitHub Issue 形式
- `/my:branch PROJECT-9403` - JIRA/Backlog 形式
- `/my:branch ユーザー認証機能を追加` - キーワード形式
- `/my:branch hotfix #12345` - プレフィックス明示

## ブランチ命名規則

| 種類    | 命名規則                                          | 例                                       |
| ------- | ------------------------------------------------- | ---------------------------------------- |
| feature | `feature/${チケット番号}`                         | `feature/#12345`, `feature/PROJECT-9403` |
| hotfix  | `hotfix/${チケット番号}`                          | `hotfix/#12345`                          |
| topic   | `topic/${チケット番号}`                           | `topic/#12345`                           |
| release | `release/${yyyymmdd}` または `release/${version}` | `release/20240203`, `release/v1.2.0`     |
| develop | `develop` 固定                                    | `develop`                                |
| main    | `main` 固定                                       | `main`                                   |

## 処理フロー

### 1. 引数の取得と確認

- `$1` から入力を取得
- 未指定の場合はエラー表示

### 2. チケット番号の抽出

- **GitHub Issue**: `#12345` を検出
- **JIRA/Backlog**: `PROJECT-9403` パターンを検出
- **その他**: キーワードとして扱う

### 3. プレフィックスの決定

**チケット番号がある場合**:

- デフォルト: `feature/`
- 明示的指定時: `hotfix/`, `topic/`, `release/` など対応

**キーワードのみの場合**:
キーワード内容から推測

- 「追加」「実装」「作成」など → `feature/`
- 「緊急」「hotfix」など → `hotfix/`
- 「リリース」「release」など → `release/`
- その他 → `feature/`（デフォルト）

### 4. ブランチ名の生成

- **チケット番号あり**: `<prefix>/<チケット番号>`
- **キーワードのみ**: `<prefix>/<正規化キーワード>`
  - 日本語 → 英語に変換
  - 特殊文字 → `-` に統一
  - 小文字に統一（ケバブケース）
  - 50文字以内

### 5. main の更新とブランチへの移動

**必ず実行される** (ユーザー要求の有無にかかわらず):

1. `git checkout main` - main ブランチに移動
2. `git fetch origin main` - リモート main を最新に取得
3. ブランチ存在確認
   - 存在 → `git checkout <ブランチ名>`
   - 未存在 → `git checkout -b <ブランチ名>` で新規作成

## 出力例

```text
推奨ブランチ名: feature/#12345

プレフィックス: feature/
チケット番号: #12345
理由: GitHub Issue番号が検出されました。

ブランチ作成コマンド:
git checkout -b feature/#12345

✅ ブランチへ移動しました！
```

## チケット番号がない場合

```text
推奨ブランチ名: feature/user-authentication

プレフィックス: feature/
チケット番号: なし（フォールバック）
理由: 「追加」というキーワードから新機能と判断

代替案:
- feature/add-user-auth
- feature/user-auth

⚠️ 注意: チケット番号がないブランチ名です。
可能な限り課題管理システムでチケット作成を推奨します。
```

## 注意事項

- チケット番号を優先的に使用（課題管理システムとの連携）
- プレフィックス必須（feature, hotfix, topic, release など）
- 日本語は避ける（英語またはローマ字読み）
- ブランチ名は50文字以内を推奨
- 既存ブランチとの重複確認
