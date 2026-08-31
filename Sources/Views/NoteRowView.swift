import SwiftUI

public struct NoteRowView: View {
    public let note: Note
    public let isSelected: Bool
    public let onSelect: () -> Void
    public let onDelete: () -> Void
    public let onRename: () -> Void
    public let onDetach: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    @State private var isHovered: Bool = false
    @State private var isPressed: Bool = false
    @State private var isExpanded: Bool = false

    private var cardBackground: Color {
        colorScheme == .dark
            ? Color(red: 0.16, green: 0.16, blue: 0.18)
            : Color.white
    }

    private var titleColor: Color {
        colorScheme == .dark
            ? Color(red: 0.94, green: 0.94, blue: 0.95)
            : Color(red: 0.22, green: 0.21, blue: 0.23)
    }

    private var subtitleColor: Color {
        colorScheme == .dark
            ? Color(red: 0.60, green: 0.60, blue: 0.63)
            : Color(red: 0.60, green: 0.59, blue: 0.62)
    }

    private var hasLongContent: Bool {
        let trimmed = note.content.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.count > 60 || trimmed.contains("\n")
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header Row: Title & Action
            HStack(alignment: .top) {
                Text(note.displayTitle)
                    .font(.geist(17, weight: .bold))
                    .foregroundColor(titleColor)
                    .lineLimit(isExpanded ? nil : 1)

                Spacer()
            }

            // Note Body Text (Full content if expanded, snippet if collapsed)
            if isExpanded {
                Text(note.content.isEmpty ? note.previewText : note.content)
                    .font(.geist(13, weight: .regular))
                    .foregroundColor(subtitleColor)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .transition(AnyTransition.opacity.combined(with: .move(edge: .top)))
            } else {
                Text(note.previewText)
                    .font(.geist(13, weight: .medium))
                    .foregroundColor(subtitleColor)
                    .lineLimit(2)
            }

            // Show More / Show Less Toggle Button
            if hasLongContent {
                Button(action: {
                    withAnimation(.spring(response: 0.22, dampingFraction: 0.8)) {
                        isExpanded.toggle()
                    }
                }) {
                    HStack(spacing: 4) {
                        Text(isExpanded ? "Show less" : "Show more")
                            .font(.geist(12, weight: .semibold))
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundColor(.secondary.opacity(0.8))
                    .padding(.top, 4)
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(cardBackground)
        )
        .scaleEffect(isPressed ? 0.985 : (isHovered ? 1.006 : 1.0))
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect()
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 15)
                .onEnded { _ in
                    onDetach()
                }
        )
        .onHover { hovering in
            withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                isHovered = hovering
            }
        }
        .animation(.spring(response: 0.2, dampingFraction: 0.8), value: isHovered)
        .contextMenu {
            Button(action: {
                withAnimation(.spring(response: 0.22, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            }) {
                Label(isExpanded ? "Show Less" : "Show More", systemImage: isExpanded ? "chevron.up" : "chevron.down")
            }
            Button(action: onDetach) {
                Label(note.isDetached ? "Focus Floating Note" : "Stick on Desktop", systemImage: "pin")
            }
            Button(action: onSelect) {
                Label("Edit Note", systemImage: "pencil")
            }
            Divider()
            Button(role: .destructive, action: onDelete) {
                Label("Delete Note", systemImage: "trash")
            }
        }
    }
}
