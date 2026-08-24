import Foundation
import SwiftUI

public enum NoteColor: String, CaseIterable, Codable {
    case mint = "mint"         // Pistachio Green (#DCEBCA)
    case lavender = "lavender" // Lavender Purple (#D5C9FA)
    case yellow = "yellow"     // Butter Cream (#EFEAD4)
    case peach = "peach"       // Warm Rose (#F7DBE3)
    case blue = "blue"         // Sky Soft (#D7E6F8)

    public var lightColor: Color {
        switch self {
        case .mint: return Color(red: 0.86, green: 0.92, blue: 0.79)
        case .lavender: return Color(red: 0.84, green: 0.79, blue: 0.98)
        case .yellow: return Color(red: 0.94, green: 0.92, blue: 0.83)
        case .peach: return Color(red: 0.97, green: 0.86, blue: 0.89)
        case .blue: return Color(red: 0.84, green: 0.90, blue: 0.97)
        }
    }

    public var darkColor: Color {
        switch self {
        case .mint: return Color(red: 0.15, green: 0.22, blue: 0.12)
        case .lavender: return Color(red: 0.17, green: 0.14, blue: 0.26)
        case .yellow: return Color(red: 0.22, green: 0.20, blue: 0.13)
        case .peach: return Color(red: 0.25, green: 0.14, blue: 0.17)
        case .blue: return Color(red: 0.13, green: 0.19, blue: 0.26)
        }
    }

    public var accentBorder: Color {
        switch self {
        case .mint: return Color(red: 0.72, green: 0.82, blue: 0.62)
        case .lavender: return Color(red: 0.70, green: 0.62, blue: 0.93)
        case .yellow: return Color(red: 0.82, green: 0.78, blue: 0.62)
        case .peach: return Color(red: 0.88, green: 0.67, blue: 0.73)
        case .blue: return Color(red: 0.66, green: 0.78, blue: 0.92)
        }
    }

    public var tagLabel: String {
        switch self {
        case .mint: return "Pistachio"
        case .lavender: return "Lavender"
        case .yellow: return "Butter"
        case .peach: return "Rose"
        case .blue: return "Sky"
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
        get { NoteColor(rawValue: colorRaw) ?? .mint }
        set { colorRaw = newValue.rawValue }
    }

    public init(
        id: UUID = UUID(),
        title: String = "",
        content: String = "",
        color: NoteColor = .mint,
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

    enum CodingKeys: String, CodingKey {
        case id, title, content, colorRaw, isDetached, detachedX, detachedY, detachedWidth, detachedHeight, createdAt, updatedAt
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        content = try container.decode(String.self, forKey: .content)
        colorRaw = try container.decodeIfPresent(String.self, forKey: .colorRaw) ?? NoteColor.mint.rawValue
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
        return "Untitled Note"
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

    /// Year tag (e.g., "2026")
    public var yearTag: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: updatedAt)
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
