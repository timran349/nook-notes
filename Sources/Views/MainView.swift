import SwiftUI

public struct MainView: View {
    @StateObject var noteStore = NoteStore()
    @StateObject var windowManager = WindowManager.shared

    @State private var isEditingNote: Bool = false
    @Environment(\.colorScheme) private var colorScheme

    public init() {}

    private var exactGrayBackground: Color {
        colorScheme == .dark
            ? Color(red: 0.11, green: 0.11, blue: 0.12)
            : Color(red: 0.949, green: 0.949, blue: 0.968)
    }

    public var body: some View {
        Group {
            if !windowManager.isExpanded {
                CollapsedTabView(windowManager: windowManager)
                    .transition(AnyTransition.opacity.combined(with: .scale))
            } else {
                VStack(spacing: 0) {
                    // Header
                    HeaderView(
                        noteStore: noteStore,
                        windowManager: windowManager,
                        isEditing: isEditingNote,
                        onBack: {
                            withAnimation(.spring(response: 0.24, dampingFraction: 0.82)) {
                                isEditingNote = false
                            }
                        }
                    )

                    // Search Bar
                    if noteStore.isSearching && !isEditingNote && !windowManager.isSettingsPresented {
                        SearchBarView(searchText: $noteStore.searchQuery) {
                            withAnimation(.spring(response: 0.22, dampingFraction: 0.8)) {
                                noteStore.isSearching = false
                                noteStore.searchQuery = ""
                            }
                        }
                        .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
                    }

                    // Content Body
                    ZStack {
                        if windowManager.isSettingsPresented {
                            SettingsView(
                                noteStore: noteStore,
                                windowManager: windowManager,
                                onClose: {
                                    withAnimation(.spring(response: 0.24, dampingFraction: 0.82)) {
                                        windowManager.isSettingsPresented = false
                                    }
                                }
                            )
                            .transition(AnyTransition.opacity.combined(with: .scale))
                        } else if isEditingNote, let selectedNote = bindingForSelectedNote() {
                            NoteEditorView(
                                note: selectedNote,
                                noteStore: noteStore,
                                onNoteChanged: { updated in
                                    noteStore.updateNote(updated)
                                }
                            )
                            .transition(.asymmetric(
                                insertion: AnyTransition.move(edge: .trailing).combined(with: .opacity),
                                removal: AnyTransition.move(edge: .trailing).combined(with: .opacity)
                            ))
                        } else {
                            NoteListView(
                                noteStore: noteStore,
                                onSelectNote: { note in
                                    withAnimation(.spring(response: 0.26, dampingFraction: 0.82)) {
                                        noteStore.selectedNoteId = note.id
                                        isEditingNote = true
                                    }
                                }
                            )
                            .transition(.asymmetric(
                                insertion: AnyTransition.move(edge: .leading).combined(with: .opacity),
                                removal: AnyTransition.move(edge: .leading).combined(with: .opacity)
                            ))
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .background(exactGrayBackground)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(Color.primary.opacity(0.08), lineWidth: 0.75)
                )
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 1, y: 4)
                .padding(4)
                .transition(AnyTransition.opacity.combined(with: .scale))
            }
        }
        .animation(.spring(response: 0.26, dampingFraction: 0.82), value: windowManager.isExpanded)
        .animation(.spring(response: 0.24, dampingFraction: 0.82), value: isEditingNote)
        .animation(.spring(response: 0.24, dampingFraction: 0.82), value: windowManager.isSettingsPresented)
        .onAppear {
            setupGlobalHotkey()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                DetachedStickyManager.shared.syncDetachedWindows(noteStore: noteStore)
            }
        }
        .background(ShortcutHandlerView(
            onNewNote: {
                if windowManager.isExpanded {
                    withAnimation(.spring(response: 0.24, dampingFraction: 0.82)) {
                        let new = noteStore.createNote()
                        noteStore.selectedNoteId = new.id
                        isEditingNote = true
                    }
                }
            },
            onSearch: {
                if windowManager.isExpanded {
                    withAnimation(.spring(response: 0.22, dampingFraction: 0.8)) {
                        noteStore.isSearching.toggle()
                        if !noteStore.isSearching {
                            noteStore.searchQuery = ""
                        }
                    }
                }
            },
            onEscape: {
                if windowManager.isExpanded {
                    withAnimation(.spring(response: 0.24, dampingFraction: 0.82)) {
                        if windowManager.isSettingsPresented {
                            windowManager.isSettingsPresented = false
                        } else if isEditingNote {
                            isEditingNote = false
                        } else {
                            windowManager.collapsePanel()
                        }
                    }
                }
            },
            onDelete: {
                if windowManager.isExpanded, let id = noteStore.selectedNoteId {
                    withAnimation(.spring(response: 0.24, dampingFraction: 0.82)) {
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
