---
title: パフォーマンス分析・改善ガイドライン (Performance Analysis & Optimization)
impact: HIGH
tags: rails, performance, measurement, optimization, database, profiling
---

<!-- markdownlint-disable MD036 MD025 MD040 -->

## パフォーマンス分析・改善ガイドライン (Performance Analysis & Optimization)

Railsの性能劣化を「推測」ではなく「計測」で特定し、**計測→分類→施策→検証** で体系的に改善するガイドです。

> **関連**: 基本的なパフォーマンス確認項目は `perspective_03_performance.md` を参照してください。

---

## 0. 前提：Railsの遅さはまずDBを疑う

Railsが遅いケースの多くは以下のどれか：

- **SQL回数が多い** → N+1、ループ内SQL、無駄な副問い合わせ
- **1回のSQLが重い** → インデックス不足、件数爆発、複雑な結合
- **ロック待ち** → トランザクション長、並列更新、デッドロック
- **Ruby側が重い** → instantiate過多、JSON生成、allocation、GC
- **外部I/O待ち** → 外部API、S3、ActiveStorage、HTTP遅延

---

## 1. 計測の優先順位（推測禁止）

### 1.1 最初に見るべき値（8割これで決まる）

- **p50 / p95 / p99 レイテンシ** （平均は信用しない）
- **エラー率** （5xx / タイムアウト）
- **Throughput** （RPS / ジョブ処理数）
- **DB時間** （総時間 / 割合）
- **SQL回数** （頻出SQL、遅いSQL）
- **外部HTTP時間** （外部API、S3など）
- **リソース**: CPU / RSSメモリ / GC時間 / DB接続枯渇

### 1.2 原因当ての早見表（分類ルール）

| 観測値               | 推定原因                              | 確認項目                          |
| -------------------- | ------------------------------------- | --------------------------------- |
| SQL回数が多い        | N+1 / ループ内SQL / 無駄exists        | ログ分析、includes/preload導入    |
| DB時間が長い         | 遅いSQL / インデックス不足            | EXPLAIN ANALYZE、インデックス設計 |
| Ruby時間が長い       | instantiate過多 / serializer過剰      | pluck/pick導入、allocation削減    |
| p99だけ悪い          | ロック待ち / 外部API遅延 / GCスパイク | ロック分析、トランザクション短縮  |
| スループットが出ない | DB pool枯渇 / 並列度過多 / ブロック   | 接続数、キューイング              |

---

## 2. 計測ツール（環境別の定石）

### 2.1 開発環境（最速で原因が分かる）

**rack-mini-profiler**

- SQL回数 / 時間を可視化
- 遅いSQL・レンダリング時間を特定
- ブラウザで統計情報をリアルタイム表示

**bullet**

- N+1問題を自動検知（開発ログに警告）
- eager loadingの提案を表示
- テスト実行時にもN+1検知可能

### 2.2 ステージング/本番（最短で「どの経路が遅いか」を確定）

**APM（Application Performance Monitoring）**

- NewRelic / Datadog / Scout / Honeycomb など
- **Transactions**: 遅い経路ランキング、p95/p99表示
- **Traces**: DB / 外部I/O / テンプレート内訳
- **Slow SQL**: 頻出 × 遅い SQL を自動集計
- **Errors**: 例外、タイムアウト統計

**CloudWatch / Stackdriver（クラウド提供者）**

- ログ、メトリクスの可視化
- カスタムメトリクスでビジネスKPI計測

### 2.3 DB側（SQLを直すフェーズ）

**Postgres 想定**

```sql
-- 総時間が大きいSQL、頻出SQLを特定
SELECT query, calls, total_time, mean_time
FROM pg_stat_statements
ORDER BY total_time DESC LIMIT 20;

-- 実際のボトルネック・IO効率を確認
EXPLAIN (ANALYZE, BUFFERS) SELECT ...;
```

**ロック情報**

```sql
-- 現在のロック状態を確認
SELECT * FROM pg_locks;
SELECT pid, usename, state, query FROM pg_stat_activity WHERE state != 'idle';
```

**MySQL想定**

```sql
-- スロークエリログを有効化（設定で）
SET GLOBAL slow_query_log = 'ON';
SET GLOBAL long_query_time = 0.5;  -- 0.5秒以上

-- 実行計画確認
EXPLAIN FORMAT=JSON SELECT ...;
```

### 2.4 Ruby側（DBが支配的でない時）

