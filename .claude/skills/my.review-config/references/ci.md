<!-- markdownlint-disable MD036 -->

# CI/CD ワークフロー（GitHub Actions 等）

`.github/workflows/*.yml` を主とする。GitLab CI（`.gitlab-ci.yml`）や CircleCI（`.circleci/config.yml`）でも、**権限の最小化・シークレット・タイムアウト・キャッシュ・本番デプロイの保護**という観点は同様に適用する。

## GitHub Actions ワークフロー

### ベストプラクティス

#### Concurrency

- PRワークフローで `concurrency` が設定されているか
- `cancel-in-progress: true`（テスト）、`false`（デプロイ）

#### Timeout

- 各ジョブに `timeout-minutes` が設定されているか
  - テスト: 10-15分、ビルド: 15-20分、デプロイ: 30-60分

#### Permissions

- 最小権限の原則が適用されているか
- `permissions` が明示的に設定されているか

#### Environment

- 本番デプロイに `environment: production` が設定されているか
- 環境保護ルールが設定されているか

#### Strategy

- `fail-fast: false` が設定されているか
- `max-parallel` が設定されているか

#### キャッシュ

- `actions/setup-node` で `cache` が設定されているか
- キャッシュキーが適切か

#### アーティファクト

- `retention-days` が設定されているか

### セキュリティ

- シークレットの適切な使用（`${{ secrets.XXX }}`）
- シークレットがログに出力されない設定
- コードにハードコードされていないか

### 完全性

- PRワークフロー、デプロイワークフローが存在するか
- ESLint/Prettier/TypeScript/テストジョブが含まれているか
- 通知設定があるか

---

## 公式ドキュメント

### GitHub Actions

- [Workflow syntax](https://docs.github.com/en/actions/writing-workflows/workflow-syntax-for-github-actions)
- [Security hardening](https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions)
- [Using secrets](https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions)
- [OpenID Connect](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect)

### その他の CI（リポジトリに応じて）

- [GitLab CI/CD YAML](https://docs.gitlab.com/ee/ci/yaml/)
- [CircleCI configuration](https://circleci.com/docs/configuration-reference/)
