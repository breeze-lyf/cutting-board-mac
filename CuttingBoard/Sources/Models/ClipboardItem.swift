import Foundation
import AppKit

enum ClipboardContentType: String, Codable, CaseIterable {
    case text
    case image
    case file

    var iconName: String {
        switch self {
        case .text: return "text.alignleft"
        case .image: return "photo"
        case .file: return "doc"
        }
    }
}

struct ClipboardItem: Identifiable, Codable {
    let id: UUID
    let createdAt: Date
    let type: ClipboardContentType
    let text: String?
    let imageData: Data?
    let fileURL: URL?
    let fileSize: Int

    init(
        id: UUID = UUID(),
        createdAt: Date = .now,
        type: ClipboardContentType,
        text: String? = nil,
        image: NSImage? = nil,
        fileURL: URL? = nil,
        fileSize: Int = 0
    ) {
        self.id = id
        self.createdAt = createdAt
        self.type = type
        self.text = text
        self.fileURL = fileURL
        self.fileSize = fileSize
        if let image, let data = image.pngData() {
            self.imageData = data
        } else {
            self.imageData = nil
        }
    }

    var displayTitle: String {
        switch type {
        case .text:
            return text?.trimmingCharacters(in: .whitespacesAndNewlines).prefix(80).description ?? "Text"
        case .image:
            return "Image \(Int(imageMegabytes)) MB"
        case .file:
            return fileURL?.lastPathComponent ?? "File"
        }
    }

    var subtitle: String {
        switch type {
        case .text:
            return "Copied at \(formattedDate)"
        case .image:
            return "Resolution: \(imageResolutionDescription ?? "Unknown")"
        case .file:
            return "Size: \(ByteCountFormatter.string(fromByteCount: Int64(fileSize), countStyle: .file))"
        }
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: createdAt)
    }

    private var imageMegabytes: Double {
        guard let data = imageData else { return 0 }
        return Double(data.count) / 1_048_576.0
    }

    var imageResolutionDescription: String? {
        guard let imageData,
              let image = NSImage(data: imageData)
        else { return nil }

        return "\(Int(image.size.width))×\(Int(image.size.height))"
    }
}

private extension NSImage {
    func pngData() -> Data? {
        guard let tiffData = tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData)
        else { return nil }
        return bitmap.representation(using: .png, properties: [:])
    }
}
