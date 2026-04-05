<!-- markdownlint-disable MD036 MD024 -->

# Docker（Dockerfile / docker-compose / .dockerignore）

## Dockerfile

### ベストプラクティス

#### マルチステージビルド

- ビルド環境と実行環境が分離されているか（特にGo、Rust、C++などのコンパイル言語）
- 実行ステージでビルドツールが含まれていないか
- distrolessやalpineなどの軽量なベースイメージを使用しているか

#### キャッシュ最適化

- 依存関係の取得（`go mod download`, `npm install`など）がソースコードのコピーより前に実行されているか
- 変更頻度の低いファイル（`go.mod`, `package.json`など）が先にコピーされているか

#### RUN命令のまとめ方

- 関連する操作が1つのRUNにまとめられているか
- `apt-get update` と `apt-get install` が同じRUN内で実行されているか
- `apt-get clean` と `rm -rf /var/lib/apt/lists/*` がインストール後に実行されているか
- `--no-install-recommends` オプションが使用されているか

#### ベースイメージのバージョン固定

- `latest` タグを使用していないか
- 特定のバージョンが指定されているか
- LTSバージョンや安定版が使用されているか

#### ENTRYPOINTとCMDの使い分け

- アプリケーションのメインコマンドがENTRYPOINTで固定されているか
- 環境によって変更可能な引数がCMDで指定されているか

### セキュリティ

- パスワード、APIキー、トークンがハードコードされていないか
- ARGやENVで機密情報を渡していないか（ビルド履歴に残るため）
- 非rootユーザーで実行されているか（`USER` 命令が使用されているか）
- distrolessを使用している場合、`USER 65532` が指定されているか
- 不要なパッケージやツールがインストールされていないか

### 環境変数のタイミング管理

- ビルド時に必要な環境変数が`ARG`で定義されているか（`DOTENV_PRIVATE_KEY`, `SENTRY_AUTH_TOKEN`など）
- ランタイム時に必要な環境変数が`ENV`で定義されているか（`NODE_ENV=production`, `PORT=3000`など）

### パフォーマンス

- マルチステージビルドで不要なビルドツールが除外されているか
- 軽量なベースイメージ（alpine、distroless）が使用されているか
- パッケージインストール後のクリーンアップが実行されているか

### 整合性

- `docker-compose.yml` で使用されているイメージ名と一致しているか
- `.dockerignore` で除外されているファイルが適切か
- `package.json` や `go.mod` のバージョンと一致しているか

### 完全性

- WORKDIRが適切に設定されているか
- 必要な環境変数が設定されているか
- 適切なEXPOSEが指定されているか

### 悪い例と良い例

#### マルチステージビルドの未使用

**悪い例**:

```dockerfile
FROM golang:latest
WORKDIR /app
COPY . .
RUN go build -o server
CMD ["./server"]
```

**良い例**:

```dockerfile
FROM golang:1.24.5 AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o server

FROM gcr.io/distroless/base-debian12
WORKDIR /app
USER 65532
COPY --from=builder /app/server .
ENTRYPOINT ["./server"]
```

#### キャッシュを活かせない順序

**悪い例**:

```dockerfile
COPY . .
RUN go mod download
```

**良い例**:

```dockerfile
COPY go.mod go.sum ./
RUN go mod download
COPY . .
```

#### RUN命令の不適切な分割

**悪い例**:

```dockerfile
RUN apt-get update
RUN apt-get install -y git
RUN apt-get clean
```

**良い例**:

```dockerfile
RUN apt-get update && \
    apt-get install -y --no-install-recommends git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
```

### チェックリスト

- [ ] マルチステージビルドを使用している（コンパイル言語の場合）
- [ ] キャッシュを最大限活用する順序で記述している
- [ ] RUN命令を適切にまとめている
- [ ] `.dockerignore` を設定している
- [ ] ENTRYPOINTとCMDを適切に使い分けている
- [ ] distroless/alpineを使用している
- [ ] 非rootユーザーで実行している
- [ ] ベースイメージのバージョンを固定している
- [ ] セキュリティスキャンをCI/CDに組み込んでいる
- [ ] Linter（Hadolint）を導入している

---

## docker-compose.yml

<!-- markdownlint-disable MD024 -->

### 正確性

- YAML構文エラーがないか
- サービス名が重複していないか
- ネットワーク設定が正しいか

### ベストプラクティス

- 適切なバージョン指定がされているか
- 環境変数ファイルを使用しているか
- ボリュームマウントが適切か
- リソース制限が設定されているか

### セキュリティ

- 機密情報がハードコードされていないか
- ネットワーク分離が適切か
- 適切な権限で実行されているか

### 整合性

- `Dockerfile` との整合性
- 環境変数の命名規則が統一されているか

### 完全性

- 必要なサービスが定義されているか
- ネットワーク設定が適切か
- ボリューム設定が適切か

<!-- markdownlint-enable MD024 -->

---

## .dockerignore

<!-- markdownlint-disable MD024 -->

### ベストプラクティス

必須の除外パターン:

- `.git`, `node_modules`, `test`, `tests`, `*.md`, `*.log`
- `Dockerfile`, `docker-compose.yml`（再帰的コピー防止）
- `.env`, `.env.*`, `*.key`, `*.pem`（セキュリティ）
- `.vscode`, `.idea`（開発ツール）

### 整合性

- `Dockerfile` でCOPYされるファイルと矛盾していないか
- `.gitignore` との整合性

<!-- markdownlint-enable MD024 -->

推奨例:

```text
.git
.gitignore
test
tests
*.md
*.log
node_modules
dist
build
.env
.env.*
*.key
*.pem
Dockerfile
docker-compose.yml
.vscode
.idea
.github
```

---

## 公式ドキュメント

- [Dockerfile reference](https://docs.docker.com/engine/reference/builder/)
- [Dockerfile best practices](https://docs.docker.com/build/building/best-practices/)
- [Multi-stage builds](https://docs.docker.com/build/building/multi-stage/)
- [Build secrets（BuildKit）](https://docs.docker.com/build/building/secrets/)
- [Compose file reference](https://docs.docker.com/compose/compose-file/)
- [.dockerignore](https://docs.docker.com/build/building/context/#dockerignore-files)
