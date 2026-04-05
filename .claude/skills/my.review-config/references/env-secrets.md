# 環境変数管理（ベストプラクティス）

## 原則（12-factor 等）

- **設定をコードから分離**する。環境ごとに変える値はビルド成果物に平文で焼かず、**デプロイ環境や暗号化された設定で注入**する
- **同一のコード**が複数環境で動くとき、差分は環境変数（と接続先 URL）に集約されているか

## リポジトリ内：暗号化して持つことを優先

- **平文の秘密をコミットしない**。チームで同じ値を再現したい場合は、**可能なら暗号化したままリポジトリに含める**（例: dotenvx の暗号化 `.env`、SOPS、リポジトリ用の暗号化仕組み）。復号に必要な鍵・トークンはリポジトリに含めず、各人・CI・インフラのシークレット領域にだけ置く
- 暗号化しない運用の場合は、`.env` を `.gitignore` し、**テンプレート＋取得元ドキュメント**で欠落と手順が分かるようにする

## 取得元の文書化（必須に近い推奨）

- **どの変数がどこから入るか**を、README、`docs/env.md`、`config/deploy.yml` のコメント、または `src/config/env.ts` 等の先頭コメントに**一覧または表**で残す（例: 「`DATABASE_URL` → 本番は Kamal `env.secret`、ローカルは `.env`（暗号化ファイルを復号後）」）
- CI（GitHub Actions の `secrets` / `vars`）、コンテナ実行時の `-e`、ホストの systemd / shell、クラウドのパラメータストアなど、**複数経路があるときは優先順位**も書く
- 口伝・過去の Slack のみに依存していると、オンボーディングと障害時に抜け漏れが出るためレビューで指摘する

## リポジトリ内のファイル

- **`.env.example`（または `.env.sample`）**: 必須キーを**名前・短い説明・取得元のヒント**で列挙。実値・本番固有の秘密は書かない（暗号化ファイルのファイル名やドキュメントへのリンクは可）
- **`.env` / `.env.local`**: 個人・環境固有。平文なら `.gitignore` で除外。暗号化して追跡する場合は、復号手順と鍵の置き場所をドキュメントに書く
- **複数ファイルの優先順位**: フレームワークごとの読み込み順（例: `.env` → `.env.local`）を把握し、**どれが本番で使われないか**を上記の取得元ドキュメントに明示

## アプリケーション側

- **必須変数の起動時検証**: 欠落・空文字を**すぐ検知して失敗**する（Zod / envalid / 自前スキーマ等）。`undefined` のまま処理が進み、後段で初めてエラーになるパターンを避ける
- **アクセスの集約**: `process.env.FOO` の直参照が各所に散らばっていないか。1 か所のモジュール（例: `src/config/env.ts`）経由なら検証・型・取得元コメントをまとめやすい
- **曖昧なデフォルト値を置かない**: `process.env.FOO || 'http://localhost'` や `?? 3000` のように、**未設定を隠すフォールバック**を安易に広げない。未設定であることが検証段階で分からなくなるため、レビューでは原則として避け、どうしても必要なら「環境変数ではなくコード内の名前付き定数」とコメント付きで意図を明示する
- **クライアントに露出する変数**: `NEXT_PUBLIC_*`, `VITE_*` 等は**ブラウザに送られる**前提。秘密を載せない

## Docker・コンテナ

- **ビルド時**: `ARG` はレイヤー・履歴に残りうる。**機密を平文 `ARG` で渡さない**か、マルチステージで最終イメージに入れない
- **実行時**: 本番の秘密はランタイム注入（オーケストレーション、シークレットマウント、Kamal の `env.secret` 等）。`ENV` でデフォルトを置く場合も、**未設定のまま起動してほしくない値はアプリ側の必須検証に任せ**、Docker 側のダミーデフォルトで誤魔化さない

## CI/CD

- シークレットは**プラットフォームのシークレット機能**に保存し、ログに出さない（echo 禁止、マスキング確認）
- 長期トークンより **OIDC・短期クレデンシャル**が使えるか検討する
- ワークフロー内で参照する環境変数・シークレットも、リポジトリ内の「取得元」ドキュメントに**CI 由来であること**を追記し、ローカルとの差を明文化する

## Kamal・インフラ連携

- `config/deploy.yml` の `env`、`env.secret`、`builder.args` とアプリが期待する変数名が一致しているか
- 「環境変数管理」と [Kamal](kamal.md) の両方を読み、**供給元（ホスト・コンテナ・ビルド）**が重複・欠落なくカバーされ、取得元ドキュメントと矛盾していないか

---

## 公式ドキュメント

- [The Twelve-Factor App: Config](https://12factor.net/config)
- Docker: [ARG / ENV](https://docs.docker.com/engine/reference/builder/#arg), [Build secrets](https://docs.docker.com/build/building/secrets/)
- GitHub Actions: [Using secrets](https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions)
- Kamal: [Environment variables](https://kamal-deploy.org/docs/configuration/environment-variables)
- Rails（該当スタック時）: [Securing Rails Applications / Custom credentials](https://guides.rubyonrails.org/security.html#custom-credentials)
