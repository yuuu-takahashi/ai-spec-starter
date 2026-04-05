<!-- markdownlint-disable MD040 -->

# CI エラー対応ガイド

GitHub Actions や CI/CD パイプラインの失敗を診断・修正するための実践ガイド。

## CI チェックの種類

### 1. GitHub Actions ワークフロー

自動テスト、ビルド、デプロイなどを実行するプロセス。

**一般的なジョブ**:

```yaml
- Lint (コード品質チェック)
- Test (ユニットテスト)
- Build (ビルド・コンパイル)
- Deploy (本番デプロイ)
- Security Scan (セキュリティスキャン)
```

### 2. ステータスチェック

PR マージ前に必須のチェック。

**例**:

- Continuous Integration / Check
- Code Coverage
- Branch Protection Rules

### 3. 外部サービスチェック

GitHub 外部の CI サービスとの連携。

**例**:

- CircleCI
- TravisCI
- Codecov

## よくある CI 失敗パターン

### パターン1: Lint エラー

コード品質チェックが失敗（ESLint, Prettier など）

**症状**:

```text
ESLint errors found
❌ src/index.js:10:1 - error: Missing semicolon
❌ src/utils.js:5:3 - warning: Unused variable 'x'
```

**原因**:

- コードスタイルが規約に違反している
- Prettier でフォーマットされていない
- 不要なインポートが残っている

**修正方法**:

```bash
# ESLint 自動修正
npm run lint -- --fix

# Prettier でフォーマット
npm run format

# または手動修正してコミット
```

**修正例**:

```javascript
// Before
const x = 5; // セミコロンなし、未使用変数
function foo() {
  return x;
}

// After
function foo() {
  return 5;
}
```

### パターン2: テスト失敗

ユニットテストや統合テストが失敗

**症状**:

```text
Test Suites: 1 failed, 0 passed
Tests:       5 failed, 20 passed
● getUser › should return user details

Expected: { id: 1, name: 'John' }
Received: { id: 1, name: null }
```

**原因**:

- ロジックが間違っている
- テストケースが古い・不完全
- 外部 API レスポンスが変更された
- 依存パッケージがアップデートされた

**修正方法**:

```bash
# テストログを詳しく見る
npm test -- --verbose

# 特定のテストのみ実行
npm test -- --testNamePattern="getUser"

# カバレッジレポートを生成
npm test -- --coverage
```

**修正例**:

```javascript
// Before
function getUser(id) {
  return { id, name: null }; // バグ
}

// After
function getUser(id) {
  return { id, name: 'John' }; // 修正
}

// またはテストケースを修正
test('should return user details', () => {
  const user = getUser(1);
  expect(user.name).toBeDefined(); // より緩いアサーション
});
```

### パターン3: ビルドエラー

TypeScript コンパイルエラーやバンドルエラー

**症状**:

```text
error TS2307: Cannot find module 'lodash'

Module parse failed: Unexpected token }
File: src/index.js
```

**原因**:

- TypeScript 型エラー
- 依存パッケージが not installed
- インポート パスが間違っている
- 構文エラーがある

**修正方法**:

```bash
# 依存関係をインストール
npm install

# TypeScript エラーをチェック
npx tsc --noEmit

# バンドルをテスト
npm run build
```

**修正例**:

```typescript
// Before
import { map } from 'lodash';  // lodash がインストールされていない

// After
npm install lodash
import { map } from 'lodash';  // インストール後に使用
```

### パターン4: 型チェックエラー（TypeScript）

型の不一致や未定義の型エラー

**症状**:

```text
error TS2345: Argument of type 'string' is not assignable to parameter of type 'number'.

error TS2339: Property 'name' does not exist on type 'User'.
```

**原因**:

- 型定義がない
- 型が一致していない
- オブジェクト構造が異なる

**修正方法**:

```bash
# 型エラーをリスト
npx tsc --noEmit

# IDE のQuick Fix を使用（VS Code）
```

**修正例**:

```typescript
// Before
function add(a: number, b: number): number {
  return a + b;
}
const result = add('5', '10'); // 型エラー

// After
const result = add(5, 10); // 型を修正
// または
const result = add(Number('5'), Number('10')); // 型変換
```

### パターン5: カバレッジ不足

テストカバレッジが要件を満たしていない

**症状**:

```text
Coverage Summary:
  Branches: 50% ( 5 / 10 )
  Statements: 60% ( 12 / 20 )

Required coverage: Branches: 80%, Statements: 85%
```

**原因**:

- テストケースが不足している
- エッジケースをテストしていない
- 新コードがテストされていない

**修正方法**:

```bash
# カバレッジレポート詳細確認
npm test -- --coverage --verbose

# HTML レポートで視覚確認
open coverage/index.html
```

**修正例**: 新しいコードに対するテストを追加

```javascript
// src/utils.js に追加した関数
export function isValidEmail(email) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

// test/utils.test.js に追加
describe('isValidEmail', () => {
  test('valid email', () => {
    expect(isValidEmail('user@example.com')).toBe(true);
  });
  test('invalid email', () => {
    expect(isValidEmail('invalid')).toBe(false);
  });
});
```

### パターン6: セキュリティスキャンエラー

脆弱性が検出された

**症状**:

```text
⚠️ Vulnerability found in lodash@4.17.20
  Known to be vulnerable to: Prototype Pollution

npm install lodash@latest
```

