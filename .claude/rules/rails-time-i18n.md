---
paths:
  - '**/*.rb'
---

# 時刻・タイムゾーン / I18n 規約

## 時刻の基本原則

- DB には UTC で保存する。表示時にユーザーのタイムゾーンに変換する
- `Time.now` ではなく `Time.zone.now` を使う（`Time.current` も可）
- `Date.today` ではなく `Time.zone.today` を使う

## タイムゾーン変換

- 文字列からの変換は `in_time_zone` を使う（`to_time` は TZ 情報が欠落する）
- API レスポンスは ISO 8601 形式（`2024-01-15T10:30:00Z`）で統一する
- ユーザーごとのタイムゾーンは `timezone` カラムに IANA 名で保存する

## I18n

- テンプレートにテキストをハードコードしない。`t('key')` で管理する
- 日付表示は `l(date, format: :long)` を使う（`strftime` は多言語対応不可）
- I18n キーは階層化する（`labels.user.name`, `errors.user.not_found`）
- `config.i18n.default_locale` と `available_locales` を明示的に設定する

## DO NOT

- `Time.now` / `Date.today` を使わない（タイムゾーンが不定）
- タイムゾーンなしの文字列で日時比較しない
- 翻訳キーを重複定義しない（同じテキストに複数キー）
- `strftime` でフォーマットしない（`l()` ヘルパーを使う）
