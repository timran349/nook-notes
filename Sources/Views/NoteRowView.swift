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

    public var body: some View {
        let paperColor = colorScheme == .dark ? note.color.darkColor : note.color.lightColor

        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline) {
                // Sticky color indicator dot
                Circle()
                    .fill(note.color.accentBorder)
                    .frame(width: 8, height: 8)

                Text(note.displayTitle)
                    .font(.geist(13, weight: .semibold))
                    .foregroundColor(.primary.opacity(0.9))
                    .lineLimit(1)

                Spacer()

                if note.isDetached {
                    Image(systemName: "pin.fill")
                        .font(.system(size: 9))
                        .foregroundColor(.accentColor)
                        .help("Pinned on Desktop")
                }

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
                        ? paperColor.opacity(0.85)
                        : (isHovered ? paperColor.opacity(0.65) : paperColor.opacity(0.35))
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(
                    isSelected
                        ? note.color.accentBorder
                        : (isHovered ? note.color.accentBorder.opacity(0.6) : Color.primary.opacity(0.06)),
                    lineWidth: isSelected ? 1.25 : 0.75
                )
        )
        .scaleEffect(isPressed ? 0.98 : (isHovered ? 1.012 : 1.0))
        .shadow(
            color: isHovered ? Color.black.opacity(0.12) : Color.black.opacity(0.04),
            radius: isHovered ? 5 : 2,
            x: 0,
            y: isHovered ? 2 : 1
        )
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
            withAnimation(.spring(response: 0.2, dampingFraction: 0.75)) {
                isHovered = hovering
            }
        }
        .animation(.spring(response: 0.2, dampingFraction: 0.75), value: isHovered)
        .contextMenu {
            Button(action: onDetach) {
                Label(note.isDetached ? "Bring Sticky to Focus" : "Stick on Desktop", systemImage: "pin")
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
