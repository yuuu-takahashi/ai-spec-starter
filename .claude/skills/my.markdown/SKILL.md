---
name: my.markdown
description: |
  Markdown ドキュメントの構造化・本文・図を一貫して作る。Mermaid MCP を使ってフロー図・アーキテクチャ図・タイムラインを埋め込み、どんなときにどの図を選ぶべきかのガイド（references/diagram-guide.md）も手元で確認しながら Markdown を仕上げる。`skill-creator` で整理した意図に基づいてアウトラインを固め、Mermaid MCP で生成した図を `assets/` に保存して相対リンクを差し込む。
compatibility: |
  - Markdown ファイルの作成・更新（段落・見出し・リスト・コードブロックなど）
  - Mermaid MCP / Claude `mcp mermaid` で図を生成（SVG/PNG/base64）
  - `.claude/skills/` 内の参考資料 `references/diagram-guide.md` を読んで適切な図の型を選ぶ
---

# Overview

`my.markdown` は新しい Markdown 資料をゼロから綺麗に構成するスキルです。`skill-creator` で明らかになった intent（何を伝えたいか、誰に向けた内容か、どんな図が必要か）をベースに、図やテーブルの配置をアウトライン化し、Mermaid MCP で図を生成します。各図がどのような用途に向くかは `references/diagram-guide.md` を参照してください。

## When to use

- How-to、README、ガイド、報告書など Markdown 出力が必要なとき
- Mermaid 図（フロー、シーケンス、アーキテクチャ、タイムライン、ER）を本文に埋め込みたいとき
- どの図をどんなシナリオで選ぶべきかをすぐ確認したいとき（例: 落とし穴を説明するときに flowchart, 状態遷移なら state diagram）

## References

- Mermaid 図の型と適用例: `references/diagram-guide.md`
- Markdown 記法ガイド: `code.claude.com/docs/ja/skills`
