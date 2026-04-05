<!-- markdownlint-disable MD040 -->

# Husky フック完全ガイド

Git フック自動化ツール Husky の設定・運用・トラブルシューティング。

## Husky とは

Git コミット・プッシュなどのライフサイクルイベント時に自動でスクリプトを実行するツール。

**利点**:

- コミット前にコード品質をチェック（lint・format）
- テスト失敗時のコミット・プッシュを防止
- 統一されたコミットメッセージ形式を強制
- チーム全体で同じ品質基準を保証

**デメリット**:

- セットアップに手間がかかる
- 開発速度が落ちる場合がある（遅いチェックは改善が必要）
- ホストマシンの環境依存

## Husky のセットアップ

### インストール

```bash
# npm の場合
npm install husky --save-dev
npx husky install

# yarn の場合
yarn add husky --dev
yarn husky install

# pnpm の場合
pnpm add -D husky
pnpm husky install
```

### package.json への設定

```json
{
  "scripts": {
    "prepare": "husky install"
  }
}
```

## Git フックの種類

### pre-commit フック

**トリガー**: `git commit` 実行時

**目的**: コミット前にコード品質をチェック

**一般的な処理**:

```bash
1. Lint チェック (ESLint, Pylint など)
2. フォーマット確認 (Prettier など)
3. 型チェック (TypeScript など)
4. 簡易テスト
```

**実装例**:

```bash
#!/bin/bash

# ESLint でチェック
npm run lint || exit 1

# Prettier でチェック
npm run format:check || exit 1

# TypeScript 型チェック
npm run type-check || exit 1

echo "✓ Pre-commit checks passed"
```

**実行結果**:

```text
✓ Lint チェック成功
✓ フォーマット確認成功
✓ 型チェック成功
✓ コミット実行
```

### pre-push フック

**トリガー**: `git push` 実行時

**目的**: プッシュ前にテストをすべて実行

**一般的な処理**:

```bash
1. 全テスト実行
2. ビルド成功確認
3. セキュリティスキャン
4. 本番環境への影響確認
```

**実装例**:

```bash
#!/bin/bash

# テスト実行
npm test -- --passWithNoTests || exit 1

# ビルド確認
npm run build || exit 1

# セキュリティスキャン
npm audit --production || exit 1

echo "✓ Pre-push checks passed"
```

### commit-msg フック

**トリガー**: コミットメッセージ入力時

**目的**: コミットメッセージ形式を検証

**一般的な処理**:

```bash
1. Conventional Commits 形式の確認
2. コミットメッセージの長さチェック
3. 禁止ワードの確認
```

**実装例**:

```bash
#!/bin/bash

msg=$(cat "$1")

# Conventional Commits 形式をチェック
if ! echo "$msg" | grep -E "^(feat|fix|docs|style|refactor|perf|test|chore):" ; then
  echo "❌ Conventional Commits 形式に従ってください"
  echo "   例: feat: 新機能を追加"
  exit 1
fi

# 最初の行が50字以内
first_line=$(echo "$msg" | head -n1)
if [ ${#first_line} -gt 50 ]; then
  echo "❌ コミットメッセージの最初の行は50字以内にしてください"
  exit 1
fi

echo "✓ Commit message format is valid"
```

### post-commit フック

**トリガー**: コミット実行後

**目的**: コミット後の処理（ログ記録など）

**例**:

```bash
#!/bin/bash
echo "Commit successful: $(git log -1 --oneline)"
```

### post-merge フック

**トリガー**: マージ後

**目的**: 依存関係の再インストール（package.json が変更された場合）

**例**:

```bash
#!/bin/bash

if git diff --name-only HEAD@{1} HEAD | grep -q "package.json" ; then
  echo "package.json has changed, running npm install..."
  npm install
fi
```

## Husky フック作成

### フックファイルを作成

```bash
# pre-commit フック作成
npx husky add .husky/pre-commit "npm run lint"

# pre-push フック作成
npx husky add .husky/pre-push "npm test"

# commit-msg フック作成
npx husky add .husky/commit-msg 'npx commitlint --edit "$1"'
```

### 複数のコマンドを実行

```bash
# ファイル内を直接編集
cat > .husky/pre-commit << 'EOF'
#!/bin/bash
set -e  # 失敗時は終了

echo "Running lint..."
npm run lint

echo "Running format check..."
npm run format:check

echo "Running type check..."
npm run type-check

echo "✓ All checks passed"
EOF

chmod +x .husky/pre-commit
```

## よくある設定パターン

### パターン1: Lint + Format チェック（軽量）

```bash
# .husky/pre-commit

#!/bin/bash
set -e

npx lint-staged
npm run type-check
```

**lint-staged** の設定（package.json):

```json
{
  "lint-staged": {
    "*.js": "eslint --fix",
    "*.jsx": "eslint --fix",
    "*.ts": "eslint --fix",
    "*.tsx": "eslint --fix",
    "*": "prettier --write"
  }
}
```

### パターン2: テスト + ビルド（重量）

```bash
# .husky/pre-push

#!/bin/bash
set -e

echo "Running tests..."
npm test

echo "Running build..."
npm run build

echo "Checking for vulnerabilities..."
npm audit --production
```

### パターン3: Conventional Commits フォーマット検証

```bash
# .husky/commit-msg

#!/bin/bash
npx commitlint --edit "$1"
```

**commitlint** 設定（commitlint.config.js）:

