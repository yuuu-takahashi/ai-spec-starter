# .devcontainer / devcontainer.json

## チェック手順

1. **ファイル存在確認**
   - `.devcontainer/` ディレクトリが存在するか
   - `devcontainer.json` が存在するか
   - `image` と `build` の両方が指定されていないか（排他）

2. **設定の検証**
   - ベースイメージ: `latest` を避けバージョン固定（例: `mcr.microsoft.com/devcontainers/typescript-node:20`）
   - features: 必要な開発ツール（gh-cli, docker-in-docker, git など）が明示されているか
   - customizations.vscode.extensions: 必須拡張機能が含まれているか
   - postCreateCommand / postStartCommand: 依存インストール（`npm install`など）が設定されているか
   - forwardPorts: アプリの起動ポートがフォワードされているか

3. **整合性チェック**
   - `.nvmrc` / `.node-version` と Node バージョンの一致
   - `package.json` の `engines.node` との一致
   - devcontainer 用 Dockerfile とメイン Dockerfile の矛盾チェック

4. **セキュリティ**
   - 機密情報がハードコードされていないか
   - `mounts` でホストの機密ファイルを不必要にマウントしていないか

---

## 公式ドキュメント

- [Development Containers specification](https://containers.dev/)
- [devcontainer.json reference](https://containers.dev/implementors/json_reference/)
- [VS Code Dev Containers](https://code.visualstudio.com/docs/devcontainers/containers)
- [GitHub Codespaces devcontainer.json](https://docs.github.com/en/codespaces/setting-up-your-project-for-codespaces/adding-a-dev-container-configuration/introduction-to-dev-containers)
