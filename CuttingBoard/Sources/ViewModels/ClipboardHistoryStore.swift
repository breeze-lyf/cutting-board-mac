import Foundation
import Combine
import AppKit

final class ClipboardHistoryStore: ObservableObject {
    static let shared = ClipboardHistoryStore()
    @Published private(set) var items: [ClipboardItem] = []
    @Published var pinnedItemIDs: Set<UUID> = []

    private let persistenceURL: URL = {
        let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: NSTemporaryDirectory())
        let folder = directory.appendingPathComponent("CuttingBoard", isDirectory: true)
        try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        return folder.appendingPathComponent("history.json")
    }()

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private var cancellables: Set<AnyCancellable> = []

    private let maxEntries = 200

    init() {
        loadHistory()
        setupAutoSave()
    }

    func add(_ item: ClipboardItem) {
        guard item.fileSize <= 15 * 1_048_576 else { return }
        if items.contains(where: { $0.id == item.id }) { return }
        items.insert(item, at: 0)
        enforceLimits()
    }

    func clear() {
        items.removeAll()
        pinnedItemIDs.removeAll()
        saveHistory()
    }

    func remove(_ item: ClipboardItem) {
        items.removeAll { $0.id == item.id }
    }

    private func enforceLimits() {
        let maxCount = maxEntries + pinnedItemIDs.count
        if items.count > maxCount {
            items = Array(items.prefix(maxCount))
        }
    }

    private func setupAutoSave() {
        $items
            .debounce(for: .seconds(1.5), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.saveHistory()
            }
            .store(in: &cancellables)
    }

    private func loadHistory() {
        guard let data = try? Data(contentsOf: persistenceURL),
              let storedItems = try? decoder.decode([ClipboardItem].self, from: data)
        else { return }
        self.items = storedItems
    }

    private func saveHistory() {
        guard let data = try? encoder.encode(items) else { return }
        try? data.write(to: persistenceURL)
    }
}
