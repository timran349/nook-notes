import SwiftUI

public struct NoteEditorView: View {
    @Binding var note: Note
    @ObservedObject var noteStore: NoteStore
    public var onNoteChanged: (Note) -> Void

    @Environment(\.colorScheme) private var colorScheme
    @FocusState private var isContentFocused: Bool
    @FocusState private var isTitleFocused: Bool

    public init(
        note: Binding<Note>,
        noteStore: NoteStore,
        onNoteChanged: @escaping (Note) -> Void
    ) {
        self._note = note
        self.noteStore = noteStore
        self.onNoteChanged = onNoteChanged
    }

    private var paperColor: Color {
        colorScheme == .dark ? Color(red: 0.16, green: 0.16, blue: 0.18) : Color.white
    }

    public var body: some View {
        VStack(spacing: 8) {
            // Pin & options toolbar
            HStack {
                Spacer()

                // Stick on Desktop button
                Button(action: {
                    DetachedStickyManager.shared.detachNote(note, noteStore: noteStore)
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "pin.fill")
                            .font(.system(size: 10, weight: .bold))
                        Text(note.isDetached ? "Floating Sticky" : "Stick on Desktop")
                            .font(.geist(11, weight: .medium))
                    }
                    .foregroundColor(.primary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color.primary.opacity(0.06))
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .help("Detach as floating sticky note on desktop")
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)

            // Geist Title Field
            TextField("Title (optional)", text: Binding(
                get: { note.title },
                set: { newTitle in
                    note.title = newTitle
                    onNoteChanged(note)
                }
            ))
            .font(.geist(17, weight: .bold))
            .textFieldStyle(PlainTextFieldStyle())
            .focused($isTitleFocused)
            .padding(.horizontal, 16)

            Divider()
                .opacity(0.1)
                .padding(.horizontal, 16)

            // Body text editor
            TextEditor(text: Binding(
                get: { note.content },
                set: { newContent in
                    note.content = newContent
                    onNoteChanged(note)
                }
            ))
            .font(.geist(13, weight: .regular))
            .lineSpacing(4)
            .focused($isContentFocused)
            .scrollContentBackground(.hidden)
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(paperColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.primary.opacity(0.08), lineWidth: 0.75)
        )
        .padding(8)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                isContentFocused = true
            }
        }
    }
}
