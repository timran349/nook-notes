import SwiftUI

public struct MainView: View {
    @StateObject var noteStore = NoteStore()
    @StateObject var windowManager = WindowManager.shared

    @State private var isEditingNote: Bool = false

    public init() {}

    public var body: some View {
        Group {
            if !windowManager.isExpanded {
                CollapsedTabView(windowManager: windowManager)
            } else {
                VStack(spacing: 0) {
                    // Header
                    HeaderView(
                        noteStore: noteStore,
                        windowManager: windowManager,
                        isEditing: isEditingNote,
                        onBack: {
                            withAnimation(.easeOut(duration: 0.15)) {
                                isEditingNote = false
                            }
                        }
                    )

                    // Search Bar
                    if noteStore.isSearching && !isEditingNote && !windowManager.isSettingsPresented {
                        SearchBarView(searchText: $noteStore.searchQuery) {
                            withAnimation(.easeOut(duration: 0.15)) {
                                noteStore.isSearching = false
                                noteStore.searchQuery = ""
                            }
                        }
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    Divider()
                        .opacity(0.1)

                    // Content Body
                    ZStack {
                        if windowManager.isSettingsPresented {
                            SettingsView(
                                noteStore: noteStore,
                                windowManager: windowManager,
                                onClose: {
                                    withAnimation(.easeOut(duration: 0.15)) {
                                        windowManager.isSettingsPresented = false
                                    }
                                }
                            )
                            .transition(.opacity)
                        } else if isEditingNote, let selectedNote = bindingForSelectedNote() {
                            NoteEditorView(
                                note: selectedNote,
                                onNoteChanged: { updated in
                                    noteStore.updateNote(updated)
                                }
                            )
                            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .trailing)))
                        } else {
                            NoteListView(
                                noteStore: noteStore,
                                onSelectNote: { note in
                                    withAnimation(.easeOut(duration: 0.15)) {
                                        noteStore.selectedNoteId = note.id
                                        isEditingNote = true
                                    }
                                }
                            )
                            .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .leading)))
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .background(
                    VisualEffectView(material: .hudWindow, blendingMode: .withinWindow, state: .active)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.primary.opacity(0.12), lineWidth: 0.75)
                )
                .shadow(color: Color.black.opacity(0.22), radius: 12, x: 2, y: 4)
                .padding(4)
                .transition(.scale(scale: 0.98).combined(with: .opacity))
            }
        }
        .onAppear {
            setupGlobalHotkey()
        }
        .background(ShortcutHandlerView(
            onNewNote: {
                if windowManager.isExpanded {
                    withAnimation(.easeOut(duration: 0.15)) {
                        let new = noteStore.createNote()
                        noteStore.selectedNoteId = new.id
                        isEditingNote = true
                    }
                }
            },
            onSearch: {
                if windowManager.isExpanded {
                    withAnimation(.easeOut(duration: 0.15)) {
                        noteStore.isSearching.toggle()
                        if !noteStore.isSearching {
                            noteStore.searchQuery = ""
                        }
                    }
                }
            },
            onEscape: {
                if windowManager.isExpanded {
                    if windowManager.isSettingsPresented {
                        windowManager.isSettingsPresented = false
                    } else if isEditingNote {
                        isEditingNote = false
                    } else {
                        windowManager.collapsePanel()
                    }
                }
            },
            onDelete: {
                if windowManager.isExpanded, let id = noteStore.selectedNoteId {
                    withAnimation(.easeOut(duration: 0.15)) {
                        noteStore.deleteNote(id: id)
                        isEditingNote = false
                    }
                }
            }
        ))
    }

    private func bindingForSelectedNote() -> Binding<Note>? {
        guard let id = noteStore.selectedNoteId,
              let index = noteStore.notes.firstIndex(where: { $0.id == id }) else {
            return nil
        }
        return Binding(
            get: { self.noteStore.notes[index] },
            set: { self.noteStore.notes[index] = $0 }
        )
    }

    private func setupGlobalHotkey() {
        GlobalHotkeyManager.shared.onHotKeyTriggered = {
            windowManager.togglePanel()
        }
        GlobalHotkeyManager.shared.register()
    }
}

// Invisible view intercepting macOS keyboard shortcuts
struct ShortcutHandlerView: NSViewRepresentable {
    var onNewNote: () -> Void
    var onSearch: () -> Void
    var onEscape: () -> Void
    var onDelete: () -> Void

    func makeNSView(context: Context) -> ShortcutView {
        let view = ShortcutView()
        view.onNewNote = onNewNote
        view.onSearch = onSearch
        view.onEscape = onEscape
        view.onDelete = onDelete
        return view
    }

    func updateNSView(_ nsView: ShortcutView, context: Context) {
        nsView.onNewNote = onNewNote
        nsView.onSearch = onSearch
        nsView.onEscape = onEscape
        nsView.onDelete = onDelete
    }

    class ShortcutView: NSView {
        var onNewNote: (() -> Void)?
        var onSearch: (() -> Void)?
        var onEscape: (() -> Void)?
        var onDelete: (() -> Void)?

        private var monitor: Any?

        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            if window != nil && monitor == nil {
                monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
                    guard let self = self else { return event }

                    let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)

                    // Cmd + N
                    if flags == .command && event.charactersIgnoringModifiers == "n" {
                        self.onNewNote?()
                        return nil
                    }

                    // Cmd + F
                    if flags == .command && event.charactersIgnoringModifiers == "f" {
                        self.onSearch?()
                        return nil
                    }

                    // Cmd + Delete
                    if flags == .command && event.keyCode == 51 { // 51 is Backspace/Delete key code
                        self.onDelete?()
                        return nil
                    }

                    // Escape
                    if event.keyCode == 53 { // 53 is Esc
                        self.onEscape?()
                        return nil
                    }

                    return event
                }
            }
        }

        deinit {
            if let monitor = monitor {
                NSEvent.removeMonitor(monitor)
            }
        }
    }
}
