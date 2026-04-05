# Git（.gitignore / .gitattributes）

## .gitignore

- OS 固有（`.DS_Store` 等）、エディタ、依存キャッシュ、ビルド成果物、ログの除外
- 機密・ローカル上書き（例: `.env.local`, `.env.*.local`, 鍵・証明書、`.kamal/*.key` など）の除外
- プロジェクト方針に応じた `.env` の扱い（**平文コミットは避け**、可能なら**暗号化して追跡**する。平文のみの場合は `.gitignore` と取得元ドキュメントのセット）
- 既に追跡されているファイルは `.gitignore` 追加だけでは除外されない点の確認
- [ignore-files.md](ignore-files.md) と `.dockerignore` / 各種ツール ignore の**役割の差**を突き合わせる

---

## 公式ドキュメント

- [gitignore](https://git-scm.com/docs/gitignore)
- [gitattributes](https://git-scm.com/docs/gitattributes)