**stackprof**

- CPU / Wall / Heap allocation を計測
- フレームグラフで実行時間の内訳を可視化

```ruby
require 'stackprof'
StackProf.run(mode: :wall, out: 'tmp/stackprof.dump') do
  # 計測対象コード
end
```

**memory_profiler / derailed_benchmarks**

- allocation削減、メモリリーク検出
- GC統計

---

## 3. ActiveRecord: SQLが「いつ」発行されるか（超重要）

### 3.1 SQLが発行されない（Relation構築だけ）

以下は通常SQLを発行しません：

```ruby
rel = User.where(active: true)           # SQL発行なし
rel = rel.order(id: :desc)               # SQL発行なし
rel = rel.limit(50)                      # SQL発行なし
rel = rel.includes(:posts)               # SQL発行なし（評価時に発行）
rel = rel.select('id, email')            # SQL発行なし
```

### 3.2 SQLが即発行される（評価トリガー）

#### A) 配列化 / 反復（危険度: 高）

```ruby
User.where(active: true).to_a             # SELECT ... （全件ロード）
User.where(active: true).each { |u| }    # SELECT ... （未ロードならSELECT）
User.where(active: true).map(&:email)    # SELECT ... (enumerable呼び出し)
User.where(active: true).select { ... }  # SELECT ... (ruby filter)
```

#### B) 値 / 件数 / 存在確認（危険度: 中）

```ruby
User.where(active: true).pluck(:id)      # SELECT id ...
User.where(active: true).pick(:email)    # SELECT ... LIMIT 1
User.where(active: true).count           # SELECT COUNT(*)
User.where(active: true).exists?         # SELECT 1 ... LIMIT 1
User.where(active: true).sum(:score)     # SELECT SUM(score) ...
```

#### C) 更新 / 削除（即SQL実行、コールバック注意）

```ruby
User.where(active: false).update_all(flagged: true)     # UPDATE (コールバック不走)
User.where(active: false).delete_all                    # DELETE (コールバック不走)
User.where(active: false).destroy_all                   # DELETE (コールバック走る、遅い)

Score.insert_all(rows)                                  # INSERT (validation/callback不走)
UserTag.upsert_all(rows, unique_by: %i[user_id tag])  # UPSERT
```

---

## 4. to_a / pluck / pick / ids / count / size / length の使い分け

### 4.1 to_a は「評価＋全件ロード」なので慎重に

❌ **禁止**: limitなしの to_a

```ruby
User.where(active: true).to_a              # メモリ事故（大量件数ロード）
```

✅ **許可**: 確実に少ない＋limit付き

```ruby
User.where(active: true).limit(100).to_a
```

### 4.2 値だけ欲しい → pluck / pick（instantiate回避）

- **pluck**: 複数行の値（Array）
- **pick**: 1行の値（単一値）

```ruby
ids   = User.where(active: true).pluck(:id)        # SELECT id ... ✅ instantiate不要
name  = User.where(id: 1).pick(:name)              # SELECT ... LIMIT 1 ✅ first→属性参照より軽い
```

### 4.3 ids は巨大配列に注意

```ruby
# ❌ 巨大データセットでメモリ死ぬ
all_ids = User.pluck(:id)  # 100万件ロード

# ✅ バッチ化、またはrelation処理で対応
User.in_batches(of: 5000).each do |rel|
  process_batch(rel)
end
```

### 4.4 件数が欲しい → count（size/lengthは曖昧）

```ruby
# ❌ 曖昧（未ロードならcount相当、ロード済みならlength相当）
User.where(active: true).size

# ✅ 明確：DBに問い合わせ
User.where(active: true).count
```

---

## 5. 大量データ処理：find_each / find_in_batches / in_batches

### 5.1 find_each（1件ずつ、Ruby処理時）

- 大量件数を安全に処理（メモリ安定）
- デフォルトで主キー(id)昇順バッチ

```ruby
User.where(active: true).find_each(batch_size: 1000) do |user|
  # user = User instance（1件ずつ）
  user.update_some_attribute
end
```

### 5.2 find_in_batches（バッチ配列で処理）

- insert_all等のバルク操作と相性が良い

```ruby
User.where(active: true).find_in_batches(batch_size: 2000) do |users|
  # users = Array<User>
  scores = users.map { |u| { user_id: u.id, score: 10 } }
  Score.insert_all(scores)
end
```

