import SwiftUI

public struct NoteListView: View {
    @ObservedObject var noteStore: NoteStore
    @ObservedObject var clipboardManager = ClipboardManager.shared
    public var onSelectNote: (Note) -> Void

    @State private var selectedTab: String = "Notes" // Options: "Stickies", "Notes", "Clipboard"
    @State private var noteToRename: Note?
    @State private var renameText: String = ""
    @State private var showRenameAlert: Bool = false

    private var activeNotesList: [Note] {
        if selectedTab == "Stickies" {
            return noteStore.filteredNotes.filter { $0.isDetached }
        } else {
            return noteStore.filteredNotes
        }
    }

    public var body: some View {
        VStack(spacing: 12) {
            // Clean Segmented Pill Tab Bar ("Stickies", "Notes", "Clipboard")
            HStack(spacing: 4) {
                TabSegmentPill(title: "Stickies", isSelected: selectedTab == "Stickies") {
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                        selectedTab = "Stickies"
                    }
                }

                TabSegmentPill(title: "Notes", isSelected: selectedTab == "Notes") {
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                        selectedTab = "Notes"
                    }
                }

                TabSegmentPill(title: "Clipboard", isSelected: selectedTab == "Clipboard") {
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                        selectedTab = "Clipboard"
                    }
                }
            }
            .padding(4)
            .background(
                Capsule()
                    .fill(Color.primary.opacity(0.04))
            )
            .padding(.horizontal, 16)

            // Content Area depending on Tab
            if selectedTab == "Clipboard" {
                // Clipboard Snippets History View
                ClipboardListView(clipboardManager: clipboardManager)
            } else {
                // Notes / Stickies Cards List View
                if activeNotesList.isEmpty {
                    VStack(spacing: 12) {
                        Spacer()
                        Image(systemName: selectedTab == "Stickies" ? "pin.slash" : "note.text")
                            .font(.system(size: 32, weight: .thin))
                            .foregroundColor(.secondary.opacity(0.4))

                        Text(selectedTab == "Stickies" ? "No floating stickies on desktop" : "No notes yet")
                            .font(.geist(13, weight: .medium))
                            .foregroundColor(.secondary)

                        if selectedTab == "Notes" {
                            Button(action: {
                                withAnimation(.spring(response: 0.22, dampingFraction: 0.8)) {
                                    let newNote = noteStore.createNote()
                                    onSelectNote(newNote)
                                }
                            }) {
                                Text("+ Create Note")
                                    .font(.geist(12, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule()
                                            .fill(Color.primary.opacity(0.85))
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }

                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 10) {
                            ForEach(activeNotesList) { note in
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
                        .padding(.horizontal, 14)
                        .padding(.bottom, 60) // Space for bottom pill controls
                    }
                }
            }
        }
        .overlay(
            // Bottom Floating Glass Control Pill Bar matching reference image
            VStack {
                Spacer()
                HStack(spacing: 16) {
                    // Search toggle
                    Button(action: {
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                            noteStore.isSearching.toggle()
                            if !noteStore.isSearching {
                                noteStore.searchQuery = ""
                            }
                        }
                    }) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(noteStore.isSearching ? .accentColor : .secondary)
                    }
                    .buttonStyle(PlainButtonStyle())

                    // Plus button (New Note)
                    Button(action: {
                        withAnimation(.spring(response: 0.22, dampingFraction: 0.8)) {
                            let newNote = noteStore.createNote()
                            onSelectNote(newNote)
                        }
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.primary)
                    }
                    .buttonStyle(PlainButtonStyle())

                    // Tab toggle icon
                    Button(action: {
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                            if selectedTab == "Notes" {
                                selectedTab = "Stickies"
                            } else if selectedTab == "Stickies" {
                                selectedTab = "Clipboard"
                            } else {
                                selectedTab = "Notes"
                            }
                        }
                    }) {
                        Image(systemName: "checkmark.square.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.primary.opacity(0.85))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 9)
                .background(
                    Capsule()
                        .fill(Color.primary.opacity(0.06))
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.9))
                        )
                )
                .overlay(
                    Capsule()
                        .stroke(Color.primary.opacity(0.08), lineWidth: 0.75)
                )
                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
                .padding(.bottom, 12)
            }
        )
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

// Clean Tab Segment Pill
struct TabSegmentPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.geist(12, weight: isSelected ? .bold : .medium))
                .foregroundColor(isSelected ? .primary : .secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.white : Color.clear)
                        .shadow(color: isSelected ? Color.black.opacity(0.06) : Color.clear, radius: 4, x: 0, y: 2)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Clipboard History List View
struct ClipboardListView: View {
    @ObservedObject var clipboardManager: ClipboardManager
    @State private var copiedId: UUID?

    var body: some View {
        if clipboardManager.items.isEmpty {
            VStack(spacing: 12) {
                Spacer()
                Image(systemName: "doc.on.clipboard")
                    .font(.system(size: 32, weight: .thin))
                    .foregroundColor(.secondary.opacity(0.4))
                Text("Clipboard history is empty")
                    .font(.geist(13, weight: .medium))
                    .foregroundColor(.secondary)
                Text("Copy text anywhere on your Mac to save snippets here automatically")
                    .font(.geist(11, weight: .regular))
                    .foregroundColor(.secondary.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            VStack(spacing: 8) {
                HStack {
                    Text("PASTEBOARD RECENT COPIES")
                        .font(.geist(10, weight: .bold))
                        .foregroundColor(.secondary.opacity(0.6))
                    Spacer()
                    Button("Clear All") {
                        clipboardManager.clearAll()
                    }
                    .font(.geist(10, weight: .semibold))
                    .foregroundColor(.red.opacity(0.8))
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 16)
                .padding(.top, 4)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 8) {
                        ForEach(clipboardManager.items) { item in
                            HStack(alignment: .top, spacing: 10) {
                                Image(systemName: "doc.on.doc")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                                    .padding(.top, 2)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.text)
                                        .font(.geist(12, weight: .regular))
                                        .foregroundColor(.primary)
                                        .lineLimit(3)

                                    Text(item.formattedTime)
                                        .font(.geist(10, weight: .medium))
                                        .foregroundColor(.secondary.opacity(0.6))
                                }

                                Spacer()

                                Button(action: {
                                    clipboardManager.copyToClipboard(item)
                                    withAnimation {
                                        copiedId = item.id
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                        if copiedId == item.id {
                                            copiedId = nil
                                        }
                                    }
                                }) {
                                    Text(copiedId == item.id ? "Copied!" : "Copy")
                                        .font(.geist(10, weight: .bold))
                                        .foregroundColor(copiedId == item.id ? .green : .accentColor)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(
                                            Capsule()
                                                .fill(Color.accentColor.opacity(0.1))
                                        )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(Color.white)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(Color.primary.opacity(0.04), lineWidth: 0.75)
                            )
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.bottom, 60)
                }
            }
        }
    }
}
