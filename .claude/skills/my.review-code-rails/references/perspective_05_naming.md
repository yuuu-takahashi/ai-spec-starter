---
title: 命名
impact: MEDIUM
tags: rails, review-code, naming
---

<!-- markdownlint-disable MD036 -->

## 命名

レビュー時の命名確認チェックリスト。
基本的な命名規則（snake_case, CamelCase 等）は `.claude/rules/rails-basics.md` を参照。
Service Object の命名は `.claude/rules/rails-service-objects.md` を参照。

### 基本原則

- [ ] **英語の使用**: 日本語やローマ字表記が使われていないか
- [ ] **意図の明確性**: 変数名・メソッド名が何を表すか読み取れるか
- [ ] **省略の回避**: `usr`, `mgr` のような不明瞭な省略がないか（`params`, `config` 等の一般的なものは可）
- [ ] **統一性**: プロジェクト内で命名規則が一貫しているか

### 複合語モデル名（perspective 固有）

モデル名の複合語は以下の 2 パターンに従うべき:

**パターン1: 形容詞 + 名詞**（状態を表現）

- `AttachedFile`, `PublishedPost`, `ActiveUser`, `DisabledAccount`
- 第一の単語が過去分詞形容詞（`Attached`, `Published`）の場合

**パターン2: 名詞 + 名詞**（関係性を表現）

- `UserProfile`, `PostComment`, `OrderItem`
- メソッド名と混同される順序は避ける（`CommentPost` → `PostComment`）

### メソッド命名

- [ ] **getter は名詞**: `name`, `email`, `status`（`get_name` としない）
- [ ] **action は動詞**: `create`, `activate`, `notify_expiration`
- [ ] **述語は `?`**: `admin?`, `active?`, `valid?`（`is_admin?` としない）
- [ ] **破壊的は `!`**: 対応する非破壊版も用意する

### Rails 特有の命名

- [ ] **scope**: 形容詞・単数形で、連鎖可能（`User.active.verified.recent`）
- [ ] **アソシエーション**: `has_many` は複数形、`belongs_to` は単数形
- [ ] **enum**: 単数形で意味のあるキー
- [ ] **コールバック**: 処理内容を動詞で表現（`normalize_email`, `generate_token`）
- [ ] **Controller**: RESTful 7 アクション準拠、カスタムアクションは動詞

### 前置詞パターン辞書（perspective 固有）

Rails エコシステムで広く使われる前置詞パターン:

| 前置詞 | 意味 | 例 |
| --- | --- | --- |
| `with_` | 何かを含める | `with_posts`, `create_with_profile`, `with_lock` |
| `without_` | 何かを除外 | `without_posts`, `without_avatar` |
| `by_` | 検索条件・並び順 | `by_name`, `by_created_at`, `find_by_email` |
| `for_` | 特定の対象用 | `for_admin`, `for_date_range` |
| `from_` / `to_` | データの移動 | `import_from_csv`, `export_to_json` |
| `at_` | 特定の時点 | `created_at_today` |
| `before_` / `after_` | 時間的前後 | `before_expiry`, `after_deadline` |
| `in_` / `on_` | 範囲・状態 | `in_progress`, `in_review`, `in_japan` |

- 前置詞は 1〜2 個まで。3 つ以上必要なら Service に分離する
