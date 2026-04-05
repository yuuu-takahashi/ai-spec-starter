---
name: my.cloudwatch
description: AWS CloudWatch Logs Insights のクエリを生成するための手順を提供するスキル。コマンド構文（filter, stats, parse 等）と代表的なクエリパターンに従い、ログ分析用のクエリを出力する。他コマンド・スキルから「CloudWatch ログのクエリを書きたい」ときに参照する。
allowed-tools: Read, Write
---

# CloudWatch Logs Insights クエリ生成スキル

AWS CloudWatch Logs Insights のクエリを生成するときに参照する手順です。他コマンド・スキルから「CloudWatch のログクエリを生成したい」ときに使います。

## いつ使うか

- 障害調査・ログ分析用の CloudWatch Logs Insights クエリを書きたいとき
- ドキュメントや Runbook に「こんなクエリを実行する」例を載せたいとき
- Lambda・API Gateway・VPC Flow Logs・CloudTrail など、ログ種別に合わせたクエリ例が欲しいとき

## 構文の基本

- **複数コマンド**: パイプ `|` でつなぐ。例: `fields @timestamp, @message | filter ... | sort @timestamp desc | limit 25`
- **コメント**: `#` で始める
- **組み込みフィールド**: `@timestamp`, `@message`, `@logStream`, `@requestId`, `@type`（Lambda の REPORT など）は多くのログで利用可能

## 主なコマンド

| コマンド | 用途                                                                             |
| -------- | -------------------------------------------------------------------------------- |
| `fields` | 結果に出すフィールドを指定。`fields @timestamp, @message, status`                |
| `filter` | 条件に合うログだけに絞る。`filter @message like /Error/`                         |
| `stats`  | 集計。`count(*)`, `sum()`, `avg()`, `max()`, `min()`, `count_distinct()` と `by` |
| `sort`   | 並び替え。`sort @timestamp desc` または `sort exceptionCount desc`               |
| `limit`  | 件数制限。`limit 25`                                                             |
| `dedup`  | 指定フィールドで重複除去。`dedup @requestId` や `dedup server, severity`         |
| `parse`  | ログ文字列からフィールド抽出。glob `"* [*] *" as a, b, c` または正規表現         |

## filter の条件例

- 正規表現: `@message like /Exception/`、`@message not like /Exception/`
- 比較: `status >= 400 and status <= 499`、`@duration > 1000`
- 等価: `@type = "REPORT"`、`eventName = "CreateUser"`
- 存在: `ispresent(errorCode)`
- リスト: `tlsDetails.tlsVersion in [ "TLSv1", "TLSv1.1" ]`
- サブネット: `isIpv4InSubnet(srcAddr, "192.0.2.0/24")`（VPC Flow Logs など）

## stats の例

- 時間単位の件数: `stats count(*) as exceptionCount by bin(1h)`
- フィールド別件数: `stats count(*) by eventSource, eventName, awsRegion`
- 合計・平均: `stats sum(bytes) as bytesTransferred by srcAddr`、`stats avg(@duration), max(@duration) by bin(5m)`
- ユニーク数: `stats count_distinct(remoteIP) as UniqueVisits`

## クエリ例（コピーしてロググループ・期間を指定して利用）

### 汎用

```text
# 直近25件
fields @timestamp, @message | sort @timestamp desc | limit 25

# 例外が含まれるログを1時間ごとに集計
filter @message like /Exception/ | stats count(*) as exceptionCount by bin(1h) | sort exceptionCount desc

# サーバーごと最新1件
fields @timestamp, server, severity, message | sort @timestamp desc | dedup server
```

### Lambda

```text
# メモリ過多プロビジョニングの把握
filter @type = "REPORT"
| stats max(@memorySize / 1000 / 1000) as provisonedMB, max(@maxMemoryUsed / 1000 / 1000) as maxUsedMB by bin(1h)

# 遅い実行（1秒超）を requestId で重複除去して20件
fields @timestamp, @requestId, @message, @logStream
| filter @type = "REPORT" and @duration > 1000
| sort @timestamp desc | dedup @requestId | limit 20
```

### API Gateway アクセスログ

```text
# 直近の4xxを10件
fields @timestamp, status, ip, path, httpMethod
| filter status >= 400 and status <= 499
| sort @timestamp desc | limit 10

# パス別リクエスト数
stats count(*) as requestCount by path | sort requestCount desc | limit 10
```

### CloudTrail

```text
# サービス・イベント・リージョン別件数
stats count(*) by eventSource, eventName, awsRegion

# 特定イベント（例: EC2 起動/停止）
filter (eventName="StartInstances" or eventName="StopInstances") and awsRegion="us-east-2"
```

### parse でフィールド抽出

```text
# glob で user, method, latency を抽出して平均
parse @message "user=*, method:*, latency := *" as @user, @method, @latency
| stats avg(@latency) by @method, @user

# 正規表現で抽出
parse @message /user=(?<u>.*?), method:(?<m>.*?), latency := (?<lat>.*?)/
| stats avg(lat) by m, u
```

## ベストプラクティス

- **時間範囲**: 必要最小限に絞る（コスト・パフォーマンスのため）
- **ロググループ**: クエリに必要なロググループだけを選択する
- **limit**: 大量結果が想定されるときは `limit` を付ける
- **コンソール**: コンソールを閉じる前にクエリをキャンセルしないとバックグラウンドで継続実行される点に注意

## 参考

- [CloudWatch Logs Insights クエリ構文](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/CWL_QuerySyntax.html)
- [Sample queries](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/CWL_QuerySyntax-examples.html)
- [演算子・関数一覧](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/CWL_QuerySyntax-operations-functions.html)
