---
name: my.devcontainer
description: |
  Dev Container まわりを**一本化**して扱う。フェーズAで build / up / exec を同一手順で確認し失敗段階を切り分け、必要ならフェーズBで `devcontainer.json`・Dockerfile・compose・`postCreateCommand`・mounts・features・**シンボリックリンク / 別 repo mount** を読み、修正案（差分案）を出す。`.devcontainer`、VS Code devcontainer、Codespaces、ローカル検証、CI 前確認、「devcontainer 直して」「postCreate が落ちる」「マウントがおかしい」など**すべてこのスキル**。`/my.devcontainer` で明示実行してよい。原則 **いきなり設定を書き換えず**、まずフェーズAで再現とログを取り、フェーズBでは**差分案を先に示す**（ユーザーがパッチ適用を明示したときだけ編集）。
compatibility: |
  - Docker（または devcontainer が要求するコンテナランタイム）
  - `@devcontainers/cli`（`devcontainer` コマンド）。未導入時はチェックスクリプトが **npm がある場合** `npm install -g @devcontainers/cli` を試す（副作用を避けたいときは `DC_SKIP_CLI_INSTALL=1`）
  - フェーズB: 対象リポジトリの `.devcontainer/` および関連 Docker 定義を Read できること
---

# Devcontainer（健全性確認 + 診断・修正）

**確認（再現・ログ）と設定変更は役割を分ける**が、スキルは 1 つにまとめている。流れは次のとおり。

1. **フェーズA（Check）**: スクリプトまたは同等手順で build → up → exec を実行し、どこで落ちたかを確定する。
2. **フェーズB（Fix）**: 失敗内容と設定ファイルを突き合わせ、原因仮説と**最小の修正案**を出す。編集はユーザーが明示した場合に限り、最小差分で行う。

## 重要なルール（両フェーズ共通）

- **いきなり `devcontainer.json` や Dockerfile を書き換えない**
- まず **build → up → exec** のどこで失敗したかを確定する（フェーズA）
- ログを読み、原因候補を **3 個以内** に絞る
- 疑う順序の目安: **bind mount・シンボリックリンク** → `postCreateCommand` → **Dockerfile / image** → **features**
- フェーズBでは **差分案を提示してから** ファイルを変更する

---

## フェーズA: 健全性確認（Check）

対象リポジトリの Dev Container がローカルで成立するかを、**毎回同じ順序**で確認する。実処理は同梱スクリプトに寄せ、再現性を優先する。

### 目的

- `devcontainer build` が通るか
- `devcontainer up` が通るか
- コンテナ内で最低限のコマンドが実行できるか
- **`gh` CLI が使え、認証情報にアクセスできるか**（`gh auth status` が通るか）
- **`claude` CLI が使えるか**
- **ライフサイクルコマンド（`postCreateCommand` / `postStartCommand`）がエラーなく完走するか**
- 失敗時に **どの段階で壊れているか** を特定する

### 前提

- Docker（等）が使えること
- **`devcontainer` CLI** が PATH にあること。同梱スクリプトは未検出かつ **`npm` が使える場合**、自動で `npm install -g @devcontainers/cli` を実行する。**グローバル導入をしたくない環境**（CI など）は `DC_SKIP_CLI_INSTALL=1` を付けて実行し、事前に CLI を用意するか手動で案内する
- `npm install -g` 後も PATH に乗らない場合は、npm のグローバル bin を PATH に追加するか、シェルを開き直す
- ワークスペースに `.devcontainer/devcontainer.json`、または公式が認める devcontainer 構成があること

### 実行手順（エージェント向け）

1. ユーザーが求めているリポジトリルート（`workspace-folder`）を特定する。
2. 次を実行する（`ai-spec-starter` 内のパス固定）。

   ```bash
   bash .claude/skills/my.devcontainer/scripts/check-devcontainer.sh /path/to/target/repo
   ```

   `devcontainer` が無く **`npm` がある場合**は、このスクリプトが `@devcontainers/cli` をグローバル導入する。CI などでグローバル `npm install -g` を避けるときは  
   `DC_SKIP_CLI_INSTALL=1 bash .claude/skills/my.devcontainer/scripts/check-devcontainer.sh …` とする。

   引数を省略した場合は **カレントディレクトリ** がワークスペース。原則 **対象リポジトリのルート** で実行する。

