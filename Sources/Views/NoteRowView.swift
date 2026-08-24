import SwiftUI

public struct NoteRowView: View {
    public let note: Note
    public let isSelected: Bool
    public let onSelect: () -> Void
    public let onDelete: () -> Void
    public let onRename: () -> Void

    @State private var isHovered: Bool = false
    @State private var isPressed: Bool = false

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline) {
                Text(note.displayTitle)
                    .font(.geist(13, weight: .semibold))
                    .foregroundColor(.primary.opacity(0.9))
                    .lineLimit(1)

                Spacer()

                Text(note.formattedTime)
                    .font(.geist(10, weight: .regular))
                    .foregroundColor(.secondary.opacity(0.8))
            }

            Text(note.previewText)
                .font(.geist(11, weight: .regular))
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    isSelected
                        ? Color.accentColor.opacity(0.14)
                        : (isHovered ? Color.primary.opacity(0.06) : Color.primary.opacity(0.02))
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(
                    isSelected
                        ? Color.accentColor.opacity(0.35)
                        : (isHovered ? Color.primary.opacity(0.12) : Color.clear),
                    lineWidth: 0.75
                )
        )
        .scaleEffect(isPressed ? 0.98 : (isHovered ? 1.012 : 1.0))
        .shadow(
            color: isHovered ? Color.black.opacity(0.08) : Color.clear,
            radius: isHovered ? 4 : 0,
            x: 0,
            y: isHovered ? 2 : 0
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect()
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        .onHover { hovering in
            withAnimation(.spring(response: 0.2, dampingFraction: 0.75)) {
                isHovered = hovering
            }
        }
        .animation(.spring(response: 0.2, dampingFraction: 0.75), value: isHovered)
        .animation(.spring(response: 0.15, dampingFraction: 0.8), value: isPressed)
        .contextMenu {
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
