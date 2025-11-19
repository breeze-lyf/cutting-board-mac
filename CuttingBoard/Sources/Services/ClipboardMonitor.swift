import AppKit
import Combine

final class ClipboardMonitor {
    private let pasteboard = NSPasteboard.general
    private var changeCount: Int
    private var timer: Timer?
    private let historyStore: ClipboardHistoryStore

    init(historyStore: ClipboardHistoryStore = ClipboardHistoryStore.shared) {
        self.historyStore = historyStore
        changeCount = pasteboard.changeCount
        start()
    }

    deinit {
        timer?.invalidate()
    }

    private func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.75, repeats: true) { [weak self] _ in
            self?.checkPasteboard()
        }
    }

    private func checkPasteboard() {
        guard pasteboard.changeCount != changeCount else { return }
        changeCount = pasteboard.changeCount

        if let string = pasteboard.string(forType: .string) {
            let item = ClipboardItem(type: .text, text: string, fileSize: string.lengthOfBytes(using: .utf8))
            historyStore.add(item)
            return
        }

        if let image = NSImage(pasteboard: pasteboard) {
            let item = ClipboardItem(type: .image, image: image, fileSize: image.tiffRepresentation?.count ?? 0)
            historyStore.add(item)
            return
        }

        if let urls = pasteboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL] {
            for url in urls {
                guard let values = try? url.resourceValues(forKeys: [.fileSizeKey]),
                      let size = values.fileSize
                else { continue }
                let item = ClipboardItem(type: .file, fileURL: url, fileSize: size)
                historyStore.add(item)
            }
        }
    }
}
