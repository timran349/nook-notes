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

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header Row: Title & Action/Badge
            HStack(alignment: .top, spacing: 8) {
                Text(note.displayTitle)
                    .font(.geist(14, weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(1)

                Spacer()

                // Subtle Date Pill (e.g. 5:25 PM)
                Text(note.formattedTime)
                    .font(.geist(10, weight: .semibold))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(Color.primary.opacity(0.05))
                    )
            }

            // Preview Text
            Text(note.previewText)
                .font(.geist(12, weight: .regular))
                .foregroundColor(.secondary)
                .lineLimit(2)
                .lineSpacing(2)

            // Footer Badges
            if note.isDetached {
                HStack(spacing: 4) {
                    Image(systemName: "pin.fill")
                        .font(.system(size: 9))
                    Text("Floating Sticky")
                        .font(.geist(10, weight: .medium))
                }
                .foregroundColor(.secondary)
                .padding(.top, 2)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(cardBackground)
        )
        .scaleEffect(isPressed ? 0.98 : (isHovered ? 1.008 : 1.0))
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
