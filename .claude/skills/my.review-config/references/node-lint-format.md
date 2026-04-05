<!-- markdownlint-disable MD036 -->

# Node.js: ESLint / Prettier / package.json

## ESLint設定

**優先順位**: `.ts` → `.js` → `.json`

- 推奨ルール、セキュリティルール（`no-eval`, `no-implied-eval`）が有効か
- `package.json`、Prettier、TypeScript設定との整合性
- 重複設定ファイルの検出
- **導入パッケージ**: [recommended-tools.md](../recommended-tools.md) の JavaScript / TypeScript（ESLint 関連）の表と照らし、`typescript-eslint`・`eslint-config-prettier`・フレームワーク用プラグインなど**スタックに必要な欠品**がないか

---

## Prettier設定

**優先順位**: `.ts` → `.js` → `.json`

- ESLint設定との整合性
- 重複設定ファイルの検出

---

## package.json

- セマンティックバージョニング、`engines`、`repository` フィールド
- 脆弱性チェック（`npm audit`）
- 不要な依存関係がないか

---

## 公式ドキュメント

<!-- markdownlint-disable MD024 -->

### ESLint

- [Configuration](https://eslint.org/docs/latest/use/configure/)
- [Ignore files](https://eslint.org/docs/latest/use/configure/ignore)
- [TypeScript ESLint](https://typescript-eslint.io/)

### Prettier

- [Configuration](https://prettier.io/docs/en/configuration.html)
- [Options](https://prettier.io/docs/en/options.html)
- [Ignore code](https://prettier.io/docs/en/ignore.html)

### package.json

- [package.json](https://docs.npmjs.com/cli/v11/configuring-npm/package-json)（`engines` / `scripts` 等。プロジェクトの npm バージョンに合わせて該当版のドキュメントを参照する）
