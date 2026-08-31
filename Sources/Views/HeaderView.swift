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

    private var headerIconColor: Color {
        colorScheme == .dark
            ? Color(red: 0.65, green: 0.65, blue: 0.68)
            : Color(red: 0.50, green: 0.49, blue: 0.51)
    }

    private var layoutIconName: String {
        switch noteStore.layoutMode {
        case "grid2": return "square.grid.2x2.fill"
        case "grid3": return "square.grid.3x3.fill"
        default: return "square.grid.2x2"
        }
    }

    private var layoutTooltip: String {
        switch noteStore.layoutMode {
        case "grid2": return "Layout: 2x2 Grid (Click for 3x3)"
        case "grid3": return "Layout: 3x3 Grid (Click for List)"
        default: return "Layout: List (Click for 2x2 Grid)"
        }
    }

    public var body: some View {
        HStack(alignment: .center) {
            if isEditing {
                Button(action: onBack) {
                    HStack(spacing: 5) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(headerIconColor)
                        Text("notes")
                            .font(.system(size: 19, weight: .bold, design: .serif))
                            .foregroundColor(headerIconColor)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                // Interactive Grid/List Layout Mode Toggle + Logo
                HStack(spacing: 8) {
                    Button(action: {
                        withAnimation(.spring(response: 0.24, dampingFraction: 0.82)) {
                            switch noteStore.layoutMode {
                            case "list": noteStore.layoutMode = "grid2"
                            case "grid2": noteStore.layoutMode = "grid3"
                            default: noteStore.layoutMode = "list"
                            }
                        }
                    }) {
                        Image(systemName: layoutIconName)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(headerIconColor)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .help(layoutTooltip)

                    Text("nook notes")
                        .font(.system(size: 21, weight: .bold, design: .serif))
                        .foregroundColor(headerIconColor)
                }
            }

            Spacer()

            // Header actions: 📌 Pin (Always Open) | + New Note | ⚙ Settings | ✕ Close
            HStack(spacing: 14) {
                if !isEditing {
                    // 📌 Pin Icon (Keeps window open & at top all the time)
                    Button(action: {
                        withAnimation(.spring(response: 0.22, dampingFraction: 0.8)) {
                            windowManager.isPinned.toggle()
                        }
                    }) {
                        Image(systemName: windowManager.isPinned ? "pin.fill" : "pin")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(windowManager.isPinned ? .primary : headerIconColor)
                            .rotationEffect(.degrees(windowManager.isPinned ? 45 : 0))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .help(windowManager.isPinned ? "Unpin Window (Allow Auto-Collapse)" : "Pin Window (Keep Always Open & On Top)")

                    // + (Plus button)
                    Button(action: {
                        withAnimation(.spring(response: 0.22, dampingFraction: 0.8)) {
                            let newNote = noteStore.createNote()
                            noteStore.selectedNoteId = newNote.id
                        }
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(headerIconColor)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .help("New Note")

                    // ⚙ (Settings gear)
                    Button(action: {
                        withAnimation(.spring(response: 0.22, dampingFraction: 0.8)) {
                            windowManager.isSettingsPresented.toggle()
                        }
                    }) {
                        Image(systemName: "gearshape")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(windowManager.isSettingsPresented ? .primary : headerIconColor)
                            .rotationEffect(.degrees(windowManager.isSettingsPresented ? 45 : 0))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .help("Settings")

                    // ✕ (Close / Collapse)
                    Button(action: {
                        windowManager.collapsePanel()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(headerIconColor)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .help("Collapse (Esc)")
                } else {
                    // Pin Button in editor view
                    Button(action: {
                        withAnimation(.spring(response: 0.22, dampingFraction: 0.8)) {
                            windowManager.isPinned.toggle()
                        }
                    }) {
                        Image(systemName: windowManager.isPinned ? "pin.fill" : "pin")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(windowManager.isPinned ? .primary : headerIconColor)
                            .rotationEffect(.degrees(windowManager.isPinned ? 45 : 0))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .help(windowManager.isPinned ? "Unpin Window (Allow Auto-Collapse)" : "Pin Window (Keep Always Open & On Top)")

                    Button(action: {
                        if let selectedId = noteStore.selectedNoteId {
                            withAnimation(.spring(response: 0.2, dampingFraction: 0.8)) {
                                noteStore.deleteNote(id: selectedId)
                                onBack()
                            }
                        }
                    }) {
                        Image(systemName: "trash")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(headerIconColor)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .help("Delete Note")

                    Button(action: {
                        windowManager.collapsePanel()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(headerIconColor)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .help("Collapse (Esc)")
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }
}
