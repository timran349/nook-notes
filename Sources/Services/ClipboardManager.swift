import AppKit
import Combine

public struct ClipboardItem: Identifiable, Equatable, Hashable {
    public let id: UUID
    public let text: String
    public let timestamp: Date

    public init(id: UUID = UUID(), text: String, timestamp: Date = Date()) {
        self.id = id
        self.text = text
        self.timestamp = timestamp
    }

    public var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: timestamp)
    }
}

public class ClipboardManager: ObservableObject {
    public static let shared = ClipboardManager()

    @Published public var items: [ClipboardItem] = []
    private var lastChangeCount: Int = 0
    private var timer: Timer?

    public init() {
        startMonitoring()
    }

    public func startMonitoring() {
        lastChangeCount = NSPasteboard.general.changeCount
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.checkPasteboard()
        }
    }

    private func checkPasteboard() {
        let pb = NSPasteboard.general
        if pb.changeCount != lastChangeCount {
            lastChangeCount = pb.changeCount
            if let newString = pb.string(forType: .string), !newString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                DispatchQueue.main.async {
                    if self.items.first?.text != newString {
                        let item = ClipboardItem(text: newString)
                        self.items.insert(item, at: 0)
                        if self.items.count > 50 {
                            self.items.removeLast()
                        }
                    }
                }
            }
        }
    }

    public func copyToClipboard(_ item: ClipboardItem) {
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(item.text, forType: .string)
        self.lastChangeCount = pb.changeCount
    }

    public func clearAll() {
        items.removeAll()
    }
}
