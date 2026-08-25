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

        VStack(alignment: .leading, spacing: 8) {
            // Top Pill Badges matching reference image (e.g. "2026", "Notes")
            HStack(spacing: 6) {
                Text(note.yearTag)
                    .font(.geist(10, weight: .semibold))
                    .foregroundColor(colorScheme == .dark ? .white.opacity(0.8) : .black.opacity(0.65))
                    .padding(.horizontal, 7)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(Color.primary.opacity(0.06))
                    )

                Text(note.color.tagLabel)
                    .font(.geist(10, weight: .medium))
                    .foregroundColor(colorScheme == .dark ? .white.opacity(0.7) : .black.opacity(0.55))
                    .padding(.horizontal, 7)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(Color.primary.opacity(0.05))
                    )

                Spacer()

                if note.isDetached {
                    HStack(spacing: 3) {
                        Image(systemName: "pin.fill")
                            .font(.system(size: 9))
                        Text("Pinned")
                            .font(.geist(9, weight: .semibold))
                    }
                    .foregroundColor(.accentColor)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(Color.accentColor.opacity(0.12))
                    )
                }
            }

            // Bold Geist Title
            Text(note.displayTitle)
                .font(.geist(15, weight: .bold))
                .foregroundColor(.primary.opacity(0.92))
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)

            // Content preview text
            Text(note.previewText)
                .font(.geist(11, weight: .regular))
                .foregroundColor(.secondary.opacity(0.85))
                .lineLimit(2)
                .lineSpacing(2)

            // Bottom Footer Row with timestamp & subtle indicators
            HStack {
                Text(note.formattedTime)
                    .font(.geist(10, weight: .medium))
                    .foregroundColor(.secondary.opacity(0.65))

                Spacer()

                HStack(spacing: 8) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 9))
                        .foregroundColor(.secondary.opacity(0.5))

                    Image(systemName: "circle.circle")
                        .font(.system(size: 9))
                        .foregroundColor(.secondary.opacity(0.5))
                }
            }
            .padding(.top, 2)
        }
        .padding(13)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(paperColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    isSelected
                        ? note.color.accentBorder
                        : (isHovered ? note.color.accentBorder.opacity(0.8) : Color.primary.opacity(0.06)),
                    lineWidth: isSelected ? 1.5 : 0.8
                )
        )
        .scaleEffect(isPressed ? 0.98 : (isHovered ? 1.012 : 1.0))
        .shadow(
            color: isHovered ? Color.black.opacity(0.12) : Color.black.opacity(0.04),
            radius: isHovered ? 6 : 2,
            x: 0,
            y: isHovered ? 3 : 1
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
