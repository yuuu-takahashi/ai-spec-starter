---
name: my.drawio
description: draw.io の図を XML（.drawio）形式で生成・編集するための手順を提供するスキル。mxCell / mxGraphModel の構造に従い、フロー図などをテキストベースで定義する。他コマンド・スキルから「draw.io 形式の図を出力したい」ときに参照する。
allowed-tools: Read, Write
---

# Draw.io 図生成スキル

draw.io の図を XML（.drawio）形式で生成・編集するための手順です。他コマンド・スキルから「draw.io 形式の図を出力する」ときに参照してください。

## いつ使うか

- 設計書・仕様書用のフロー図・構成図を .drawio ファイルとして出力したいとき
- GUI ではなくテキスト（XML）で図を定義し、バージョン管理や LLM 生成と組み合わせたいとき

## draw.io XML の基本構造

- ルートは `<mxfile>`（`host="app.diagrams.net"` など）。
- その下に `<diagram>` → `<mxGraphModel>` → `<root>` → 複数の `<mxCell>`。
- **ノード（図形）**: `vertex="1"`、`parent`、`value`（表示テキスト）、`style`（形状・色など）、`id`。
- **エッジ（線）**: `edge="1"`、`source`、`target`、`parent`、`style`、`id`。
- 位置・サイズは `<mxGeometry>` で指定（`x`, `y`, `width`, `height`）。

## ノード（図形）の例

```xml
<mxCell id="A1" value="開始" parent="1" vertex="1">
  <mxGeometry x="40" y="40" width="120" height="40" as="geometry"/>
</mxCell>
```

- `parent="1"`: 通常はルートのセル `1` を指定。
- `style`: 例）`rounded=1;whiteSpace=wrap;html=1;fillColor=#f5f5f5;strokeColor=#333333;`（角丸・折り返し・塗り・線色）。

## エッジ（矢印）の例

```xml
<mxCell id="e1" source="A1" target="A2" parent="1" edge="1">
  <mxGeometry relative="1" as="geometry"/>
</mxCell>
```

- `source` / `target`: 接続元・接続先の mxCell の `id`。
- 直角線にしたい場合: `style="edgeStyle=orthogonalEdgeStyle;rounded=0;orthogonalLoop=1;jettySize=auto;html=1;"`。

## サブグラフ（グループ）

- `style="group"` の mxCell でグループ化。子ノードの `parent` にその id を指定。
- グループのサイズ・位置は `<mxGeometry>` で指定。

## 作成・編集の手順

1. **骨組みを作る**: `<mxfile>` → `<diagram>` → `<mxGraphModel>` → `<root>` と、ルート用の `<mxCell id="0"/>` と `<mxCell id="1" parent="0"/>` を用意。
2. **ノードを追加**: 各ステップ・要素を `vertex="1"` の mxCell で定義。`id` は一意に（例: A1, A2, B1）。
3. **エッジを追加**: `edge="1"` の mxCell で `source` / `target` をノード id に指定。
4. **レイアウト**: ノードの `<mxGeometry>` の `x`, `y` を調整して重なりを防ぎ、流れが分かりやすい位置に配置。
5. **保存**: 拡張子 `.drawio` で保存（中身は XML）。draw.io で「開く」→「XMLをインポート」で読み込むか、XML をそのまま貼り付けて表示できる。

## スタイルの例（ノード）

- 角丸四角: `rounded=1;whiteSpace=wrap;html=1;`
- 塗り色: `fillColor=#f5f5f5;`
- 枠線: `strokeColor=#333333;strokeWidth=2;`
- 菱形（条件分岐）: `rhombus;whiteSpace=wrap;html=1;` など

## 注意事項

- **id の一意性**: ノード・エッジの `id` はファイル内で重複させない。
- **親子関係**: グループを使う場合、子の `parent` はグループの id にすること。
- **レイアウト**: XML だけではレイアウトが難しい場合は、インポート後に draw.io の「レイアウト」メニューで整列・階層型レイアウトなどを利用するとよい。

## 参考

- [draw.io XML文書作成ガイド (フロー図)](https://zenn.dev/centervil/articles/2025-03-14-drawio-xml-creation-guide)
- draw.io: <https://app.diagrams.net/>
- 既存の .drawio ファイルを開いて XML 構造を確認すると理解しやすい。