### 5.3 in_batches（relation単位、DB一括を優先）

- Rubyで触る必要がないなら最優先（SQL 1回で完結）

```ruby
# ✅ 最速：SQL 1本で全件更新
User.where(active: false).in_batches(of: 5000) do |rel|
  rel.update_all(flagged: true, updated_at: Time.current)
end

# ❌ 遅い：relation ごとにSQLを発行
User.where(active: false).in_batches(of: 5000) do |rel|
  rel.each { |user| user.update(flagged: true) }
end
```

### 5.4 バッチ処理の落とし穴

バッチ中に対象が更新/追加されると漏れ/重複の可能性：

- **対策**: 冪等設計 / 対象固定（cutoff）/ キュー化

---

## 6. バルク操作：insert_all / upsert_all / update_all / delete_all

### 6.1 insert_all の性質（速いが副作用あり）

```ruby
# ❌ 注意：以下は実行されない
# - validation
# - callback (after_create, before_save など)
# - counter_cache, touch
# - timestamps（明示が安全）

# ✅ 正しい使用
now = Time.current
rows = users.map { |u|
  {
    user_id: u.id,
    score: 10,
    created_at: now,
    updated_at: now
  }
}
Score.insert_all(rows)
```

### 6.2 upsert_all の前提

- **unique index が必須**
- **unique_by を明示**（衝突判定をDBに委ねる）

```ruby
UserTag.upsert_all(rows, unique_by: %i[user_id tag_id])
```

### 6.3 update_all / delete_all

- コールバック不要なら最強（1SQL）
- ただしアプリレベル整合性を確認

```ruby
# ✅ 高速：1SQL
User.where(active: false).update_all(flagged: true, updated_at: Time.current)

# ❌ 遅い：コールバック実行、複数SQL
User.where(active: false).each { |u| u.update(flagged: true) }
```

---

## 7. N+1対策：includes / preload / eager_load

**関連テーブルで絞り込み/並び替え → eager_load or joins+preload**

```ruby
# ✅ eager_load（JOINで1SQL）
posts = Post.eager_load(:comments).where('comments.approved = ?', true)

# または
posts = Post.joins(:comments).preload(:comments).where('comments.approved = ?', true)
```

**表示のために関連を読むだけ → preload**

```ruby
# ✅ preload（別SQLで読み込み）
posts = Post.preload(:user, :comments).limit(50)
```

**条件分岐が複雑 → includes（自動で判定）**

```ruby
# ✅ includes（状況で切替）
posts = Post.includes(:comments).limit(50)
```

---

## 8. インデックスとクエリ設計

### インデックス設計のルール

- WHERE / JOIN / ORDER BY に沿うインデックスがないと勝てない
- EXPLAIN でSeq Scanなら基本負け

```sql
-- ❌ これはSeq Scan
SELECT * FROM posts WHERE title LIKE '%foo%';

-- ✅ インデックス活用（前方一致）
SELECT * FROM posts WHERE title LIKE 'foo%';

-- インデックス例
CREATE INDEX idx_posts_title ON posts(title);
CREATE INDEX idx_orders_user_created ON orders(user_id, created_at DESC);
```

### EXPLAIN の確認

```sql
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM posts WHERE user_id = 1;
-- Seq Scan なら負け
-- Index Scan / Bitmap Index Scan なら勝ち
```

---

## 9. ロック / トランザクション / 並列（p99悪化の主因）

### ロック戦略の基本

- **長いトランザクション** = ロック保持が長い = 詰まる
- **同一テーブル並列更新** = ロック待ち増加
- **並列度を上げれば速い** は幻想（DBが詰まる）

### 基本方針

- **バッチ化** + **短いトランザクション**
- **同一キー（tenant/user等）の直列化**検討
- Sidekiq等のキュー分離/並列度調整

```ruby
# ❌ 長いトランザクション（ロック待ちで詰まる）
User.transaction do
  user = User.lock.find(1)
  external_api_call()  # 外部API待ち
  user.update(...)
end

# ✅ 短いトランザクション
result = external_api_call()
User.transaction do
  user = User.lock.find(1)
  user.update(...)
end
```

関連詳細は `perspective_02_security.md`（競合状態の観点）を参照してください。

---

## 10. Ruby側の重さ（DBじゃない時）

