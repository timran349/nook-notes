import SwiftUI
import AppKit

public struct HeaderView: View {
    @ObservedObject var noteStore: NoteStore
    @ObservedObject var windowManager: WindowManager
    public var isEditing: Bool
    public var onBack: () -> Void

    @Environment(\.colorScheme) private var colorScheme

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

    private var mutedLogoGray: Color {
        colorScheme == .dark
            ? Color(red: 0.45, green: 0.45, blue: 0.48)
            : Color(red: 0.72, green: 0.72, blue: 0.75)
    }

    public var body: some View {
        HStack(alignment: .center) {
            if isEditing {
                Button(action: onBack) {
                    HStack(spacing: 5) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 11, weight: .bold))
                        Text("Notes")
                            .font(.geist(13, weight: .semibold))
                    }
                    .foregroundColor(.primary)
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                // Bold Muted Gray Logo matching user image
                HStack(spacing: 6) {
                    Image(systemName: "square.grid.2x2.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(mutedLogoGray)

                    Text("Nook Notes")
                        .font(.geist(16, weight: .bold))
                        .foregroundColor(mutedLogoGray)
                }
            }

            Spacer()

            // Header actions
            HStack(spacing: 12) {
                if !isEditing {
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
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(noteStore.isSearching ? .primary : .secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .help("Search Notes")

                    // New Note button
                    Button(action: {
                        withAnimation(.spring(response: 0.22, dampingFraction: 0.8)) {
                            let newNote = noteStore.createNote()
                            noteStore.selectedNoteId = newNote.id
                        }
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.primary)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .help("New Note (Cmd+N)")
                } else {
                    Button(action: {
                        if let selectedId = noteStore.selectedNoteId {
                            withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                                noteStore.deleteNote(id: selectedId)
                                onBack()
                            }
                        }
                    }) {
                        Image(systemName: "trash")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .help("Delete Note")
                }

                Button(action: {
                    withAnimation(.spring(response: 0.22, dampingFraction: 0.8)) {
                        windowManager.isSettingsPresented.toggle()
                    }
                }) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 13))
                        .foregroundColor(windowManager.isSettingsPresented ? .primary : .secondary.opacity(0.8))
                        .rotationEffect(.degrees(windowManager.isSettingsPresented ? 45 : 0))
                }
                .buttonStyle(PlainButtonStyle())
                .help("Settings")

                Button(action: {
                    windowManager.collapsePanel()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary.opacity(0.6))
                }
                .buttonStyle(PlainButtonStyle())
                .help("Collapse (Esc)")
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }
}
