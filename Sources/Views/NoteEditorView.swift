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

    public var body: some View {
        let paperColor = colorScheme == .dark ? note.color.darkColor : note.color.lightColor

        VStack(spacing: 8) {
            // Color picker & desktop pin toolbar
            HStack {
                // Color dots
                HStack(spacing: 6) {
                    ForEach(NoteColor.allCases, id: \.self) { c in
                        Circle()
                            .fill(colorScheme == .dark ? c.darkColor : c.lightColor)
                            .frame(width: 13, height: 13)
                            .overlay(
                                Circle()
                                    .stroke(note.color == c ? Color.primary.opacity(0.6) : Color.clear, lineWidth: 1.5)
                            )
                            .onTapGesture {
                                withAnimation(.spring(response: 0.18, dampingFraction: 0.8)) {
                                    note.color = c
                                    onNoteChanged(note)
                                }
                            }
                    }
                }

                Spacer()

                // Stick on Desktop button
                Button(action: {
                    DetachedStickyManager.shared.detachNote(note, noteStore: noteStore)
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "pin.fill")
                            .font(.system(size: 10, weight: .bold))
                        Text(note.isDetached ? "Floating" : "Stick on Desktop")
                            .font(.geist(11, weight: .medium))
                    }
                    .foregroundColor(.accentColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.accentColor.opacity(0.1))
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .help("Detach as floating sticky note on desktop")
            }
            .padding(.horizontal, 16)
            .padding(.top, 6)

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

            Divider()
                .opacity(0.15)
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
            RoundedRectangle(cornerRadius: 10)
                .fill(paperColor.opacity(0.85))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(note.color.accentBorder.opacity(0.4), lineWidth: 0.75)
        )
        .padding(8)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                isContentFocused = true
            }
        }
    }
}
