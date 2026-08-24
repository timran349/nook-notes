import SwiftUI
import AppKit

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
                            .font(.geist(13, weight: .medium))
                    }
                    .foregroundColor(.secondary)
                    .contentShape(Rectangle())
                }
                .buttonStyle(HeaderIconButtonStyle())
            } else {
                HStack(spacing: 6) {
                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.secondary.opacity(0.5))
                        .help("Drag to move Nook")

                    Text("Nook")
                        .font(.geist(15, weight: .bold))
                        .foregroundColor(.primary.opacity(0.9))
                }
            }

            Spacer()

            if !isEditing {
                // Search button
                Button(action: {
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.75)) {
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
                    withAnimation(.spring(response: 0.22, dampingFraction: 0.8)) {
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
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
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
                withAnimation(.spring(response: 0.22, dampingFraction: 0.8)) {
                    windowManager.isSettingsPresented.toggle()
                }
            }) {
                Image(systemName: "gearshape")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(windowManager.isSettingsPresented ? .accentColor : .secondary)
                    .rotationEffect(.degrees(windowManager.isSettingsPresented ? 45 : 0))
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
        .contentShape(Rectangle())
        .contextMenu {
            Button(action: {
                windowManager.resetToBottomLeft()
            }) {
                Label("Reset Position to Bottom-Left", systemImage: "arrow.uturn.backward")
            }

            Button(action: {
                windowManager.collapsePanel()
            }) {
                Label("Collapse Panel", systemImage: "chevron.down")
            }

            Button(action: {
                withAnimation(.spring(response: 0.22, dampingFraction: 0.8)) {
                    windowManager.isSettingsPresented.toggle()
                }
            }) {
                Label("Settings...", systemImage: "gearshape")
            }

            Divider()

            Button(role: .destructive, action: {
                NSApp.terminate(nil)
            }) {
                Label("Quit Nook Notes", systemImage: "power")
            }
        }
    }
}

struct HeaderIconButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.primary.opacity(configuration.isPressed ? 0.1 : 0.0))
            )
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.15, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
