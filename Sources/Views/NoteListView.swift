import SwiftUI

public struct NoteListView: View {
    @ObservedObject var noteStore: NoteStore
    public var onSelectNote: (Note) -> Void

    @State private var selectedTab: String = "Items"
    @State private var selectedColorFilter: NoteColor? = nil

    @State private var noteToRename: Note?
    @State private var renameText: String = ""
    @State private var showRenameAlert: Bool = false

    private var filteredNotesList: [Note] {
        var base = noteStore.filteredNotes
        if selectedTab == "Floating" {
            base = base.filter { $0.isDetached }
        }
        if let colorFilter = selectedColorFilter {
            base = base.filter { $0.color == colorFilter }
        }
        return base
    }

    public var body: some View {
        VStack(spacing: 10) {
            // Folder-style Tab Bar matching reference image ("Items", "Notebooks", "Canvases")
            HStack(spacing: 4) {
                TabPillButton(title: "Items", count: noteStore.notes.count, isSelected: selectedTab == "Items") {
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                        selectedTab = "Items"
                    }
                }

                TabPillButton(title: "Floating", count: noteStore.notes.filter { $0.isDetached }.count, isSelected: selectedTab == "Floating") {
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                        selectedTab = "Floating"
                    }
                }

                Spacer()

                // "+ Add" Button matching reference image
                Button(action: {
                    withAnimation(.spring(response: 0.22, dampingFraction: 0.8)) {
                        let newNote = noteStore.createNote()
                        onSelectNote(newNote)
                    }
                }) {
                    HStack(spacing: 4) {
                        Text("+ Add")
                            .font(.geist(11, weight: .semibold))
                    }
                    .foregroundColor(.primary.opacity(0.85))
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.primary.opacity(0.06))
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 14)
            .padding(.top, 2)

            // Category Dots Filter Bar matching reference image
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    // All filter dot
                    FilterDotChip(
                        label: "All",
                        color: nil,
                        count: noteStore.notes.count,
                        isSelected: selectedColorFilter == nil
                    ) {
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                            selectedColorFilter = nil
                        }
                    }

                    ForEach(NoteColor.allCases, id: \.self) { c in
                        let count = noteStore.notes.filter { $0.color == c }.count
                        FilterDotChip(
                            label: c.tagLabel,
                            color: c.accentBorder,
                            count: count,
                            isSelected: selectedColorFilter == c
                        ) {
                            withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                                selectedColorFilter = selectedColorFilter == c ? nil : c
                            }
                        }
                    }
                }
                .padding(.horizontal, 14)
            }

            // Cards Scroll Grid
            if filteredNotesList.isEmpty {
                VStack(spacing: 12) {
                    Spacer()
                    Image(systemName: "note.text")
                        .font(.system(size: 28, weight: .thin))
                        .foregroundColor(.secondary.opacity(0.5))

                    Text("No matching notes")
                        .font(.geist(13, weight: .medium))
                        .foregroundColor(.secondary)

                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(filteredNotesList) { note in
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

// Tab Pill Button matching reference image tabs ("Items", "Notebooks", "Canvases")
struct TabPillButton: View {
    let title: String
    let count: Int
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Text(title)
                    .font(.geist(12, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? .primary : .secondary)

                if count > 0 {
                    Text("\(count)")
                        .font(.geist(10, weight: .medium))
                        .foregroundColor(isSelected ? .primary.opacity(0.8) : .secondary.opacity(0.6))
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.primary.opacity(0.1) : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Category Dot Chip matching reference image left sidebar dots
struct FilterDotChip: View {
    let label: String
    let color: Color?
    let count: Int
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                if let color = color {
                    Circle()
                        .fill(color)
                        .frame(width: 7, height: 7)
                }

                Text(label)
                    .font(.geist(11, weight: isSelected ? .bold : .regular))
                    .foregroundColor(isSelected ? .primary : .secondary)

                Text("\(count)")
                    .font(.geist(10, weight: .regular))
                    .foregroundColor(.secondary.opacity(0.6))
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(isSelected ? Color.primary.opacity(0.08) : Color.primary.opacity(0.03))
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.primary.opacity(0.2) : Color.clear, lineWidth: 0.75)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
