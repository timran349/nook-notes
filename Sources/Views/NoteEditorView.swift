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
                // Color dots matching reference image
                HStack(spacing: 6) {
                    ForEach(NoteColor.allCases, id: \.self) { c in
                        Circle()
                            .fill(colorScheme == .dark ? c.darkColor : c.lightColor)
                            .frame(width: 14, height: 14)
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
                            .fill(Color.accentColor.opacity(0.12))
                    )
                }
                .buttonStyle(PlainButtonStyle())
                .help("Detach as floating sticky note on desktop")
            }
            .padding(.horizontal, 16)
            .padding(.top, 6)

            // Serif Title Field matching reference image headline font
            TextField("Title (optional)", text: Binding(
                get: { note.title },
                set: { newTitle in
                    note.title = newTitle
                    onNoteChanged(note)
                }
            ))
            .font(.system(size: 18, weight: .bold, design: .serif))
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
            RoundedRectangle(cornerRadius: 12)
                .fill(paperColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(note.color.accentBorder.opacity(0.5), lineWidth: 0.8)
        )
        .padding(8)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                isContentFocused = true
            }
        }
    }
}
