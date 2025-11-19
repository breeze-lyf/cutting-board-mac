# CuttingBoard (macOS 剪贴板增强工具)

CuttingBoard 是一个原生 SwiftUI 菜单栏应用，专为 macOS 打造的剪贴板历史工具。它支持文本、图片以及不超过 15MB 的文件记录，帮助你快速查看、搜索并再次复制历史记录。

## 功能特性

- **实时监听**：使用 `NSPasteboard` 轮询方式捕捉剪贴板变化。
- **多类型支持**：文本、图片、文件（15MB 限制）。
- **历史列表**：最多自动保存 200 条最新记录，可搜索、预览、再次复制。
- **菜单栏界面**：通过 `MenuBarExtra` 以窗口方式展示，随时唤出。
- **持久化存储**：JSON 持久化到 `~/Library/Application Support/CuttingBoard/history.json`。
- **自定义偏好**：保留天数、开机自启等设置示例。

## 目录结构

```
CuttingBoard/
├── Sources/
│   ├── CuttingBoardApp.swift        // App 入口、菜单栏 Scene
│   ├── Models/
│   │   └── ClipboardItem.swift      // 数据模型 & 类型定义
│   ├── ViewModels/
│   │   ├── ClipboardHistoryStore.swift
│   │   └── PreferencesStore.swift
│   ├── Services/
│   │   ├── ClipboardMonitor.swift   // 监听 NSPasteboard
│   │   └── ClipboardWriter.swift    // 将记录写回剪贴板
│   └── Views/
│       └── ContentView.swift        // SwiftUI 界面
└── Resources/
```

## 构建与运行

> **注意**：由于项目依赖 AppKit/SwiftUI，仅能在 macOS + Xcode 15 及以上环境构建运行。

1. 在 macOS 上 clone 仓库：
   ```bash
   git clone <repo-url>
   cd cutting-board-mac/CuttingBoard
   ```
2. 使用 Xcode 打开 `CuttingBoard` 目录（或创建一个空的 SwiftUI App 项目并将 `Sources/` 内容拷贝进去）。
3. 选择 `My Mac` 目标并运行。

## 后续可扩展方向

- 使用 `LaunchAtLogin` framework 真正控制登录项。
- 将 `Timer` 轮询改为 `DistributedNotificationCenter` 或 `event taps` 提升效率。
- 为图片/文件提供缩略图缓存与拖拽支持。
- iCloud 同步、快捷键粘贴、跨设备共享等高级功能。