- **instantiate削減** → pluck/pick導入
- **不要なselect列削減** → select('id, email')
- **JSON生成/serializer過剰** → 削減、ストリーミング
- **allocation削減** → 巨大配列map回避
- **GC時間が目立つ** → memory_profiler で詳細分析

```ruby
# ❌ instantiate過多、allocation大
@users = User.all
@user_emails = @users.map(&:email)

# ✅ 効率的
@user_emails = User.pluck(:email)
```

---

## 11. エージェント実行フロー（必ずこの順番）

1. **対象を1つに絞る** （エンドポイント/ジョブ）
2. **p95/p99、DB時間、SQL回数、外部HTTP時間を取得**
3. **原因を 1つに分類** （DB回数/DB時間/Ruby/ロック/外部）
4. **施策を最大2つに絞って実装** （多発禁止）
5. **Before/After を提示** （p95、SQL回数、DB時間）
6. **残課題があれば次の分類へ進む**

---

## 12. レビュー時に必ず見るチェック項目（機械的に指摘）

- [ ] limitなしの `to_a` / `length` / `map` を見つけたら改善提案
- [ ] `map(&:id)` があれば `pluck(:id)` を検討
- [ ] 1件だけ必要なら `pick` を検討（`first→属性参照`を避ける）
- [ ] 件数取得で `size`/`length` を使っていたら `count` を検討
- [ ] ループ内SQLがあれば `includes`/`preload` を検討
- [ ] `create!`/`save!` の大量ループがあれば `insert_all`/`upsert_all` を検討
- [ ] Rubyで回さず `relation.in_batches(...).update_all` を検討
- [ ] 遅いSQLがあれば EXPLAIN とインデックスを検討
- [ ] 長いtransaction/並列更新でロック待ちになってないか疑う
- [ ] 外部I/Oをリクエスト内で同期的に待っていないか疑う

---

## 13. 変更提案のアウトプット規約（PR品質）

変更の説明は必ず以下のどれかで理由付けする：

- **SQL回数が減る** （N+1削減）
- **DB時間が減る** （インデックス/クエリ改善）
- **instantiateが減る** （pluck/pick導入）
- **ロック待ちが減る** （トランザクション短縮/直列化）
- **外部I/O待ちが減る** （非同期化/キャッシュ）

### PRに必須の情報

```markdown
**対象**: {endpoint / job}
**データ規模**: {件数オーダー}

**Before**:

- p95: {ms}
- SQL count: {n}
- DB time: {ms or %}

**After**:

- p95: {ms}
- SQL count: {n}
- DB time: {ms or %}

**施策**: {最大2つ}
**副作用**: {callback/validation/整合性など}
**ロールバック方針**: {戻し方}
```

---

## 14. 確認方法（計測方法）：Before/After を再現可能にする

### 14.1 原則

- "速くなった気がする"は禁止。必ず **数値で比較** する。
- 比較対象は「同じ条件（同じデータ規模・同じ入力・同じ環境）」で揃える。
- 改善は最大2点まで（同時に多発すると因果が不明になる）。

### 14.2 開発環境での確認（最短ルート）

**SQL回数/時間を確認**

```bash
# Gemfile
gem 'rack-mini-profiler'
gem 'bullet'

# config/environments/development.rb
config.middleware.use Rack::MiniProfiler
Bullet.enable = true
```

ブラウザの右上に表示される **SQL time / SQL count** を確認：

```text
Total time: 250ms
SQL time: 150ms (60%)
SQL count: 15
```

**N+1の有無確認**

Bulletが開発ログに以下のような警告を出す：

```text
[Bullet] N+1 Query: SELECT ... with includes ...
[Bullet] Unnecessary Eager Load Detected ...
```

### 14.3 ステージング/本番での確認（APMがある場合）

APMで必ず以下を取得して比較する：

- **対象トランザクションの p95 / p99**
- **DB時間**（総時間/割合）
- **SQL回数**
- **Top Slow SQL**（頻出×遅い）
- **外部HTTP時間**（外部I/Oがある場合）

---

## 15. キャッシング戦略（Rails Cache機構）

### 15.1 キャッシュレイアウト（階層別）

Railsのキャッシュは複数レイアウトで構成される：

