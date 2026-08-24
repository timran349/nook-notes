import SwiftUI

public struct NoteEditorView: View {
    @Binding var note: Note
    public var onNoteChanged: (Note) -> Void

    @FocusState private var isContentFocused: Bool
    @FocusState private var isTitleFocused: Bool

    public init(
        note: Binding<Note>,
        onNoteChanged: @escaping (Note) -> Void
    ) {
        self._note = note
        self.onNoteChanged = onNoteChanged
    }

    public var body: some View {
        VStack(spacing: 8) {
            // Optional title field
            TextField("Title (optional)", text: Binding(
                get: { note.title },
                set: { newTitle in
                    note.title = newTitle
                    onNoteChanged(note)
                }
            ))
            .font(.geist(16, weight: .bold))
            .textFieldStyle(PlainTextFieldStyle())
            .focused($isTitleFocused)
            .padding(.horizontal, 16)
            .padding(.top, 4)

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
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                isContentFocused = true
            }
        }
    }
}
