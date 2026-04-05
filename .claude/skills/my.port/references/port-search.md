# ポート番号検索・管理ガイド

## ポート確認コマンド

### macOS での確認

特定のポート番号を確認：

```bash
lsof -i :<ポート番号>
```

詳細情報を取得：

```bash
lsof -i :<ポート番号> -P -n
```

### Linux での確認

```bash
netstat -tuln | grep :<ポート番号>
# または
ss -tuln | grep :<ポート番号>
```

## プロセス情報の取得

PID からプロジェクト情報を特定：

```bash
# 作業ディレクトリを取得
lsof -p <PID> | grep cwd

# プロジェクト名を抽出（ディレクトリの最後の部分）
basename "$PROJECT_DIR"

# Railsアプリかどうかを確認
test -f "$PROJECT_DIR/Gemfile" && test -f "$PROJECT_DIR/config/application.rb" && echo "Railsアプリ"
```

より詳細な情報：

```bash
lsof -i :<ポート番号> -P -n | awk 'NR>1 {print $2, $1, $9}'
```

## 空きポート検索（開発用ポート範囲）

### 3000番台の空きポート（macOS）

```bash
for port in {3000..3099}; do
  if ! lsof -i :$port > /dev/null 2>&1; then
    echo "$port"
  fi
done | head -10
```

### 3000番台の空きポート（Linux）

```bash
for port in {3000..3099}; do
  if ! netstat -tuln | grep -q ":$port "; then
    echo "$port"
  fi
done | head -10
```

### 4000番台・5000番台

3000 を 4000 または 5000 に置き換えて実行

## 使用中のポート一覧表示

3000 番台で使用中のポートを確認：

```bash
for port in {3000..3099}; do
  if lsof -i :$port > /dev/null 2>&1; then
    PID=$(lsof -i :$port -P -n -t | head -1)
    if [ -n "$PID" ]; then
      PROJECT_DIR=$(lsof -p $PID 2>/dev/null | grep cwd | awk '{print $NF}')
      PROJECT_NAME=$(basename "$PROJECT_DIR" 2>/dev/null || echo "不明")
      echo "$port (使用中 - プロジェクト名: $PROJECT_NAME)"
    fi
  fi
done
```

## プロセス終了

### 通常の終了

```bash
kill <PID>
```

### 強制終了（応答しない場合）

```bash
kill -9 <PID>
```

## 推奨ポート番号

| 番台     | 用途                           | 例                  |
| -------- | ------------------------------ | ------------------- |
| 3000番台 | Next.js・React 開発サーバー    | 3000, 3001, 3002... |
| 4000番台 | API サーバー・バックエンド     | 4000, 4001, 4002... |
| 5000番台 | 追加サーバー・マイクロサービス | 5000, 5001, 5002... |

## ポート競合の解決

ポートが使用中の場合：

1. **プロセス情報を確認**

   ```bash
   lsof -i :<ポート番号>
   ```

2. **プロセスを終了** (ユーザー確認後)

   ```bash
   kill <PID>
   ```

3. **近くの空きポートを探す**
   - 同じ番台（3000番台など）から探す
   - または、別の番台を使用

## トラブルシューティング

### 「Permission denied」エラー

- 1024番以下のポートは管理者権限が必要な場合があります
- `sudo` で実行するか、別のポートを使用してください

### ポート確認ツールが見つからない

- `lsof` がない場合は `netstat` を使用
- `netstat` もない場合は `ss` を試す

```bash
which lsof    # lsof がある確認
which netstat # netstat がある確認
which ss      # ss がある確認
```

## ポート確認スクリプト（汎用）

```bash
#!/bin/bash
PORT=$1

if [ -z "$PORT" ]; then
  echo "使用方法: $0 <ポート番号>"
  exit 1
fi

# macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
  echo "ポート $PORT の使用状況:"
  lsof -i :$PORT -P -n
  PID=$(lsof -i :$PORT -P -n -t | head -1)
  if [ -n "$PID" ]; then
    echo ""
    echo "プロセス情報:"
    ps -p $PID -o pid,user,command
    PROJECT_DIR=$(lsof -p $PID 2>/dev/null | grep cwd | awk '{print $NF}')
    echo "プロジェクト: $(basename "$PROJECT_DIR")"
  else
    echo "ポート $PORT は使用可能です"
  fi
# Linux
elif [[ "$OSTYPE" == "linux"* ]]; then
  echo "ポート $PORT の使用状況:"
  netstat -tuln | grep ":$PORT"
  ss -tuln | grep ":$PORT"
fi
```
