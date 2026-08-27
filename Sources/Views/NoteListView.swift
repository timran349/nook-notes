import SwiftUI

public struct NoteListView: View {
    @ObservedObject var noteStore: NoteStore
    public var onSelectNote: (Note) -> Void

    @State private var noteToRename: Note?
    @State private var renameText: String = ""
    @State private var showRenameAlert: Bool = false

    public var body: some View {
        Group {
            if noteStore.filteredNotes.isEmpty {
                VStack(spacing: 14) {
                    Spacer()
                    Image(systemName: "note.text")
                        .font(.system(size: 36, weight: .thin))
                        .foregroundColor(.secondary.opacity(0.35))

                    Text("No notes yet")
                        .font(.geist(14, weight: .medium))
                        .foregroundColor(.secondary)

                    Button(action: {
                        withAnimation(.spring(response: 0.22, dampingFraction: 0.8)) {
                            let newNote = noteStore.createNote()
                            onSelectNote(newNote)
                        }
                    }) {
                        Text("+ Create Note")
                            .font(.geist(13, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 9)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color.primary.opacity(0.85))
                            )
                    }
                    .buttonStyle(PlainButtonStyle())

                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 8) {
                        ForEach(noteStore.filteredNotes) { note in
                            NoteRowView(
                                note: note,
                                isSelected: noteStore.selectedNoteId == note.id,
                                onSelect: {
                                    noteStore.selectedNoteId = note.id
                                    onSelectNote(note)
                                },
                                onDelete: {
                                    withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                                        noteStore.deleteNote(id: note.id)
                                    }
                                },
                                onRename: {
                                    noteToRename = note
                                    renameText = note.title
                                    showRenameAlert = true
                                },
                                onDetach: {
                                    DetachedStickyManager.shared.detachNote(note, noteStore: noteStore)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 4)
                    .padding(.top, 2)
                    .padding(.bottom, 12)
                }
            }
        }
        .alert("Rename Note", isPresented: $showRenameAlert) {
            TextField("Note Title", text: $renameText)
            Button("Cancel", role: .cancel) {}
            Button("Save") {
                if var target = noteToRename {
                    target.title = renameText
                    noteStore.updateNote(target)
                }
            }
        }
    }
}
