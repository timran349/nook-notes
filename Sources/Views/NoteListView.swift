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
                VStack(spacing: 12) {
                    Spacer()
                    Image(systemName: "note.text")
                        .font(.system(size: 28, weight: .thin))
                        .foregroundColor(.secondary.opacity(0.5))

                    Text(noteStore.searchQuery.isEmpty ? "Nothing here yet." : "No matching notes")
                        .font(.geist(13, weight: .medium))
                        .foregroundColor(.secondary)

                    Button(action: {
                        withAnimation(.spring(response: 0.22, dampingFraction: 0.8)) {
                            noteStore.searchQuery = ""
                            let newNote = noteStore.createNote()
                            onSelectNote(newNote)
                        }
                    }) {
                        Text("+ New sticky note")
                            .font(.geist(12, weight: .semibold))
                            .foregroundColor(.accentColor)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.accentColor.opacity(0.08))
                            )
                    }
                    .buttonStyle(PlainButtonStyle())

                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 14) {
                        ForEach(noteStore.groupedNotes, id: \.category) { section in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(section.category.rawValue)
                                    .font(.geist(10, weight: .bold))
                                    .foregroundColor(.secondary.opacity(0.6))
                                    .padding(.leading, 6)
                                    .padding(.bottom, 2)

                                ForEach(section.notes) { note in
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
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 16)
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
