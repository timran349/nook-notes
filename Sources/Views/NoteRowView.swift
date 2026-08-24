import SwiftUI

public struct NoteRowView: View {
    public let note: Note
    public let isSelected: Bool
    public let onSelect: () -> Void
    public let onDelete: () -> Void
    public let onRename: () -> Void

    @State private var isHovered: Bool = false

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
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? Color.accentColor.opacity(0.12) : (isHovered ? Color.primary.opacity(0.04) : Color.clear))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? Color.accentColor.opacity(0.25) : Color.clear, lineWidth: 0.75)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect()
        }
        .onHover { hovering in
            withAnimation(.easeOut(duration: 0.1)) {
                isHovered = hovering
            }
        }
        .contextMenu {
            Button(action: onSelect) {
                Label("Open", systemImage: "arrow.up.forward.app")
            }
            Button(action: onRename) {
                Label("Rename", systemImage: "pencil")
            }
            Divider()
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}
