import SwiftUI

public struct StandaloneStickyView: View {
    public let noteId: UUID
    @ObservedObject var noteStore: NoteStore
    public var onDock: () -> Void
    public var onDelete: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    @FocusState private var isContentFocused: Bool

    public var body: some View {
        if let noteIndex = noteStore.notes.firstIndex(where: { $0.id == noteId }) {
            let note = noteStore.notes[noteIndex]
            let paperColor = colorScheme == .dark ? note.color.darkColor : note.color.lightColor

            VStack(spacing: 0) {
                // Header Bar (Tape/Pin Bar)
                HStack(spacing: 8) {
                    // Drag indicator
                    Image(systemName: "circle.grid.2x2.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.primary.opacity(0.4))

                    // Color picker dots
                    HStack(spacing: 5) {
                        ForEach(NoteColor.allCases, id: \.self) { c in
                            Circle()
                                .fill(colorScheme == .dark ? c.darkColor : c.lightColor)
                                .frame(width: 12, height: 12)
                                .overlay(
                                    Circle()
                                        .stroke(note.color == c ? Color.primary.opacity(0.6) : Color.clear, lineWidth: 1.5)
                                )
                                .onTapGesture {
                                    var updated = note
                                    updated.color = c
                                    noteStore.updateNote(updated)
                                }
                        }
                    }

                    Spacer()

                    // Dock back to Nook button
                    Button(action: onDock) {
                        Image(systemName: "sidebar.left")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.primary.opacity(0.6))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .help("Dock back into Nook Notes")

                    // Delete button
                    Button(action: onDelete) {
                        Image(systemName: "xmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.primary.opacity(0.5))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .help("Delete Sticky Note")
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(Color.primary.opacity(0.04))

                Divider().opacity(0.15)

                // Editable Title
                TextField("Title", text: Binding(
                    get: { note.title },
                    set: { newTitle in
                        var updated = note
                        updated.title = newTitle
                        noteStore.updateNote(updated)
                    }
                ))
                .font(.geist(15, weight: .bold))
                .textFieldStyle(PlainTextFieldStyle())
                .padding(.horizontal, 12)
                .padding(.top, 8)

                // Editable Content
                TextEditor(text: Binding(
                    get: { note.content },
                    set: { newContent in
                        var updated = note
                        updated.content = newContent
                        noteStore.updateNote(updated)
                    }
                ))
                .font(.geist(13, weight: .regular))
                .lineSpacing(3)
                .focused($isContentFocused)
                .scrollContentBackground(.hidden)
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
            }
            .background(paperColor)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(note.color.accentBorder.opacity(0.5), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.18), radius: 10, x: 2, y: 4)
        } else {
            EmptyView()
        }
    }
}