| レイヤー                   | 用途                                   | 実装                               |
| -------------------------- | -------------------------------------- | ---------------------------------- |
| **HTTP キャッシュ**        | ブラウザ/CDNに保存（帯域削減）         | ETag, Last-Modified, Cache-Control |
| **ページキャッシュ**       | 静的HTMLをディスク保存（廃止傾向）     | 現在はリバースプロキシやCDNで代替  |
| **フラグメントキャッシュ** | ビューの一部をMemcache/Redisに保存     | `cache do ... end`                 |
| **ロシアンドール**         | ネストしたフラグメント（更新時に連鎖） | updated_at をキー含める            |
| **低レベルキャッシュ**     | 任意のデータをキャッシュ（計算結果等） | `Rails.cache.fetch`                |

### 15.2 実装パターン

**フラグメントキャッシュ：**

```erb
<% cache @post do %>
  <h1><%= @post.title %></h1>
  <div><%= @post.body %></div>
<% end %>
```

Rails は自動的に `@post.cache_key`（`"post/123-20250322120000"`）をキーとする。`@post.updated_at`が変わればキーが変わり自動無効化される。

**ロシアンドール（ネスト）：**

```erb
<% cache @post do %>
  <h1><%= @post.title %></h1>

  <% @post.comments.each do |comment| %>
    <% cache comment do %>
      <%= comment.body %>
      <small><%= comment.updated_at %></small>
    <% end %>
  <% end %>
<% end %>
```

1つのコメントが更新されれば、そのコメント部分だけ無効化される（親キャッシュは生き残る）。

**低レベルキャッシュ：**

```ruby
# app/controllers/products_controller.rb
def index
  @products = Rails.cache.fetch("products:count", expires_in: 1.hour) do
    Product.count
  end
end
```

計算結果など、任意のデータを1時間キャッシュ。

### 15.3 バックエンド設定

開発・テスト環境：

```ruby
# config/environments/development.rb
config.cache_store = :memory_store
```

本番環境（Memcache または Redis）：

```ruby
# config/environments/production.rb
config.cache_store = :mem_cache_store, ENV['MEMCACHE_SERVERS'].split(',')
# または
config.cache_store = :redis_cache_store, {
  url: ENV['REDIS_URL'],
  expires_in: 24.hours
}
```

### 15.4 キャッシュキー管理

**`cache_key` と `touch`:**

```ruby
class Post < ApplicationRecord
  has_many :comments, dependent: :destroy

  # 自動的に updated_at をキーに含める
  # => "post/123-20250322120000"

  def cache_key_with_version
    super + "-v2"  # キャッシュ形式が変わった時のバージョン指定
  end
end

# ビューで
<% cache @post do %>
  ...
<% end %>
```

**手動キー指定：**

```ruby
Rails.cache.fetch("expensive_computation:#{params[:id]}", expires_in: 1.day) do
  # 重い計算処理
  expensive_operation
end
```

### 15.5 HTTP キャッシング

ブラウザキャッシュを活用すれば、サーバアクセス自体を削減：

```ruby
def show
  @post = Post.find(params[:id])

  if stale?(@post)  # @post.updated_at が変わってなければ 304 Not Modified
    render :show
  end
end
```

または：

```ruby
def show
  @post = Post.find(params[:id])
  fresh_when(@post, public: true)  # Cache-Control: public を設定
end
```

**レスポンスヘッダ：**

```text
Cache-Control: public, max-age=3600
ETag: "abc123..."
Last-Modified: Mon, 22 Mar 2025 12:00:00 GMT
```

ブラウザは `Last-Modified` や `ETag` が変わらなければリクエストを送らない。

### 15.6 キャッシュ戦略のベストプラクティス

**キャッシュすべき処理：**

- 頻繁にアクセスされるが、滅多に変わらないデータ（Product一覧の合計数など）
- 計算コストが高い処理（複雑な集計、外部API呼び出し）
- 重い View レンダリング（パーシャル多数含む）

**キャッシュ避けるべき処理：**

- ユーザー認証情報（session はキャッシュしない）
- リアルタイム性が必須のデータ（在庫数など）
- キャッシュキーが一意でない（user_id に依存し、共有キーで危険）

**無効化パターン：**

```ruby
# 関連データ更新時に手動無効化
class Comment < ApplicationRecord
  belongs_to :post, touch: true  # post.updated_at を自動更新

  after_create do
    Rails.cache.delete("post:#{post_id}:comments:count")
  end
end
```

---

## 関連観点

- `perspective_03_performance.md` - パフォーマンス評価観点（全般）

比較は「改善前後で同じ時間帯/同程度の負荷」を意識する。

### 14.4 ステージング/本番での確認（APMがない場合：ログ計測）

