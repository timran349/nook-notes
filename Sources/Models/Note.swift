import Foundation

public struct Note: Identifiable, Codable, Equatable, Hashable {
    public let id: UUID
    public var title: String
    public var content: String
    public let createdAt: Date
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        title: String = "",
        content: String = "",
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    /// Derived title if explicit title is empty
    public var displayTitle: String {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedTitle.isEmpty {
            return trimmedTitle
        }
        let lines = content.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        if let firstLine = lines.first {
            return firstLine
        }
        return "Untitled Note"
    }

    /// Preview snippet for note rows
    public var previewText: String {
        let lines = content.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedTitle.isEmpty {
            return lines.first ?? "No additional text"
        } else if lines.count > 1 {
            return lines[1]
        } else {
            return "No additional text"
        }
    }

    /// Human-friendly relative date header label
    public var dateCategory: DateCategory {
        let calendar = Calendar.current
        if calendar.isDateInToday(updatedAt) {
            return .today
        } else if calendar.isDateInYesterday(updatedAt) {
            return .yesterday
        } else if let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: Date()), updatedAt >= sevenDaysAgo {
            return .thisWeek
        } else {
            return .older
        }
    }

    /// Short formatted timestamp (e.g. "10:42 AM", "Yesterday", "Aug 20")
    public var formattedTime: String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        if calendar.isDateInToday(updatedAt) {
            formatter.dateFormat = "h:mm a"
        } else if calendar.isDateInYesterday(updatedAt) {
            return "Yesterday"
        } else {
            formatter.dateFormat = "MMM d"
        }
        return formatter.string(from: updatedAt)
    }
}

public enum DateCategory: String, CaseIterable, Comparable {
    case today = "Today"
    case yesterday = "Yesterday"
    case thisWeek = "Previous 7 Days"
    case older = "Older"

    private var sortOrder: Int {
        switch self {
        case .today: return 0
        case .yesterday: return 1
        case .thisWeek: return 2
        case .older: return 3
        }
    }

    public static func < (lhs: DateCategory, rhs: DateCategory) -> Bool {
        lhs.sortOrder < rhs.sortOrder
    }
}
