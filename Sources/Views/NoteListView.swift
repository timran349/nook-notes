import SwiftUI
import UniformTypeIdentifiers

public struct NoteListView: View {
    @ObservedObject var noteStore: NoteStore
    public var onSelectNote: (Note) -> Void

    @State private var noteToRename: Note?
    @State private var renameText: String = ""
    @State private var showRenameAlert: Bool = false

    @State private var draggingNoteID: UUID?

    private var columns: [GridItem] {
        switch noteStore.layoutMode {
        case "grid2":
            return [GridItem(.flexible(), spacing: 6), GridItem(.flexible(), spacing: 6)]
        case "grid3":
            return [GridItem(.flexible(), spacing: 6), GridItem(.flexible(), spacing: 6), GridItem(.flexible(), spacing: 6)]
        default:
            return [GridItem(.flexible(), spacing: 4)]
        }
    }

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
                    LazyVGrid(columns: columns, spacing: 4) {
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
                                }
                            )
                            .opacity(draggingNoteID == note.id ? 0.35 : 1.0)
                            .scaleEffect(draggingNoteID == note.id ? 0.96 : 1.0)
                            .onDrag {
                                self.draggingNoteID = note.id
                                return NSItemProvider(object: note.id.uuidString as NSString)
                            } preview: {
                                // Transparent ghost preview to prevent duplicate floating image
                                Color.clear.frame(width: 1, height: 1)
                            }
                            .onDrop(of: [.text], delegate: NoteDropDelegate(
                                item: note,
                                noteStore: noteStore,
                                draggingNoteID: $draggingNoteID
                            ))
                        }
                    }
                    .padding(.horizontal, 4)
                    .padding(.top, 2)
                    .padding(.bottom, 12)
                    .animation(.spring(response: 0.24, dampingFraction: 0.82), value: noteStore.notes)
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

// Drop Delegate for live drag & drop note reordering
struct NoteDropDelegate: DropDelegate {
    let item: Note
    let noteStore: NoteStore
    @Binding var draggingNoteID: UUID?

    func performDrop(info: DropInfo) -> Bool {
        draggingNoteID = nil
        return true
    }

    func dropEntered(info: DropInfo) {
        guard let sourceID = draggingNoteID, sourceID != item.id else { return }
        withAnimation(.spring(response: 0.24, dampingFraction: 0.82)) {
            noteStore.moveNote(from: sourceID, to: item.id)
        }
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }

    func dropExited(info: DropInfo) {}
}
