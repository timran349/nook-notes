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
                // 100% Exact match to mockup image: Grid icon + lowercase chunky serif "nook notes"
                HStack(spacing: 8) {
                    Image(systemName: "square.grid.2x2")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(headerIconColor)

                    Text("nook notes")
                        .font(.system(size: 21, weight: .bold, design: .serif))
                        .foregroundColor(headerIconColor)
                }
            }

            Spacer()

            // Header actions: +  ⚙  ✕ (Exact 3 icons from image)
            HStack(spacing: 16) {
                if !isEditing {
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
        .padding(.horizontal, 20)
        .padding(.top, 18)
        .padding(.bottom, 14)
    }
}
