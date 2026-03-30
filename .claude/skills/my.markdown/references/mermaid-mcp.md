# Mermaid MCPについて

Mermaid MCP（Model Context Protocol server for Mermaid diagrams）は、Mermaid.js の完全な構文をサポートし、背景・テーマ・出力形式（base64, svg, mermaid, file/PNG）をカスタマイズできるMCPサーバです。Claude Code や VSCode などのデスクトップアプリから `mcp mermaid` を呼び出し、AI による図の構造生成・検証・レンダリングを後押しします。Mermaid MCP は SSE/Streamable などさまざまな transport をサポートし、`outputType: "file"` でPNG 画像を自動保存するオプションも提供されます。
