# Docker クリーンアップ処理手順

## ステップ1: 全体使用状況を確認

```bash
docker system df -v
```

このコマンドで以下を確認：

- イメージの使用量
- コンテナの使用量
- ボリュームの使用量
- ビルドキャッシュの使用量

## ステップ2: コンテナの状態を確認

### 実行中のコンテナ

```bash
docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.CreatedAt}}"
```

### 停止中のコンテナ

```bash
docker ps -a --filter "status=exited" --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.CreatedAt}}"
```

## ステップ3: ボリュームの状態を確認

### 未使用のボリューム

```bash
docker volume ls --filter "dangling=true"
```

### すべてのボリューム

```bash
docker volume ls --format "table {{.Name}}\t{{.Driver}}\t{{.Mountpoint}}"
```

## ステップ4: 未使用のイメージを確認

```bash
docker images --filter "dangling=true"
```

またはタグのないイメージ：

```bash
docker images --format "table {{.ID}}\t{{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}" | grep "<none>"
```

## ステップ5: 未使用のネットワークを確認

```bash
docker network ls --filter "dangling=true"
```

## ステップ6: ビルドキャッシュの使用状況を確認

```bash
docker system df | grep "Build Cache"
```

## クリーンアップコマンド集

### 停止中のコンテナを削除

```bash
docker container prune -f
```

または特定のコンテナを選択：

```bash
docker rm <container_id>
```

### 未使用のボリュームを削除

```bash
docker volume prune -f
```

### 未使用のイメージを削除

```bash
docker image prune -f
```

またはタグ付きも含めて削除：

```bash
docker image prune -a -f
```

### 未使用のネットワークを削除

```bash
docker network prune -f
```

### ビルドキャッシュを削除

```bash
docker builder prune -a -f
```

### すべてを一度にクリーンアップ

```bash
docker system prune -a --volumes -f
```

### 実行中のコンテナも含めてすべて削除

```bash
docker stop $(docker ps -q) 2>/dev/null || true
docker container prune -f
```

### すべてのボリュームを削除（使用中も含む）

```bash
docker stop $(docker ps -q) 2>/dev/null || true
docker volume rm $(docker volume ls -q) 2>/dev/null || true
```

### 完全クリーンアップ

```bash
# すべてのコンテナを停止して削除
docker stop $(docker ps -q) 2>/dev/null || true
docker rm -f $(docker ps -aq) 2>/dev/null || true

# すべてのボリュームを削除
docker volume rm $(docker volume ls -q) 2>/dev/null || true

# すべてのイメージを削除
docker rmi -f $(docker images -q) 2>/dev/null || true

# すべてのネットワークを削除（デフォルトネットワークは除く）
docker network prune -f

# すべてのビルドキャッシュを削除
docker builder prune -a -f
```

## 注意事項

- **実行中のコンテナの削除**: サービスが停止します
- **ボリュームの削除**: データが失われます。削除前に必ず確認してください
- **イメージの削除**: 使用中のイメージを削除するとコンテナの再起動に影響します
- **ネットワークの削除**: カスタムネットワークを削除するとコンテナの接続に影響します
- **ビルドキャッシュの削除**: 次回のビルドが遅くなります
