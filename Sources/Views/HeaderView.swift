import SwiftUI

public struct HeaderView: View {
    @ObservedObject var noteStore: NoteStore
    @ObservedObject var windowManager: WindowManager
    public var isEditing: Bool
    public var onBack: () -> Void

    public init(
        noteStore: NoteStore,
        windowManager: WindowManager,
        isEditing: Bool,
        onBack: @escaping () -> Void
    ) {
        self.noteStore = noteStore
        self.windowManager = windowManager
        self.isEditing = isEditing
        self.onBack = onBack
    }

    public var body: some View {
        HStack(spacing: 12) {
            if isEditing {
                Button(action: onBack) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 11, weight: .bold))
                        Text("Notes")
                            .font(.system(size: 13, weight: .medium, design: .default))
                    }
                    .foregroundColor(.secondary)
                    .contentShape(Rectangle())
                }
                .buttonStyle(HeaderIconButtonStyle())
            } else {
                Text("Nook")
                    .font(.system(size: 15, weight: .bold, design: .default))
                    .foregroundColor(.primary.opacity(0.9))
            }

            Spacer()

            if !isEditing {
                // Search button
                Button(action: {
                    withAnimation(.easeOut(duration: 0.15)) {
                        noteStore.isSearching.toggle()
                        if !noteStore.isSearching {
                            noteStore.searchQuery = ""
                        }
                    }
                }) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(noteStore.isSearching ? .accentColor : .secondary)
                }
                .buttonStyle(HeaderIconButtonStyle())

                // New note button
                Button(action: {
                    withAnimation(.easeOut(duration: 0.15)) {
                        let newNote = noteStore.createNote()
                        noteStore.selectedNoteId = newNote.id
                    }
                }) {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.primary.opacity(0.85))
                }
                .buttonStyle(HeaderIconButtonStyle())
                .help("New Note (Cmd+N)")
            } else {
                // Delete active note button
                Button(action: {
                    if let selectedId = noteStore.selectedNoteId {
                        withAnimation(.easeOut(duration: 0.15)) {
                            noteStore.deleteNote(id: selectedId)
                            onBack()
                        }
                    }
                }) {
                    Image(systemName: "trash")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(HeaderIconButtonStyle())
                .help("Delete Note (Cmd+Delete)")
            }

            // Settings button
            Button(action: {
                withAnimation(.easeOut(duration: 0.15)) {
                    windowManager.isSettingsPresented.toggle()
                }
            }) {
                Image(systemName: "gearshape")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(windowManager.isSettingsPresented ? .accentColor : .secondary)
            }
            .buttonStyle(HeaderIconButtonStyle())

            // Collapse button
            Button(action: {
                windowManager.collapsePanel()
            }) {
                Image(systemName: "chevron.down.square.fill")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary.opacity(0.6))
            }
            .buttonStyle(HeaderIconButtonStyle())
            .help("Collapse (Esc)")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

struct HeaderIconButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.primary.opacity(configuration.isPressed ? 0.08 : 0.0))
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}