```javascript
module.exports = {
  extends: ['@commitlint/config-conventional'],
  rules: {
    'type-enum': [
      2,
      'always',
      ['feat', 'fix', 'docs', 'style', 'refactor', 'perf', 'test', 'chore'],
    ],
  },
};
```

## パフォーマンス最適化

### 遅いフック: 原因と対策

**問題**: pre-commit フックが実行されるたびに 30 秒以上かかる

```bash
# 原因を特定
time npm run lint
time npm test
time npm run build
```

### 最適化テクニック

#### 1. lint-staged を使用（変更ファイルのみチェック）

```json
{
  "lint-staged": {
    "*.js": ["eslint --fix", "prettier --write"],
    "*.md": "prettier --write"
  }
}
```

**効果**: 全ファイルチェック（5秒）→ 変更ファイルのみ（1秒）

#### 2. フック内での処理を分散

```bash
# Before: pre-commit で全処理
npm run lint
npm run format:check
npm run type-check

# After: pre-commit と pre-push に分散
# .husky/pre-commit (軽い)
npm run lint
npm run format:check

# .husky/pre-push (重い)
npm run type-check
npm test
```

#### 3. キャッシュを活用

```bash
# ESLint cache を使用
npx eslint . --cache

# Prettier cache を使用
npx prettier . --cache --write
```

#### 4. 並列実行

```bash
#!/bin/bash

# npm-run-all で並列実行
npm-run-all --parallel lint format:check type-check
```

## フックの一時的なスキップ

### コミット時にフックをスキップ

```bash
# --no-verify フラグ
git commit --no-verify -m "WIP: まだテスト中"

# または
git commit -m "WIP" --no-verify
```

**注意**: 緊急時のみ使用（通常は使わない）

### フックを一時的に無効化

```bash
# フックを無効化
npx husky uninstall

# フックを再度有効化
npx husky install
```

## トラブルシューティング

### 問題1: フックが実行されない

**確認**:

```bash
# .husky ディレクトリが存在するか
ls -la .husky/

# pre-commit ファイルが実行可能か
ls -la .husky/pre-commit

# package.json に prepare スクリプトがあるか
cat package.json | grep prepare
```

**解決**:

```bash
# 権限を付与
chmod +x .husky/pre-commit
chmod +x .husky/pre-push

# husky を再インストール
npx husky install
```

### 問題2: フック内のコマンドが見つからない

**原因**: npm スクリプトが PATH に含まれていない

```bash
# Before（失敗）
#!/bin/bash
eslint .

# After（成功）
#!/bin/bash
npx eslint .
# または
npm run lint
```

### 問題3: フックで環境変数が undefined

```bash
# Before（失敗）
#!/bin/bash
echo $MY_VAR  # undefined

# After（成功）
#!/bin/bash
source ~/.bashrc  # 環境変数をロード
echo $MY_VAR
```

### 問題4: Windows で実行権限エラー

**エラー**:

```text
cannot execute binary file: Exec format error
```

**原因**: Windows では実行権限の概念が異なる

**解決**:

```bash
# git-bash でのみ実行
bash .husky/pre-commit

# または .husky/pre-commit.js 形式を使用
```

### 問題5: CI で Husky フックがスキップされる

**原因**: CI 環境では husky install が実行されていない

**解決**: CI ファイルに追加

```yaml
# .github/workflows/ci.yml
- name: Install Husky
  run: npx husky install

- name: Run pre-commit hook
  run: npx husky run pre-commit
```

## ベストプラクティス

### 1. フックは軽く、高速に

- pre-commit: 1-2秒以内
- pre-push: 5-10秒以内

### 2. lint-staged で変更ファイルのみチェック

```json
{
  "lint-staged": {
    "*.js": "eslint --fix"
  }
}
```

### 3. フックの出力を明確に

```bash
#!/bin/bash
set -e

echo "🔍 Running lint..."
npm run lint && echo "✓ Lint passed"

echo "🎨 Running format check..."
npm run format:check && echo "✓ Format check passed"

echo "✨ All checks passed!"
```

### 4. フックファイルは Git に含める

```bash
# .gitignore に追加しない
# .husky/ をコミット
git add .husky/
git commit -m "chore: Add husky hooks"
```

### 5. CI との連携

- ローカル: Husky フック（軽量）
- CI: 本番品質チェック（重量）

### 6. チーム全体で同じ設定を共有

```bash
# prepare スクリプト自動実行
npm install  # husky install も自動実行
```

## デバッグモード

### フックの詳細ログ出力

```bash
#!/bin/bash
set -x  # トレースモード（コマンド実行前に表示）

npm run lint
npm run test
```

### フック実行を手動テスト

```bash
# pre-commit フックを手動実行
bash .husky/pre-commit

# pre-push フックを手動実行
bash .husky/pre-push

# 特定の時点での動作確認
npm run lint -- src/specific-file.js
```

## 参考設定ファイル

### 推奨設定セット

**.husky/pre-commit**:

```bash
#!/bin/bash
npx lint-staged
npx tsc --noEmit
```

**.husky/pre-push**:

```bash
#!/bin/bash
npm test -- --bail
npm run build
```

**.husky/commit-msg**:

```bash
#!/bin/bash
npx commitlint --edit "$1"
```

**package.json**:

```json
{
  "husky": {
    "hooks": {
      "pre-commit": "lint-staged",
      "pre-push": "npm test"
    }
  },
  "lint-staged": {
    "*.js": "eslint --fix",
    "*.ts": ["eslint --fix", "tsc --noEmit"]
  }
}
```
