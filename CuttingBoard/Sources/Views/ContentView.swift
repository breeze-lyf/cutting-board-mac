import SwiftUI
import AppKit

struct ContentView: View {
    @EnvironmentObject private var historyStore: ClipboardHistoryStore
    @EnvironmentObject private var preferences: PreferencesStore
    @State private var filterText: String = ""
    @State private var previewItem: ClipboardItem?

    private var filteredItems: [ClipboardItem] {
        guard !filterText.isEmpty else { return historyStore.items }
        return historyStore.items.filter { item in
            item.displayTitle.localizedCaseInsensitiveContains(filterText) ||
            (item.text?.localizedCaseInsensitiveContains(filterText) ?? false)
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            header
            searchField
            historyList
            footer
        }
        .padding(.horizontal)
        .sheet(item: $previewItem) { item in
            ClipboardPreview(item: item)
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("CuttingBoard")
                    .font(.headline)
                Text("最多保存200条记录，支持文本、图片和15MB内的文件。")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Button {
                historyStore.clear()
            } label: {
                Label("清空", systemImage: "trash")
            }
            .help("清除所有历史记录")
        }
    }

    private var searchField: some View {
        TextField("搜索历史...", text: $filterText)
            .textFieldStyle(RoundedBorderTextFieldStyle())
    }

    private var historyList: some View {
        List {
            if filteredItems.isEmpty {
                EmptyHistoryView()
            } else {
                ForEach(filteredItems) { item in
                    ClipboardRow(item: item)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            previewItem = item
                        }
                        .contextMenu {
                            Button("复制到系统剪贴板") {
                                ClipboardWriter.write(item: item)
                            }
                            Button("删除记录", role: .destructive) {
                                delete(item: item)
                            }
                        }
                }
            }
        }
        .listStyle(.inset)
    }

    private var footer: some View {
        HStack {
            Stepper(value: $preferences.keepForDays, in: 1...30) {
                Text("保留天数：\(preferences.keepForDays)")
                    .font(.caption)
            }
            Spacer()
            Toggle("开机自启", isOn: $preferences.launchAtLogin)
                .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                .font(.caption)
        }
    }

    private func delete(item: ClipboardItem) {
        historyStore.remove(item)
    }
}

private struct EmptyHistoryView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "tray")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            Text("没有记录")
                .font(.headline)
            Text("复制一些内容后再回来看看。")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }
}

struct ClipboardRow: View {
    let item: ClipboardItem

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: item.type.iconName)
                .font(.title3)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 4) {
                Text(item.displayTitle)
                    .font(.body)
                    .lineLimit(2)
                Text(item.subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            Spacer()
            Text(item.createdAt, style: .time)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct ClipboardPreview: View {
    let item: ClipboardItem

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(item.displayTitle)
                .font(.title3)
            switch item.type {
            case .text:
                ScrollView {
                    Text(item.text ?? "")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .textSelection(.enabled)
                }
            case .image:
                if let data = item.imageData, let nsImage = NSImage(data: data) {
                    Image(nsImage: nsImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                }
            case .file:
                if let url = item.fileURL {
                    VStack(alignment: .leading, spacing: 8) {
                        Label(url.lastPathComponent, systemImage: "doc")
                        Text("位置：\(url.path)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            Button("复制到系统剪贴板") {
                ClipboardWriter.write(item: item)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .frame(minWidth: 360, minHeight: 320)
    }
}
