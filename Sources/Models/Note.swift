import Foundation
import SwiftUI

public enum NoteColor: String, CaseIterable, Codable {
    case yellow = "yellow"
    case mint = "mint"
    case peach = "peach"
    case blue = "blue"
    case lavender = "lavender"

    public var lightColor: Color {
        switch self {
        case .yellow: return Color(red: 0.99, green: 0.95, blue: 0.68)
        case .mint: return Color(red: 0.86, green: 0.96, blue: 0.86)
        case .peach: return Color(red: 1.0, green: 0.88, blue: 0.82)
        case .blue: return Color(red: 0.87, green: 0.93, blue: 0.99)
        case .lavender: return Color(red: 0.93, green: 0.89, blue: 0.99)
        }
    }

    public var darkColor: Color {
        switch self {
        case .yellow: return Color(red: 0.26, green: 0.24, blue: 0.12)
        case .mint: return Color(red: 0.12, green: 0.24, blue: 0.14)
        case .peach: return Color(red: 0.28, green: 0.16, blue: 0.14)
        case .blue: return Color(red: 0.12, green: 0.20, blue: 0.28)
        case .lavender: return Color(red: 0.22, green: 0.16, blue: 0.28)
        }
    }

    public var accentBorder: Color {
        switch self {
        case .yellow: return Color(red: 0.88, green: 0.82, blue: 0.40)
        case .mint: return Color(red: 0.65, green: 0.85, blue: 0.65)
        case .peach: return Color(red: 0.92, green: 0.70, blue: 0.62)
        case .blue: return Color(red: 0.65, green: 0.80, blue: 0.92)
        case .lavender: return Color(red: 0.78, green: 0.70, blue: 0.90)
        }
    }
}

public struct Note: Identifiable, Codable, Equatable, Hashable {
    public let id: UUID
    public var title: String
    public var content: String
    public var colorRaw: String
    public var isDetached: Bool
    public var detachedX: CGFloat?
    public var detachedY: CGFloat?
    public var detachedWidth: CGFloat?
    public var detachedHeight: CGFloat?
    public let createdAt: Date
    public var updatedAt: Date

    public var color: NoteColor {
        get { NoteColor(rawValue: colorRaw) ?? .yellow }
        set { colorRaw = newValue.rawValue }
    }

    public init(
        id: UUID = UUID(),
        title: String = "",
        content: String = "",
        color: NoteColor = .yellow,
        isDetached: Bool = false,
        detachedX: CGFloat? = nil,
        detachedY: CGFloat? = nil,
        detachedWidth: CGFloat? = nil,
        detachedHeight: CGFloat? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.colorRaw = color.rawValue
        self.isDetached = isDetached
        self.detachedX = detachedX
        self.detachedY = detachedY
        self.detachedWidth = detachedWidth
        self.detachedHeight = detachedHeight
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // Codable keys with default fallbacks for backwards compatibility
    enum CodingKeys: String, CodingKey {
        case id, title, content, colorRaw, isDetached, detachedX, detachedY, detachedWidth, detachedHeight, createdAt, updatedAt
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        content = try container.decode(String.self, forKey: .content)
        colorRaw = try container.decodeIfPresent(String.self, forKey: .colorRaw) ?? NoteColor.yellow.rawValue
        isDetached = try container.decodeIfPresent(Bool.self, forKey: .isDetached) ?? false
        detachedX = try container.decodeIfPresent(CGFloat.self, forKey: .detachedX)
        detachedY = try container.decodeIfPresent(CGFloat.self, forKey: .detachedY)
        detachedWidth = try container.decodeIfPresent(CGFloat.self, forKey: .detachedWidth)
        detachedHeight = try container.decodeIfPresent(CGFloat.self, forKey: .detachedHeight)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
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
        return "Sticky Note"
    }

    /// Preview snippet for note rows
    public var previewText: String {
        let lines = content.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedTitle.isEmpty {
            return lines.first ?? "Empty note"
        } else if lines.count > 1 {
            return lines[1]
        } else {
            return "Empty note"
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

    /// Short formatted timestamp
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
