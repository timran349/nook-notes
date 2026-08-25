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

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Bold Title (e.g. Untitled Note)
            Text(note.displayTitle)
                .font(.geist(17, weight: .bold))
                .foregroundColor(titleColor)
                .lineLimit(1)

            // Subtitle preview (e.g. Empty note)
            Text(note.previewText)
                .font(.geist(13, weight: .medium))
                .foregroundColor(subtitleColor)
                .lineLimit(1)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
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
            Button(action: onDetach) {
                Label(note.isDetached ? "Focus Floating Note" : "Stick on Desktop", systemImage: "pin")
            }
            Button(action: onSelect) {
                Label("Open Note", systemImage: "arrow.up.forward.app")
            }
            Button(action: onRename) {
                Label("Rename", systemImage: "pencil")
            }
            Divider()
            Button(role: .destructive, action: onDelete) {
                Label("Delete Note", systemImage: "trash")
            }
        }
    }
}