3. スクリプトが途中で失敗したら、そのステップ名（Build / Up / Exec）を記録し、直近のエラーログを要約する。
4. 成功時も、標準出力の最後まで確認し、Node / Ruby の有無は参考情報として報告する。

### 手動で同じこと（スクリプト非使用）

1. `.devcontainer` の存在確認
2. `devcontainer build --workspace-folder <root>`
3. `devcontainer up --workspace-folder <root>`
4. `devcontainer exec --workspace-folder <root> bash -lc "pwd && whoami && ls"`（bash が無ければ `sh -lc`）
5. 任意: Node 系 `node -v`, `npm -v`, `yarn -v` / `pnpm -v` — Ruby 系 `ruby -v`, `bundle -v`
6. **`gh` CLI**: `gh --version` → `gh auth status`（認証情報にアクセスできるか。credential mount や `GH_TOKEN` の確認）
7. **`claude` CLI**: `claude --version`（パスが通っているか。`CLAUDE_CONFIG_DIR` の設定確認）
8. **ライフサイクルコマンド再実行**: `devcontainer.json` の `postCreateCommand` / `postStartCommand` を手動で exec し、終了コード 0 を確認

### フェーズAの報告フォーマット

- **結果**: success / failed
- **失敗ステップ**: build / up / exec / gh-auth / claude-cli / lifecycle-command（該当なら）
- **gh CLI**: found / not found — **認証**: OK / failed / N/A
- **claude CLI**: found / not found
- **ライフサイクルコマンド**: postCreateCommand OK/failed — postStartCommand OK/failed
- **原因候補**（最大 3 件）
- **次に確認すべき点**（ファイル・コマンド・ログ）

フェーズBへ進む場合は、上記に加え **失敗ステップ・ログ抜粋** をフェーズBの入力として渡す。

---

## フェーズB: 診断と修正案（Fix）

設定を読み、「なぜ壊れているか」の仮説と **最小の修正** を整理する。ユーザーが「この方針で直して」「パッチ当てて」と明示するまでは、**差分案・チェックリスト**を主とする。

### いつフェーズBに入るか

- フェーズA（または同等）で **build / up / exec のどこで落ちたか** わかっている
- `devcontainer.json` / Dockerfile / compose の見直し、postCreate・マウント・シンボリックリンクの相談

フェーズAが未実施なら、**先にフェーズAを実行**する。

### 診断の順序（毎回この順で見る）

1. **失敗ステップ**で切り分けが済んでいるか。未済ならフェーズAへ戻る
2. **bind mount** と **ホスト側パス**（別 repo、相対パス、存在しないディレクトリ）
3. **シンボリックリンク**（コンテナ内・ホスト双方）
4. **`postCreateCommand` / `postStartCommand` / `initializeCommand`**（再実行して exit code 確認）
5. **`gh` CLI / 認証**（credential mount、`GH_TOKEN` env、`gh auth login` のどれで通すか）
6. **`claude` CLI**（`CLAUDE_CONFIG_DIR` の設定、PATH、credential の有無）
7. **`Dockerfile` / `image` / build の context**
8. **`features`**（競合、ネットワーク必須など）

### 読むファイル（典型的）

- `.devcontainer/devcontainer.json`（および参照パス）
- `.devcontainer/Dockerfile` または参照されている `Dockerfile`
- `docker-compose.yml` / `.devcontainer/docker-compose*.yml`
- `.dockerignore`

### フェーズBの出力フォーマット

1. **前提**: 失敗ステップとエラー要約
2. **原因仮説**（重要度順、最大 3 件）
3. **根拠**（どの設定のどこか）
4. **修正案**（優先順位・触るファイル・メリット / リスク）
5. **次の一手**（フェーズAの再実行、ログ取得、`postCreate` の分割切り分けなど）

### ファイルを自動編集してよい条件

次を**すべて**満たすときだけ。

- ユーザーが「この方針で直して」「パッチ当てて」と明示している
- 変更後に **フェーズA（スクリプトまたは同等）で再検証**する旨を伝えられる

それ以外は **差分案のみ**。