**Railsログから遅延を拾う**

```bash
# productionログの request_id 単位で確認
grep "request_id=abc123" log/production.log | grep "Completed"

# 出力例
[2024-01-15T10:30:00] Completed 200 OK in 150ms (db: 100ms, view: 30ms)
```

**「遅いSQLログ」を使う（DB側）**

```sql
-- Postgres
SET log_min_duration_statement = 100;  -- 100ms以上のSQLをログ出力

-- MySQL
SET GLOBAL slow_query_log = 'ON';
SET GLOBAL long_query_time = 0.1;
```

### 14.5 EXPLAIN の確認ルール（SQL改善時は必須）

SQLを変えた/インデックスを追加した場合は以下を確認：

```sql
-- Before
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM posts WHERE user_id = 1;
-- Seq Scan ... (rows=100000) ❌ 遅い

-- After（インデックス追加後）
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM posts WHERE user_id = 1;
-- Index Scan ... (rows=100) ✅ 軽い
```

### 14.6 バッチ・ジョブの確認（find_each / insert_all 等）

以下のメトリクスを必ず出す：

```text
処理件数: 10000 items
所要時間: 15 seconds (1.5ms per item)
バッチサイズ: 1000
DBへの書き込み回数: 10 batches
エラー: 0
```

### 14.7 Before/After フォーマット例（PRに貼る）

```markdown
## パフォーマンス改善: User.where(active:true).each の N+1 削減

**対象**: GET /users

**Before**:
```

p95: 850ms
SQL count: 101 (1 main query + 100 user queries)
DB time: 650ms

```text

**After**:
```

p95: 120ms
SQL count: 2 (1 main query + 1 eager load)
DB time: 85ms

```text

**施策**:
- `User.all.each` → `User.preload(:posts)`に変更

**副作用**: なし

**ロールバック**: コミットを revert
```

### 14.8 典型的な「確認観点」と「期待される改善」

| 施策                            | 期待される改善                             | 確認方法                            |
| ------------------------------- | ------------------------------------------ | ----------------------------------- |
| includes/preload導入            | SQL countが減る（N+1が消える）             | SQLログ分析、bullet確認             |
| pluck/pick導入                  | Ruby時間/メモリが減る（instantiateが減る） | rack-mini-profiler、memory_profiler |
| insert_all/upsert_all導入       | 書き込みSQL回数が激減                      | SQLログ数                           |
| in_batches + update_all         | Ruby処理が減りDB一括になって速い           | 所要時間、SQL回数                   |
| インデックス追加                | DB timeが減る（遅いSQLが軽くなる）         | EXPLAIN ANALYZE                     |
| トランザクション短縮/並列度調整 | p99が改善（ロック待ちが減る）              | APM、pg_locks確認                   |

---

## 15. よくある落とし穴（アンチパターン）

### ❌ 測定なしで「速い」を主張

```ruby
# ❌ 根拠なし
# "これは高速です" → でもSQL数は変わらない？

# ✅ 数値で証明
# "SQL count: 20 → 2, DB time: 500ms → 50ms"
```

### ❌ 複数の改善を同時に実施

```ruby
# ❌ 因果不明
# includes導入 + インデックス追加 + キャッシュ追加を同時実施
# → どれが効いたか不明

# ✅ 1つずつ計測
# Step 1: includes導入 → 計測
# Step 2: インデックス追加 → 計測
```

### ❌ limitなしのto_a（メモリ事故）

```ruby
# ❌ 危険
users = User.where(active: true).to_a  # 100万件ロード

# ✅ 安全
users = User.where(active: true).limit(100).to_a
User.where(active: true).find_each { |u| ... }
```

### ❌ destroy_all（コールバック走って遅い）

```ruby
# ❌ 遅い（1件ずつdestroy）
User.where(active: false).destroy_all

# ✅ 高速（1SQLで削除）
User.where(active: false).delete_all
```

---

## まとめ：効果的な性能改善フロー

1. **計測** → APM/APTで p95、SQL count、DB time を取得
2. **分類** → 「DB回数か」「DB時間か」「Ruby か」「ロック か」「外部I/Oか」を特定
3. **施策** → 最大2点まで絞って実装
4. **検証** → 同じ条件で Before/After を計測
5. **ロールバック戦略** → 必ず出してから実装

---

## 参考リンク

- 関連規約: `perspective_03_performance.md` (基本確認項目)