**原因**:

- 依存パッケージに脆弱性がある
- セキュリティアップデートが利用可能
- 推奨されないメソッドを使用している

**修正方法**:

```bash
# 脆弱性レポート確認
npm audit

# 自動修正を試みる
npm audit fix

# 手動で特定パッケージをアップグレード
npm install lodash@latest
```

### パターン7: デプロイエラー

本番環境へのデプロイ失敗

**症状**:

```text
Deploy to Heroku failed
Error: Procfile not found
```

**原因**:

- 必須ファイルがない（Procfile, package-lock.json など）
- 環境変数が設定されていない
- リソース不足（メモリ、ディスク）
- デプロイスクリプトが失敗している

**修正方法**:

1. Procfile がある確認
2. 環境変数を設定
3. ログを確認

```bash
# ローカルでビルド・デプロイプロセスをテスト
npm run build
npm start
```

## GitHub Actions のデバッグ方法

### ステップ1: ワークフローファイルを確認

`.github/workflows/` ディレクトリ内のファイルを確認。

```yaml
# .github/workflows/ci.yml
name: CI
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Install
        run: npm install
      - name: Lint
        run: npm run lint
      - name: Test
        run: npm test
```

### ステップ2: ワークフロー実行ログを確認

GitHub の PR ページで「Checks」タブを開いて詳細ログを確認。

**確認項目**:

1. どのステップで失敗したか
2. エラーメッセージ
3. 実行時刻と所要時間

### ステップ3: ローカル環境で再現

失敗を再現してデバッグ。

```bash
# CI で使用される環境をシミュレート
docker run -it ubuntu:latest bash
# または
node:16-alpine  # Node.js の場合

# ワークフロー内と同じコマンドを実行
npm install
npm run lint
npm test
```

### ステップ4: デバッグ出力を追加

```yaml
- name: Print debug info
  run: |
    node --version
    npm --version
    echo $PATH
    pwd
    ls -la
```

### ステップ5: 環境変数を確認

```yaml
- name: Check environment
  env:
    DEBUG: true # デバッグフラグ追加
  run: |
    echo "Node version: $(node --version)"
    echo "npm version: $(npm --version)"
    npm test
```

## 修正プロセス

### フェーズ1: エラー分析

```bash
# 1. CI ログを読む
# GitHub Actions の "Checks" タブでエラーメッセージを確認

# 2. エラーの種類を特定
# Lint? Test? Build? Deploy?

# 3. ローカルで再現
npm run lint
npm test
npm run build
```

### フェーズ2: 修正

```bash
# 1. 修正を実行
npm run lint -- --fix
npm test -- --updateSnapshot

# 2. ローカルでテスト
npm run ci  # CI と同じコマンドを実行

# 3. 変更をステージ・コミット
git add .
git commit -m "fix: CI エラーを修正"
```

### フェーズ3: 再実行

```bash
# 1. 修正をプッシュ
git push origin feature/branch-name

# 2. GitHub Actions を待機
# PR ページで "Checks" を確認

# 3. すべてのチェックが成功したら PR マージ
```

## GitHub CLI を使用した確認

### PR 情報を取得

```bash
# 現在のブランチの PR を確認
gh pr checks

# 特定の PR を指定
gh pr checks <PR_NUMBER>

# 詳細情報
gh pr view --json checks
```

### ワークフロー実行を確認

```bash
# 最新のワークフロー実行
gh run list --limit 5

# 特定の実行詳細
gh run view <RUN_ID>

# ログを取得
gh run view <RUN_ID> --log
```

### PR をローカルでテスト

```bash
# PR をローカルにチェックアウト
gh pr checkout <PR_NUMBER>

# ローカルで CI コマンドを実行
npm install
npm run lint
npm test
npm run build

# もと のブランチに戻る
git checkout -
```

## トラブルシューティング

### 問題: ローカルでは成功するが CI で失敗

**原因**: 環境差異

```text
対策:
1. Node.js バージョン確認
   npm run which node

2. OS の差異確認（Ubuntu vs Mac vs Windows）
   uname -a

3. 環境変数確認
   echo $PATH
   env | grep NODE
```

### 問題: CI が遅い

**原因**: 依存関係の解決、テスト実行が遅い

```text
対策:
1. キャッシュを使用
   - npm ci (npm install の高速版)
   - GitHub Actions キャッシュ

2. テストを分割実行
   npm test -- --maxWorkers=2

3. 不要なステップを削除
```

### 問題: タイムアウト

**原因**: テストやビルドに時間がかかりすぎている

```text
対策:
1. タイムアウト設定を延長
   timeout-minutes: 15

2. テストを並列実行
   npm test -- --parallel

3. 遅いテストを特定
   npm test -- --verbose --detectOpenHandles
```

## ベストプラクティス

1. **ローカルで常に成功させる**: CI 実行前にローカルで確認
2. **キャッシュを活用**: npm キャッシュ、ビルドキャッシュを使用
3. **タイムアウトを適切に設定**: 通常 10-15 分
4. **ログを残す**: デバッグ情報を出力して後から確認可能に
5. **定期的にアップデート**: Node.js、パッケージの最新版を使用
6. **セキュリティスキャンを実行**: npm audit で脆弱性を定期確認
7. **テストカバレッジを監視**: カバレッジレポートを毎回確認
